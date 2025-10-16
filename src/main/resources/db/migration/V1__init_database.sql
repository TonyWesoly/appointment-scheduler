-- ======== Function and types ========
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE appointment_status AS ENUM (
    'SCHEDULED', 'COMPLETED', 'CANCELLED_BY_CLIENT', 'CANCELLED_BY_SPECIALIST', 'NO_SHOW'
);

CREATE TYPE days_of_week AS ENUM (
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
);

-- ======== Main Tables ========
CREATE TABLE users
(
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER set_timestamp BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TABLE institutions
(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE roles
(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE languages
(
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE, -- np. 'pl', 'en-US'
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE service_categories
(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE services
(
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES service_categories (id)
);

-- ======== Specialists and Users Tables ========
CREATE TABLE user_roles
(
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE specialist_profiles
(
    specialist_id BIGINT PRIMARY KEY,
    bio TEXT,
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE specialist_institutions
(
    specialist_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions (id) ON DELETE CASCADE,
    PRIMARY KEY (specialist_id, institution_id)
);

CREATE TABLE specialist_languages
(
    specialist_id BIGINT NOT NULL,
    language_id BIGINT NOT NULL,
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages (id) ON DELETE CASCADE,
    PRIMARY KEY (specialist_id, language_id)
);

CREATE TABLE specialist_services
(
    id BIGSERIAL PRIMARY KEY,
    specialist_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    duration_minutes INTERVAL NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
    UNIQUE (specialist_id, service_id)
);

-- ======== Appointments Tables ========
CREATE TABLE availabilities
(
    id BIGSERIAL PRIMARY KEY,
    specialist_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    day_of_week days_of_week NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions (id) ON DELETE CASCADE,
    CONSTRAINT end_time_after_start_time CHECK (end_time > start_time)
);

CREATE TABLE time_offs
(
    id BIGSERIAL PRIMARY KEY,
    specialist_id BIGINT NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    reason TEXT,
    FOREIGN KEY (specialist_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT end_datetime_after_start_datetime CHECK (end_datetime > start_datetime)
);

CREATE TABLE appointments
(
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    specialist_id BIGINT NOT NULL,
    specialist_service_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status appointment_status NOT NULL DEFAULT 'SCHEDULED',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (client_id) REFERENCES users (id),
    FOREIGN KEY (specialist_id) REFERENCES users (id),
    FOREIGN KEY (specialist_service_id) REFERENCES specialist_services (id),
    FOREIGN KEY (institution_id) REFERENCES institutions (id),
    CONSTRAINT end_time_after_start_time CHECK (end_time > start_time)
);
CREATE TRIGGER set_timestamp BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();


-- ======== Performance indexes ========
CREATE INDEX idx_appointments_client_id ON appointments(client_id);
CREATE INDEX idx_appointments_specialist_id ON appointments(specialist_id);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_availabilities_specialist_id_institution_id ON availabilities(specialist_id, institution_id);
CREATE INDEX idx_services_category_id ON services(category_id);
CREATE INDEX idx_specialist_services_specialist_id ON specialist_services(specialist_id);
CREATE INDEX idx_time_offs_specialist_id ON time_offs(specialist_id);
