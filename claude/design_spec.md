# Design Export: Vehicle System (Blueprint Edition)

This document contains the complete UI design for a Vehicle Control App tailored for the Colombian market, following the **Engineering Blueprint Schematic** design system.

## 🎨 Design System: Engineering Blueprint Schematic

**Theme:** Dark, Technical, Precision-Engineered
- **Background:** `#0b1623` (Deep Navy) with a `#1c2b3a` grid overlay.
- **Typography:** JetBrains Mono (Monospace) for all UI elements.
- **Primary Accent:** `#ff9f30` (Orange) for CTAs and highlights.
- **Status Colors:** `#00ff9d` (Success), `#ff9f30` (Warning/Alert).
- **Shapes:** Sharp 0px corners, industrial borders.

---

## 📱 Screens Overview

### 1. Dashboard Principal (Home)
- **ID:** {{DATA:SCREEN:SCREEN_12}}
- **Purpose:** Central command for the driver.
- **Key Features:** Vehicle selector, odometer quick-update, "Pico y Placa" today indicator, and legalized status (SOAT/RTM) traffic light system.

### 2. Tanqueos y Consumo (Metrics)
- **ID:** {{DATA:SCREEN:SCREEN_11}}
- **Purpose:** Monitor fuel efficiency and costs.
- **Key Features:** Performance curve (Km/Gal), KPI cards (Cost/Km), and recent fueling history with "Full Tank" badges.

### 3. Garaje Legal (Documents)
- **ID:** {{DATA:SCREEN:SCREEN_10}}
- **Purpose:** Legal compliance management.
- **Key Features:** Tabs for Vehicle/Taxes/Driver, PDF preview buttons, and countdown timers for document expiration.

### 4. Mantenimientos y Taller (Status)
- **ID:** {{DATA:SCREEN:SCREEN_9}}
- **Purpose:** Preventive maintenance tracking.
- **Key Features:** Component lifespan bars (Oil, Tires, Brakes), and service history segmented by Preventive/Corrective.

### 5. Acciones Rápidas (Quick Actions)
- **ID:** {{DATA:SCREEN:SCREEN_8}}
- **Purpose:** Speed-dial for logging data.
- **Key Features:** Floating action menu to trigger Refuel, Maintenance, or Document registration flows.

### 6. Registrar Tanqueo (Form)
- **ID:** {{DATA:SCREEN:SCREEN_7}}
- **Purpose:** Data entry for fueling events.
- **Key Features:** Odometer, Volume (Gal), and Cost (COP) inputs with a "Full Tank" toggle.

### 7. Registrar Documento (Upload)
- **ID:** {{DATA:SCREEN:SCREEN_6}}
- **Purpose:** Digitalizing physical records.
- **Key Features:** Document type selector, date pickers, and a technical PDF/Image upload zone.

### 8. Registrar Mantenimiento (Log)
- **ID:** {{DATA:SCREEN:SCREEN_5}}
- **Purpose:** Documenting workshop visits.
- **Key Features:** Service station ID, spare parts detail area, and total value input.

### 9. Agregar Vehículo (Onboarding)
- **ID:** {{DATA:SCREEN:SCREEN_3}}
- **Purpose:** Initial system setup.
- **Key Features:** License plate, Brand/Model, and Year inputs, combined with an OCR-powered document scanner simulation.

---

## 🧱 Shared Components (JSON)

### Top Navigation Bar
```json
{"name": "TopAppBar", "type": "small", "headline": "VEHICLE_SYSTEM_V1.0", "leading_type": "avatar", "leading_avatar": "user_profile_technical_draft", "trailing_type": "icon", "trailing_icon": "settings", "style_bg_color": "bg-background dark:bg-background", "style_primary_color": "text-primary dark:text-primary", "style_typography": "font-h2 text-h2", "style_brand_logo": "font-h1 text-h1 text-primary tracking-tighter", "style_component_shape": "fixed top-0 w-full z-50", "style_separation_logic": "border-b border-outline-variant"}
```

### Bottom Navigation Bar
```json
{"name": "BottomNavBar", "type": "label_icon", "destination_count": "5", "label_texts": ["Inicio", "Gasolina", "Acciones", "Legal", "Taller"], "icons": ["dashboard", "local_gas_station", "build_circle", "gavel", "home_repair_service"], "style_bg_color": "bg-surface-container-low dark:bg-surface-container-low", "style_primary_color": "text-primary dark:text-primary", "style_typography": "font-label text-label", "style_brand_logo": "font-h2 text-h2 text-primary", "style_component_shape": "fixed bottom-0 w-full z-50", "style_separation_logic": "border-t border-outline-variant"}
```