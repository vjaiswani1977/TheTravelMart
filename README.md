# TravelMart - Aviation Fest 2026
## Flutter iOS App — Version 1.0 (MVP)

A service booking app for Aviation Fest 2026. Users can find and book Tour Guides ($35/hr) and Sitters ($30/hr) directly from their iPhone.

---

## Project Structure

```
lib/
├── main.dart                          ← App entry point
│
├── api/
│   ├── api_constants.dart             ← Odoo URL, database, endpoints
│   └── odoo_service.dart              ← ALL Odoo API calls live here
│
├── data/
│   ├── models/
│   │   ├── contractor.dart            ← Contractor data model
│   │   ├── service_model.dart         ← Service type model (Guide/Sitter)
│   │   └── user_model.dart            ← Logged-in user model
│   └── datasources/
│       ├── contractor_datasource.dart ← DUMMY DATA (swap with Odoo later)
│       └── service_datasource.dart    ← DUMMY DATA (swap with Odoo later)
│
├── screens/
│   ├── login_screen.dart              ← Login with email + API key
│   └── dashboard_screen.dart         ← Main screen with contractor list
│
└── ui/
    ├── theme/
    │   └── app_theme.dart             ← Colors, fonts, theme
    └── widgets/
        └── contractor_card.dart       ← Reusable contractor card UI
```

---

## How to Run

### 1. Install Flutter on Windows
```
https://docs.flutter.dev/get-started/install/windows
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run on a device or emulator
```bash
flutter run
```

---

## Swapping Dummy Data with Real Odoo API

All dummy data is in `lib/data/datasources/`. To connect to your Odoo subscription:

1. Open `lib/api/api_constants.dart`
2. Update `odooBaseUrl` with your Odoo instance URL
3. Update `odooDatabase` with your database name (`srkj`)
4. In `contractor_datasource.dart`, replace the `_dummyContractors` list with:
   ```dart
   return await OdooService.instance.fetchContractors();
   ```
5. In `login_screen.dart`, replace the dummy login with:
   ```dart
   await OdooService.instance.login(email: email, apiKey: apiKey);
   ```

---

## Version 1.0 (This release)
- ✅ Login screen
- ✅ Dashboard with contractor list
- ✅ Filter by Tour Guide / Sitter
- ✅ Search contractors
- ✅ Side drawer with menu
- ✅ Bottom navigation bar
- ✅ Logout

## Version 2.0 (Next release)
- Add to Cart
- Checkout with Odoo sale.order
- Notifications page
- Check-in / Check-out with live timer
- Thank You page with glitter animation
- Real Odoo API integration

---

## Odoo API Details

- **Endpoint:** `https://your-company.odoo.com/json/2/{model}/{method}`
- **Auth:** `Authorization: bearer YOUR_API_KEY`
- **Database:** `X-Odoo-Database: srkj`
- **Tested with:** Postman ✅

---

## App Store Deployment

1. Open this project in Xcode (on Mac or MacStadium)
2. Set Bundle ID: `com.travelmart.contractorservices`
3. Sign with your Apple Developer account
4. Archive → Upload to App Store Connect
5. TestFlight → App Store

---

*Built for Aviation Fest 2026 | Powered by Odoo 18*
