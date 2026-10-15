# 🎨 FoodBridge — Material You (M3) UI Redesign Blueprint
**Reference Video Source:** `gemini_generated_video_81725072.mp4` (in project root)  
**Target Design Standard:** Google Material Design 3 / Material You (Android 15 Flagship Aesthetic)  
**Last Updated:** October 2026

---

## 📌 1. Purpose of This Blueprint
This document serves as the **absolute source of truth** for transforming the entire FoodBridge Flutter mobile application UI. Even if work is paused, resumed tomorrow, or transferred to another session, this file outlines **every color, typography rule, component radius, layout hierarchy, and code file** needed to match the generated reference video with 100% fidelity.

---

## 🎨 2. Master Material You Design Tokens

### 2.1 Dynamic Tonal Color Palette
Material You relies on **tonal container fills** with high-contrast text rather than heavy borders or dark skeuomorphic drop shadows.

| Role / Element | Primary Accent | Container Fill (Background) | Text / Icon Foreground | Visual Role & Feel |
| :--- | :--- | :--- | :--- | :--- |
| **Donor Ecosystem** | `#2E6B4F` (Sage Green) | `#D2E7D6` (Pale Pistachio) | `#1B4332` (Deep Forest) | Organic, wholesome, generous |
| **NGO Shelter Ecosystem** | `#A04E28` (Warm Terracotta)| `#F9DCC4` (Apricot Peach) | `#672D12` (Deep Rust) | Compassionate, human, urgent shelter |
| **Volunteer Courier** | `#2B5B84` (Muted Slate Sky)| `#D0E3EE` (Pale Ice Sky) | `#173752` (Deep Navy) | Calm, rapid, transit-ready |
| **Global Canvas / Surface**| `#FBFDF9` (Ceramic Canvas) | `#F3F5F0` (Surface Container)| `#1A1C19` (Charcoal Black)| Clean, warm, anti-glare off-white |
| **Celebration / Verified** | `#34A853` (Leaf Green) | `#D6F5E3` (Mint Rosette) | `#0D652D` (Forest Green)| Achievement, impact, trust |
| **Subtle Neutral Outlines**| N/A | `#E1E4DD` (4% border tint)| `#5D635C` (Muted secondary) | Dashed inspection boxes |

### 2.2 Geometry & Corner Radii
* **Large Hero Cards / Containers:** `28dp` squircle rounded corners (`BorderRadius.circular(28)`).
* **Modal Sheets & Drawers:** `28dp` top-left & top-right corners (`BorderRadius.vertical(top: Radius.circular(28))`).
* **Input Boxes & OTP Digit Containers:** `16dp` to `20dp` rounded rectangles.
* **Filter Chips & Interactive Pills:** Full pill radius (`BorderRadius.circular(50)` or `height / 2`).
* **Primary Action Buttons:** Full pill shape (`BorderRadius.circular(50)`), height `56dp`.

### 2.3 Typography Scale (Google Sans / Product Sans Aesthetic)
* **Screen Display Title:** `26sp`–`28sp`, FontWeight: `700` (Bold), Letter spacing: `-0.5px`.
* **Card & Section Titles:** `18sp`–`20sp`, FontWeight: `600` (Semi-bold).
* **Body / Subtitles:** `14sp`–`15sp`, FontWeight: `400`–`500`, Color: `#5D635C` (Muted Charcoal).
* **Pill & Button Labels:** `14sp`–`15sp`, FontWeight: `600` (Semi-bold), Letter spacing: `0.1px`.
* **OTP Digit Box Characters:** `28sp`–`32sp`, FontWeight: `700`, Color: `#173752`.

### 2.4 Shadows & Elevation
* **Strict Rule:** **Zero harsh drop shadows**. 
* Use subtle diffuse ambient occlusion:
  ```dart
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ]
  ```

---

## 📱 3. Detailed Screen-by-Screen Breakdown (From Video)

###  screen 1: Dynamic Role Hub
* **File Target:** `lib/features/auth/role_selection_screen.dart`
* **Video Timestamp:** `00:00 - 00:02`
* **Header:**
  * Top bar: "FoodBridge" logo on left in bold Google Sans. Right: User profile avatar and settings gear.
  * Subtitle text: *"Dynamic Role Hub"* in medium typography.
* **3 Hero Stacked Cards (Each 28dp Squircle):**
  1. **Top Card — Donor:**
     - Height: ~140dp.
     - Background: `#D2E7D6` (Pale Pistachio).
     - Left: Steaming meal bowl icon (`Icons.soup_kitchen_rounded` or `LucideIcons.soup`) in dark sage container.
     - Center text: Title: **"Donor"**, Subtitle: *"I have surplus food from a kitchen, hotel, or household."*
     - Right: Subtle botanical curved wave art in slightly deeper green tint.
  2. **Middle Card — NGO Shelter:**
     - Height: ~140dp.
     - Background: `#F9DCC4` (Warm Apricot).
     - Left: Shelter house icon (`Icons.home_work_rounded` or `LucideIcons.building2`).
     - Center text: Title: **"NGO Shelter"**, Subtitle: *"I represent a verified community hunger relief center."*
     - Right: Subtle curved contour background motif.
  3. **Bottom Card — Volunteer Courier:**
     - Height: ~140dp.
     - Background: `#D0E3EE` (Pale Ice Sky).
     - Left: Delivery cargo bicycle icon (`Icons.pedal_bike_rounded` or `LucideIcons.bike`).
     - Center text: Title: **"Volunteer Courier"**, Subtitle: *"I transport surplus meals from donors to shelters."*
     - Right: Abstract dynamic motion wave motif.
* **Interaction:** Tapping any card produces a smooth translucent white ink ripple (`InkWell`), followed by a fluid `ContainerTransform` transitioning into that role's home view.

---

### screen 2: Donor Surplus Food Creation Wizard
* **File Target:** `lib/features/donor/create_donation_screen.dart`
* **Video Timestamp:** `00:03 - 00:04`
* **Top Stepper Bar:**
  * Clean 3-step pill stepper:
    - Step 1: Active circle filled with warm terracotta (`#A04E28`), numeral "1".
    - Track line: Soft grey connecting track to Step 2 & 3.
* **Dual Inspection & Details Row:**
  * **Left Box: "AI Freshness Inspection"**
    - Square squircle card with **dashed border** (`borderStyle: dashed` or custom painter).
    - Background: Light pale mint (`#EBF5EE`).
    - Centered icon: Minimalist camera glyph + green dot.
    - Label below: *"AI Freshness Inspection"*.
  * **Right Box: Food Item Details**
    - Background: Solid pale pistachio squircle (`#DCEFDE`).
    - Top left: Small green verified checkmark badge (`✔`).
    - Title: *"Fresh Paneer Pulao & Dal Tadka"*.
    - Bottom pill: Small editable pencil chip with quantity/details.
* **Category & Dietary Filter Chips:**
  * Section label: *"Category"*.
  * Horizontal row of pill chips:
    - Chip 1 (Selected): *"Cooked Meals"* in soft sage container.
    - Chip 2 (Dietary): *"100% Vegetarian"* with green leaf icon badge.
* **CTA Button:**
  * Bottom floating pill: `[ Continue / Broadcast Food Rescue ]` in filled primary sage green (`#2E6B4F`).

---

### screen 3: NGO Shelter Dispatch Radar
* **File Target:** `lib/features/ngo/ngo_home_screen.dart`
* **Video Timestamp:** `00:05`
* **Header:**
  * Back arrow (`←`), Title: *"NGO Shelter Dispatch Radar"*.
* **Incoming Surplus Alert Card:**
  * Background: Warm apricot squircle container (`#FCEADE`), `28dp` radius.
  * Top left badge: Steaming food bowl inside a circular badge.
  * Headline: *"Incoming Surplus: 45 Meals · 1.8 km away"*.
  * Sub-info: Preparation time, shelf life countdown.
  * **Dual Action Buttons inside card:**
    - `[ Decline ]`: Tonal off-white rounded pill button.
    - `[ Claim & Request Rider ]`: Filled terracotta pill button (`#A04E28`), white text, bold font.
  * Carousel pagination dots below card.
* **Live Matching Radar Graphic:**
  * Positioned beneath the card:
  * Animated concentric circular rings in warm terracotta tones (`#F5D0C0` to `#E07A5F`) pulsing outwards from center.
  * Compass/lightning icon at perimeter representing real-time algorithmic courier matching.

---

### screen 4: Courier Live Navigation & 2-Step OTP Handshake
* **File Target:** `lib/features/rider/active_delivery_screen.dart`
* **Video Timestamp:** `00:06 - 00:08`
* **Upper Viewport — Pastel Vector Map:**
  * Minimalist Google Maps / OSM pastel aesthetic.
  * Destination Shelter Pin (Soft red marker).
  * Courier GPS Marker (Pulsing orange circular ring labeled *"Volunteer Rider"*).
  * Animated dashed green polyline route with bicycle icon traveling along path.
* **Lower Viewport — Sliding 2-Step OTP Drawer:**
  * Bottom sheet sliding up with `28dp` rounded top corners and soft grey grab handle.
  * Headline: *"Donor Pickup OTP"*.
  * **4 Large Digit Containers:**
    - Four side-by-side squircle boxes: `[ 0 ]  [ 4 ]  [ 3 ]  [ 4 ]`.
    - Box dimensions: ~`64dp` width, `72dp` height, `18dp` corner radius.
    - Box fill: Light pale blue (`#E3EEF7`).
    - Digits: Large, bold, slate blue (`#173752`), `28sp` font size.
  * **2-Step Progress Indicator:**
    - Horizontal slider bar with indicator dot.
    - Subtitle: *"2-Step OTP Handshake — Step 1 of 2: Donor Verification"*.
  * **Primary Action Pill:**
    - Full-width pill button: `[ Verify & In Transit ]`.

---

### screen 5: Celebratory Delivery Complete Modal
* **File Target:** `lib/features/rider/active_delivery_screen.dart` (Completion BottomSheet)
* **Video Timestamp:** `00:09`
* **Hero Rosette Badge:**
  * Large scalloped star / rosette badge in pastel mint (`#D6F5E3`).
  * Centered crisp green checkmark (`✔`), `36dp` icon.
* **Impact Typography:**
  * Title: **"Delivery Complete!"** in Google Sans Bold (`26sp`).
  * Subtitle: **"50 Meals Rescued"** in Title Medium (`18sp`, `#2E6B4F`).
* **3 Horizontal Metric Squircle Cards:**
  1. **Card 1 (Food Saved):** `56.75 kg` with hand holding food bowl icon.
  2. **Card 2 (CO2 Prevented):** `4.086 kg` with green leaf icon.
  3. **Card 3 (Karma Points):** `317 pts` with heart icon.
* **Bottom Action Pill:**
  * Full-width pill button: `[ Return to Dispatch Hub ]`.

---

## 🛠️ 4. Code Implementation Roadmap & File Mapping

When starting the implementation, follow this exact sequence:

```
┌─────────────────────────────────────────────────────────┐
│ Step 1: Design Tokens & Colors                         │
│ File: lib/core/theme/app_colors.dart                   │
│ Add M3 dynamic pastel tokens (Sage, Terracotta, Slate) │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│ Step 2: Global Material 3 Theme                        │
│ File: lib/core/theme/app_theme.dart                    │
│ Update CardTheme (28dp squircle), ButtonTheme (Pills)   │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│ Step 3: Screen 1 — Dynamic Role Hub                    │
│ File: lib/features/auth/role_selection_screen.dart     │
│ Build 3 large squircle cards with ripples & navigation  │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│ Step 4: Screen 2 — Donor Surplus Creation Wizard       │
│ File: lib/features/donor/create_donation_screen.dart   │
│ Dual AI inspection + food card, pill category chips     │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│ Step 5: Screen 3 — NGO Dispatch Radar                  │
│ File: lib/features/ngo/ngo_home_screen.dart            │
│ Incoming alert card + animated concentric pulse radar   │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│ Step 6: Screen 4 & 5 — Courier OTP Drawer & Rosette    │
│ File: lib/features/rider/active_delivery_screen.dart   │
│ 4-box OTP input drawer + mint rosette celebration sheet│
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 5. Verification Protocol (Post-Implementation)
Once code updates are applied, test on the Android Emulator (`emulator-5554`):
1. **Role Hub:** Inspect 3 stacked cards, check colors (Sage, Terracotta, Slate Sky), verify `28dp` corners.
2. **Donor Wizard:** Verify dashed "AI Freshness Inspection" box, check pill chips.
3. **NGO Radar:** Verify incoming dispatch card and pulsing concentric circles.
4. **Courier OTP Drawer:** Open delivery, verify the 4 large digit boxes `[ 0 ] [ 4 ] [ 3 ] [ 4 ]`.
5. **Celebration Sheet:** Trigger completion, verify mint rosette star badge and the 3 impact metric cards.

---

*This blueprint is permanently saved in the project directory for continuous development.*
