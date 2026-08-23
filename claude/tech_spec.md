# 🛠️ Especificación Técnica y Arquitectura - App Control Vehicular (Colombia)

## 📌 Contexto y Stack Tecnológico
Construir una aplicación móvil cross-platform usando únicamente la capa **GRATUITA (Free Tier)** de los servicios seleccionados:
* **Frontend:** Flutter (Mobile Android / iOS).
* **State Management:** `flutter_riverpod`.
* **Backend & DB:** Supabase (PostgreSQL, Storage, Auth).
* **Alertas:** `flutter_local_notifications` (Push locales a costo $0).

---

## 🗄️ Modelo de Datos (PostgreSQL en Supabase)

Ejecutar el siguiente script SQL para crear la estructura relacional y configurar Row Level Security (RLS):

```sql
-- Usuarios
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(150),
    city_code VARCHAR(10) DEFAULT 'BOG',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Vehículos
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_plate VARCHAR(10) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    fuel_type VARCHAR(20) CHECK (fuel_type IN ('GASOLINA_CORRIENTE', 'GASOLINA_EXTRA', 'DIESEL', 'HIBRIDO', 'ELECTRICO', 'GAS')),
    current_odometer INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Documentos Legales
CREATE TABLE legal_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    document_type VARCHAR(30) CHECK (document_type IN ('SOAT', 'RTM', 'IMPUESTO_VEHICULAR', 'POLIZA_TODO_RIESGO', 'LICENCIA_CONDUCCION', 'EXTINTOR')),
    issue_date DATE,
    expiration_date DATE NOT NULL,
    cost DECIMAL(12,2),
    entity_name VARCHAR(100),
    document_url TEXT,
    notes TEXT
);

-- Registros de Combustible
CREATE TABLE fuel_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    odometer INT NOT NULL,
    gallons DECIMAL(6,3) NOT NULL,
    price_per_gallon DECIMAL(10,2),
    total_cost DECIMAL(12,2) NOT NULL,
    is_full_tank BOOLEAN DEFAULT TRUE,
    station_name VARCHAR(100)
);

-- Mantenimientos
CREATE TABLE maintenances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    service_type VARCHAR(20) CHECK (service_type IN ('PREVENTIVO', 'CORRECTIVO')),
    category VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    odometer INT NOT NULL,
    total_cost DECIMAL(12,2) NOT NULL,
    workshop_name VARCHAR(100),
    invoice_url TEXT,
    notes TEXT
);