-- KHADAMATY Egypt Maintenance Platform - PostgreSQL Schema
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'customer', -- customer, technician, admin
    city VARCHAR(60) DEFAULT 'القاهرة',
    wallet_balance NUMERIC(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE technicians (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(80) NOT NULL,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_online BOOLEAN DEFAULT TRUE,
    rating NUMERIC(3,2) DEFAULT 4.90,
    completed_jobs INT DEFAULT 0,
    lat NUMERIC(9,6) DEFAULT 30.0444,
    lng NUMERIC(9,6) DEFAULT 31.2357
);

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    base_price NUMERIC(10,2) NOT NULL,
    max_price NUMERIC(10,2) NOT NULL,
    warranty_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    id VARCHAR(30) PRIMARY KEY,
    customer_id INT REFERENCES users(id),
    technician_id INT REFERENCES technicians(id),
    service_id INT REFERENCES services(id),
    description TEXT NOT NULL,
    photos_urls TEXT[],
    city VARCHAR(60) NOT NULL,
    address TEXT NOT NULL,
    lat NUMERIC(9,6),
    lng NUMERIC(9,6),
    scheduled_at VARCHAR(80) NOT NULL,
    assignment_mode VARCHAR(30) DEFAULT 'auto_nearest', -- auto_nearest, manual
    status VARCHAR(30) DEFAULT 'جديد', -- جديد, مقبول, في الطريق, قيد التنفيذ, مكتمل
    pin_code VARCHAR(6) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(30) REFERENCES orders(id),
    method VARCHAR(40) NOT NULL, -- cash, paymob_card, fawry
    amount NUMERIC(10,2) NOT NULL,
    platform_fee NUMERIC(10,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'paid',
    transaction_ref VARCHAR(100),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(30) REFERENCES orders(id),
    customer_id INT REFERENCES users(id),
    technician_id INT REFERENCES technicians(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);