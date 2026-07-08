-- Script de setup para la base de datos de ayudalocal_app
-- Ejecutar: psql -U postgres -f server/setup.sql

-- Crear la base de datos (ignorar error si ya existe)
SELECT 'CREATE DATABASE ayudalocal_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ayudalocal_db')\gexec

-- Conectar a la base de datos
\c ayudalocal_db

-- Crear la tabla de servicios
CREATE TABLE IF NOT EXISTS servicios (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(255) NOT NULL,
    descripcion_servicio TEXT NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente'
);

-- Datos de ejemplo (opcional)
INSERT INTO servicios (cliente, descripcion_servicio, precio, estado) VALUES
    ('Juan Perez', 'Reparacion de tuberia', 150.00, 'Completado'),
    ('Maria Lopez', 'Instalacion electrica', 320.00, 'En progreso'),
    ('Carlos Garcia', 'Pintura de pared', 200.00, 'Pendiente')
ON CONFLICT DO NOTHING;

SELECT 'Base de datos configurada correctamente!' AS resultado;
