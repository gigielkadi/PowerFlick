# Energy Calculation and Storage Process

This document explains how real-time power (watts) and total energy (kWh) are calculated and stored in the system, from the ESP device to the app UI.

---

## 1. ESP Device Sends Data
- The ESP device measures the **current power usage** (in watts) and sends a reading to the backend (Supabase) at regular intervals (e.g., every minute).
- Each reading includes:
  - `device_id`
  - `power_watts`
  - `timestamp` (when the reading was taken)

---

## 2. Storing the Reading
- The backend (or app) receives the new reading and inserts it into the `power_readings` table.
- At this point, only `power_watts` and `timestamp` are known.

---

## 3. Calculating `power_kwh` (Energy Used in the Interval)
**This is the key step!**
- **Before inserting the new reading:**
  1. **Fetch the previous reading** for the same device (get its `power_watts` and `timestamp`).
  2. **Calculate the time difference** between the previous and current reading (in hours).
  3. **Calculate the energy used in that interval:**
     ```
     power_kwh = (previous power_watts × time difference in hours) / 1000
     ```
  4. **Insert the new reading** into `power_readings`, including the calculated `power_kwh` value.
- **This calculation is done in your backend/app code, NOT in the ESP or the database trigger.**

---

## 4. Database Trigger Sums Up kWh
- There is a trigger on the `power_readings` table.
- When a new row is inserted (with `power_kwh`), the trigger adds this value to the device's `total_power` in the `devices` table.

---

## 5. Displaying in the App
- **Real-time power (W):**
  - Show the latest `power_watts` value for each device (from the most recent reading).
- **Total energy (kWh):**
  - Show the `total_power` value from the `devices` table (which is the sum of all `power_kwh` for that device).

---

## Where Each Value Is Updated

| Value         | How/Where is it updated?                                                                 |
|---------------|-----------------------------------------------------------------------------------------|
| `power_watts` | Sent by ESP, stored directly in `power_readings` by your backend/app.                   |
| `power_kwh`   | **Calculated in your backend/app** (using previous reading), then stored in `power_readings`. |
| `total_power` | **Automatically updated by a database trigger** whenever a new `power_kwh` is inserted. |

---

## Visual Flow

```
ESP (sends power_watts) 
      ↓
Backend/App (fetches previous reading, calculates power_kwh, inserts new row with both)
      ↓
Supabase DB (trigger adds power_kwh to devices.total_power)
      ↓
App UI (shows latest power_watts and total_power)
```

---

## Summary
- **ESP:** Only sends `power_watts`.
- **Backend/App:** Calculates `power_kwh` using previous reading and time difference, inserts both into `power_readings`.
- **Database Trigger:** Sums `power_kwh` into `devices.total_power`.
- **App UI:** Displays real-time `power_watts` and total `kWh` (from `total_power`). 