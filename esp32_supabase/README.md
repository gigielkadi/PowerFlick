# ESP32 Supabase Connection

This project demonstrates how to connect an ESP32 to a local Supabase database.

## Prerequisites

1. Arduino IDE installed
2. ESP32 board support installed in Arduino IDE
3. Required libraries:
   - WiFi.h (built-in)
   - HTTPClient.h (built-in)
   - ArduinoJson (install from Library Manager)

## Installation

1. Install the required libraries:
   - Open Arduino IDE
   - Go to Tools > Manage Libraries
   - Search for "ArduinoJson" and install it

2. Configure the code:
   - Open `esp32_supabase.ino`
   - Update the WiFi credentials:
     ```cpp
     const char* ssid = "YOUR_WIFI_SSID";
     const char* password = "YOUR_WIFI_PASSWORD";
     ```
   - Update the Supabase configuration:
     ```cpp
     const char* supabaseUrl = "http://YOUR_LOCAL_IP:54321";
     const char* supabaseKey = "YOUR_SUPABASE_ANON_KEY";
     ```
   - Update the table name in the URL:
     ```cpp
     String url = String(supabaseUrl) + "/rest/v1/your_table_name";
     ```

3. Upload the code:
   - Connect your ESP32 to your computer
   - Select the correct board and port in Arduino IDE
   - Click the Upload button

## Usage

1. Open the Serial Monitor (Tools > Serial Monitor)
2. Set the baud rate to 115200
3. The ESP32 will:
   - Connect to WiFi
   - Print its IP address
   - Send data to Supabase every 5 seconds

## Troubleshooting

1. If you can't connect to WiFi:
   - Check your WiFi credentials
   - Ensure the ESP32 is in range of your WiFi network

2. If you can't connect to Supabase:
   - Verify your local Supabase instance is running
   - Check if the ESP32 can reach your computer's IP address
   - Verify the Supabase anon key is correct
   - Check the table name and structure

## Security Notes

- Never commit your WiFi credentials or Supabase keys to version control
- Consider using environment variables or a separate configuration file
- Use HTTPS in production environments 