#include <WiFi.h>
#include <HTTPClient.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <time.h>

/* === Wi-Fi credentials === */


/* === Supabase API === */
const char* SUPABASE_URL = "http://192.168.1.73:54321";
const char* SUPABASE_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
const char* DEVICE_ID = "a229ab1b-05d8-48eb-bd67-77b0c93b5b18";  // UUID from your Supabase table

/* === Pin assignments === */
constexpr uint8_t PIN_RELAY  = 25;
constexpr uint8_t PIN_I_SENS = 34;
constexpr uint8_t PIN_V_SENS = 35;

/* === Calibration === */
const float ZERO_OFFSET     = 1.46f;
const float ACS_SENSITIVITY = 0.185f;
const float DIVIDER_RATIO   = 5.0f;

WebServer server(80);
bool relayOn = false;

/* === Sensor Struct === */
struct Readings {
  float voltage;
  float current;
  float power;
};

Readings readSensors() {
  int rawI = analogRead(PIN_I_SENS);
  int rawV = analogRead(PIN_V_SENS);
  float vI = rawI * (3.3f / 4095.0f);
  float vS = rawV * (3.3f / 4095.0f);
  float current = (vI - ZERO_OFFSET) / ACS_SENSITIVITY;
  float voltage = vS * DIVIDER_RATIO;
  float power = voltage * current;
  return { voltage, current, power };
}

/* === UI === */
String makePage(const Readings& r, bool state) {
  String html = "<html><body style='text-align:center;'>";
  html += "<h1>Smart Plug Dashboard</h1>";
  html += "<p><b>Voltage:</b> " + String(r.voltage, 2) + " V</p>";
  html += "<p><b>Current:</b> " + String(r.current, 3) + " A</p>";
  html += "<p><b>Power:</b> " + String(r.power, 2) + " W</p>";
  html += "<hr>";
  html += "<a href='/toggle'><button>";
  html += state ? "Turn OFF Load" : "Turn ON Load";
  html += "</button></a></body></html>";
  return html;
}

void handleRoot() {
  Readings r = readSensors();
  server.send(200, "text/html", makePage(r, relayOn));
}

void handleToggle() {
  relayOn = !relayOn;
  digitalWrite(PIN_RELAY, relayOn ? HIGH : LOW);
  Serial.printf("Relay toggled %s manually\n", relayOn ? "ON" : "OFF");
  handleRoot();
}

// === Store previous power and time for kWh calculation ===
float prevPower = 0;
unsigned long prevMillis = 0;
bool firstReading = true;

/* === Send Data to Supabase === */
void sendToSupabase(float power, float powerKwh) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String endpoint = String(SUPABASE_URL) + "/rest/v1/power_readings";
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Prefer", "return=minimal");

  StaticJsonDocument<192> doc;
  doc["device_id"] = DEVICE_ID;
  doc["power_watts"] = power;
  doc["power_kwh"] = powerKwh;

  time_t now = time(nullptr);
  struct tm* p_tm = gmtime(&now);
  char isoTime[25];
  strftime(isoTime, sizeof(isoTime), "%Y-%m-%dT%H:%M:%SZ", p_tm);
  doc["timestamp"] = isoTime;

  String json;
  serializeJson(doc, json);
  Serial.println("Sending JSON: " + json);

  int code = http.POST(json);
  Serial.print("Supabase response: ");
  Serial.println(code);
  if (code >= 400) Serial.println(http.getString());

  http.end();
}

/* === Fetch Relay Status from Supabase === */
void fetchRelayStatus() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String endpoint = String(SUPABASE_URL) + "/rest/v1/devices?select=status&id=eq." + DEVICE_ID;
  http.begin(endpoint);
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_API_KEY));
  http.addHeader("Accept", "application/json");

  int code = http.GET();

  if (code == 200) {
    String response = http.getString();
    Serial.println("Status fetch response: " + response);

    StaticJsonDocument<256> doc;
    DeserializationError err = deserializeJson(doc, response);
    if (!err && doc.is<JsonArray>() && doc.size() > 0 && doc[0]["status"]) {
      String status = doc[0]["status"].as<String>();
      bool shouldBeOn = status == "online";
      if (shouldBeOn != relayOn) {
        relayOn = shouldBeOn;
        digitalWrite(PIN_RELAY, relayOn ? HIGH : LOW);
        Serial.printf("Relay switched %s via cloud command\n", relayOn ? "ON" : "OFF");
      }
    } else {
      Serial.println("Failed to parse JSON or status not found.");
    }
  } else {
    Serial.printf("Failed to fetch status, code: %d\n", code);
    Serial.println(http.getString());
  }
  http.end();
}

/* === Setup === */
void setup() {
  Serial.begin(9600);
  pinMode(PIN_RELAY, OUTPUT);
  digitalWrite(PIN_RELAY, LOW);
  pinMode(PIN_I_SENS, INPUT);
  pinMode(PIN_V_SENS, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.println(WiFi.localIP());

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("Waiting for NTP time sync...");
  time_t now = time(nullptr);
  while (now < 8 * 3600 * 2) { // Wait until time is synced
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("");
  Serial.println("Time synchronized!");

  server.on("/", handleRoot);
  server.on("/toggle", handleToggle);
  Serial.println("Web server started!");
}

/* === Loop === */
void loop() {
  server.handleClient();

  static unsigned long lastCheck = 0;
  if (millis() - lastCheck > 2000) {
    Readings r = readSensors();
    Serial.printf("P=%.2fW\n", r.power);

    float powerKwh = 0;
    unsigned long nowMillis = millis();
    if (!firstReading) {
      float hours = (nowMillis - prevMillis) / 1000.0 / 3600.0;
      powerKwh = (prevPower * hours) / 1000.0;
    } else {
      firstReading = false; // Skip kWh for the very first reading
    }

    sendToSupabase(r.power, powerKwh);
    prevPower = r.power;
    prevMillis = nowMillis;

    fetchRelayStatus();
    lastCheck = millis();
  }
} 