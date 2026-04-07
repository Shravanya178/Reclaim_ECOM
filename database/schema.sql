-- ReClaim Database Schema
-- Supabase PostgreSQL Implementation

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Custom ENUM types
CREATE TYPE user_role AS ENUM ('student', 'lab', 'admin');
CREATE TYPE material_status AS ENUM ('detected', 'listed', 'matched', 'picked_up', 'in_use', 'completed');
CREATE TYPE material_condition AS ENUM ('good', 'used', 'scrap');
CREATE TYPE opportunity_status AS ENUM ('generated', 'confirmed', 'rejected', 'modified');
CREATE TYPE request_status AS ENUM ('open', 'partially_matched', 'fulfilled', 'expired');
CREATE TYPE requirement_status AS ENUM ('open', 'matched', 'completed');
CREATE TYPE application_status AS ENUM ('pending', 'approved', 'rejected');

-- Users & Authentication (extends Supabase auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR UNIQUE NOT NULL,
    role user_role NOT NULL,
    campus_id UUID,
    department_id UUID,
    full_name VARCHAR,
    phone VARCHAR,
    profile_image_url VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campus & Departments
CREATE TABLE campuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    address TEXT,
    location POINT,
    zones JSONB DEFAULT '[]',
    contact_info JSONB,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    campus_id UUID REFERENCES campuses(id) ON DELETE CASCADE,
    description TEXT,
    contact_email VARCHAR,
    lab_spaces JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Profiles
CREATE TABLE student_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    skills TEXT[] DEFAULT '{}',
    domains TEXT[] DEFAULT '{}',
    availability_hours INTEGER DEFAULT 0,
    project_interests TEXT,
    past_projects JSONB DEFAULT '[]',
    match_preferences JSONB DEFAULT '{}',
    bio TEXT,
    year_of_study INTEGER,
    major VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Lab Profiles
CREATE TABLE lab_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    lab_name VARCHAR,
    specializations TEXT[] DEFAULT '{}',
    equipment_list JSONB DEFAULT '[]',
    safety_protocols JSONB DEFAULT '{}',
    operating_hours JSONB DEFAULT '{}',
    capacity_info JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Materials & Detection
CREATE TABLE material_lots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lab_user_id UUID REFERENCES users(id),
    batch_name VARCHAR,
    images TEXT[] DEFAULT '{}',
    detected_materials JSONB DEFAULT '[]',
    location VARCHAR,
    campus_zone VARCHAR,
    status material_status DEFAULT 'detected',
    confidence_scores JSONB DEFAULT '{}',
    notes TEXT,
    pickup_instructions TEXT,
    safety_notes TEXT,
    estimated_value DECIMAL(10,2),
    expiry_date DATE,
    is_hazardous BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE detected_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lot_id UUID REFERENCES material_lots(id) ON DELETE CASCADE,
    material_type VARCHAR NOT NULL,
    category VARCHAR,
    subcategory VARCHAR,
    quantity INTEGER DEFAULT 1,
    unit VARCHAR DEFAULT 'pieces',
    condition material_condition DEFAULT 'good',
    bounding_box JSONB,
    confidence_score DECIMAL(3,2),
    carbon_factor DECIMAL(10,4),
    dimensions JSONB,
    weight DECIMAL(10,2),
    color VARCHAR,
    brand VARCHAR,
    model VARCHAR,
    specifications JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Opportunities & Matching
CREATE TABLE opportunities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_lot_id UUID REFERENCES material_lots(id) ON DELETE CASCADE,
    suggested_projects JSONB DEFAULT '[]',
    matched_student_id UUID REFERENCES users(id),
    match_percentage INTEGER,
    carbon_impact DECIMAL(10,2),
    logistics_notes TEXT,
    status opportunity_status DEFAULT 'generated',
    priority_score INTEGER DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE,
    requirements JSONB DEFAULT '{}',
    estimated_completion_days INTEGER,
    difficulty_level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Requests
CREATE TABLE material_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    material_type VARCHAR NOT NULL,
    category VARCHAR,
    quantity_needed INTEGER DEFAULT 1,
    unit VARCHAR DEFAULT 'pieces',
    deadline DATE,
    intended_project TEXT,
    project_description TEXT,
    urgency INTEGER DEFAULT 1,
    budget_range JSONB,
    preferred_condition material_condition,
    specifications JSONB DEFAULT '{}',
    status request_status DEFAULT 'open',
    progress_data JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Request-Opportunity Matching
CREATE TABLE request_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID REFERENCES material_requests(id) ON DELETE CASCADE,
    opportunity_id UUID REFERENCES opportunities(id) ON DELETE CASCADE,
    match_score DECIMAL(3,2),
    auto_matched BOOLEAN DEFAULT false,
    student_confirmed BOOLEAN DEFAULT false,
    lab_confirmed BOOLEAN DEFAULT false,
    matched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(request_id, opportunity_id)
);

-- Barter System
CREATE TABLE skill_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lab_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR NOT NULL,
    required_skills TEXT[] NOT NULL DEFAULT '{}',
    project_description TEXT,
    detailed_requirements TEXT,
    material_access JSONB DEFAULT '{}',
    time_commitment INTEGER, -- hours
    deadline DATE,
    compensation_type VARCHAR, -- 'materials', 'experience', 'certificate'
    status requirement_status DEFAULT 'open',
    max_applicants INTEGER DEFAULT 1,
    difficulty_level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE barter_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requirement_id UUID REFERENCES skill_requirements(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    application_data JSONB NOT NULL DEFAULT '{}',
    cover_letter TEXT,
    portfolio_links TEXT[] DEFAULT '{}',
    availability JSONB,
    status application_status DEFAULT 'pending',
    rating INTEGER,
    feedback TEXT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(requirement_id, student_id)
);

-- Lifecycle Tracking
CREATE TABLE lifecycle_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_lot_id UUID REFERENCES material_lots(id) ON DELETE CASCADE,
    event_type VARCHAR NOT NULL,
    event_subtype VARCHAR,
    description TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    photo_url VARCHAR,
    metadata JSONB DEFAULT '{}',
    user_id UUID REFERENCES users(id),
    location VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR NOT NULL,
    title VARCHAR NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    read BOOLEAN DEFAULT false,
    action_url VARCHAR,
    priority INTEGER DEFAULT 1,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE
);

-- Impact Tracking
CREATE TABLE impact_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    campus_id UUID REFERENCES campuses(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    co2_saved DECIMAL(10,2) DEFAULT 0,
    materials_diverted DECIMAL(10,2) DEFAULT 0,
    materials_count INTEGER DEFAULT 0,
    projects_enabled INTEGER DEFAULT 0,
    students_helped INTEGER DEFAULT 0,
    labs_participated INTEGER DEFAULT 0,
    waste_prevented DECIMAL(10,2) DEFAULT 0,
    cost_savings DECIMAL(10,2) DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material Categories (Static Reference Data)
CREATE TABLE material_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL UNIQUE,
    parent_id UUID REFERENCES material_categories(id),
    description TEXT,
    carbon_factor DECIMAL(10,4) DEFAULT 0,
    typical_projects TEXT[] DEFAULT '{}',
    safety_level INTEGER DEFAULT 1,
    icon_url VARCHAR,
    color VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Sessions & Activity
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_info JSONB,
    location_data JSONB,
    session_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    session_end TIMESTAMP WITH TIME ZONE,
    activity_summary JSONB DEFAULT '{}'
);

-- Feedback & Ratings
CREATE TABLE feedback_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    opportunity_id UUID REFERENCES opportunities(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    categories JSONB DEFAULT '{}', -- communication, quality, timeliness
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add foreign key constraints
ALTER TABLE users ADD CONSTRAINT fk_users_campus FOREIGN KEY (campus_id) REFERENCES campuses(id);
ALTER TABLE users ADD CONSTRAINT fk_users_department FOREIGN KEY (department_id) REFERENCES departments(id);

-- Create indexes for better performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_campus ON users(campus_id);
CREATE INDEX idx_material_lots_status ON material_lots(status);
CREATE INDEX idx_material_lots_lab_user ON material_lots(lab_user_id);
CREATE INDEX idx_detected_materials_type ON detected_materials(material_type);
CREATE INDEX idx_opportunities_status ON opportunities(status);
CREATE INDEX idx_opportunities_student ON opportunities(matched_student_id);
CREATE INDEX idx_material_requests_student ON material_requests(student_id);
CREATE INDEX idx_material_requests_status ON material_requests(status);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read);
CREATE INDEX idx_lifecycle_events_lot ON lifecycle_events(material_lot_id);
CREATE INDEX idx_impact_metrics_period ON impact_metrics(period_start, period_end);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_campuses_updated_at BEFORE UPDATE ON campuses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_student_profiles_updated_at BEFORE UPDATE ON student_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_lab_profiles_updated_at BEFORE UPDATE ON lab_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_material_lots_updated_at BEFORE UPDATE ON material_lots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_opportunities_updated_at BEFORE UPDATE ON opportunities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_material_requests_updated_at BEFORE UPDATE ON material_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_skill_requirements_updated_at BEFORE UPDATE ON skill_requirements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_impact_metrics_updated_at BEFORE UPDATE ON impact_metrics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default material categories
INSERT INTO material_categories (name, description, carbon_factor, typical_projects) VALUES
('Electronics', 'Electronic components and devices', 0.0234, ARRAY['Robotics', 'IoT Projects', 'Circuit Design']),
('PCB', 'Printed Circuit Boards', 0.0156, ARRAY['Electronics Projects', 'Prototyping']),
('Acrylic', 'Acrylic sheets and components', 0.0089, ARRAY['Laser Cutting', 'Displays', 'Enclosures']),
('Aluminum', 'Aluminum rods, sheets, and components', 0.0445, ARRAY['Mechanical Projects', 'Frames', 'CNC Work']),
('Steel', 'Steel components and raw materials', 0.0234, ARRAY['Heavy Machinery', 'Structural Work']),
('Plastic', 'Various plastic materials', 0.0123, ARRAY['3D Printing', 'Molding', 'Prototyping']),
('Wood', 'Wooden materials and components', 0.0067, ARRAY['Furniture', 'Construction', 'Art Projects']),
('Sensors', 'Various sensor components', 0.0178, ARRAY['IoT', 'Automation', 'Data Collection']),
('Motors', 'Electric motors and actuators', 0.0289, ARRAY['Robotics', 'Automation', 'Mechanical Systems']),
('Cables', 'Electrical cables and wiring', 0.0034, ARRAY['Wiring', 'Electronics', 'Infrastructure']);