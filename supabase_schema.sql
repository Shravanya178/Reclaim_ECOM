-- ReClaim Supabase Database Schema
-- Run this in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================= PROFILES TABLE =================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  department TEXT,
  campus_id UUID REFERENCES campuses(id),
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'lab', 'admin')),
  skills TEXT[] DEFAULT '{}',
  interests TEXT[] DEFAULT '{}',
  availability TEXT DEFAULT 'part-time',
  co2_saved DECIMAL(10, 2) DEFAULT 0,
  materials_reused INTEGER DEFAULT 0,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ================= CAMPUSES TABLE =================
CREATE TABLE IF NOT EXISTS campuses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  location TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on campuses
ALTER TABLE campuses ENABLE ROW LEVEL SECURITY;

-- Campuses policies (public read)
CREATE POLICY "Anyone can view campuses" ON campuses FOR SELECT USING (true);

-- Insert sample campuses
INSERT INTO campuses (name, location) VALUES
  ('VESIT - Vivekanand Education Society Institute of Technology', 'Chembur, Mumbai, Maharashtra'),
  ('IIT Bombay', 'Powai, Mumbai, Maharashtra'),
  ('VJTI - Veermata Jijabai Technological Institute', 'Matunga, Mumbai, Maharashtra'),
  ('SPIT - Sardar Patel Institute of Technology', 'Andheri, Mumbai, Maharashtra'),
  ('DJ Sanghvi College of Engineering', 'Vile Parle, Mumbai, Maharashtra'),
  ('KJ Somaiya College of Engineering', 'Vidyavihar, Mumbai, Maharashtra');

-- ================= DEPARTMENTS TABLE =================
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  campus_id UUID REFERENCES campuses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on departments
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

-- Departments policies (public read)
CREATE POLICY "Anyone can view departments" ON departments FOR SELECT USING (true);

-- ================= MATERIALS TABLE =================
CREATE TABLE IF NOT EXISTS materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Electronic', 'Metal', 'Plastic', 'Glass', 'Wood', 'Chemical', 'Other')),
  quantity TEXT NOT NULL,
  condition TEXT NOT NULL CHECK (condition IN ('Excellent', 'Good', 'Fair', 'Poor')),
  location TEXT NOT NULL,
  confidence DECIMAL(3, 2) DEFAULT 0,
  image_url TEXT,
  notes TEXT,
  status TEXT DEFAULT 'detected' CHECK (status IN ('detected', 'listed', 'matched', 'in_use', 'completed')),
  carbon_saved DECIMAL(10, 2) DEFAULT 0,
  campus_id UUID REFERENCES campuses(id),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on materials
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

-- Materials policies
CREATE POLICY "Anyone can view materials" ON materials FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert materials" ON materials FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Material creators can update" ON materials FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Material creators can delete" ON materials FOR DELETE USING (auth.uid() = created_by);

-- Enable realtime for materials
ALTER PUBLICATION supabase_realtime ADD TABLE materials;

-- ================= OPPORTUNITIES TABLE =================
CREATE TABLE IF NOT EXISTS opportunities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  material_name TEXT NOT NULL,
  material_type TEXT NOT NULL,
  suggested_projects TEXT[] DEFAULT '{}',
  carbon_impact DECIMAL(10, 2) DEFAULT 0,
  matched_student_id UUID REFERENCES profiles(id),
  match_percentage INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on opportunities
ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

-- Opportunities policies
CREATE POLICY "Anyone can view opportunities" ON opportunities FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert opportunities" ON opportunities FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update opportunities" ON opportunities FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Enable realtime for opportunities
ALTER PUBLICATION supabase_realtime ADD TABLE opportunities;

-- ================= REQUESTS TABLE =================
CREATE TABLE IF NOT EXISTS requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  material_type TEXT NOT NULL,
  quantity TEXT NOT NULL,
  project TEXT NOT NULL,
  description TEXT,
  deadline TIMESTAMP WITH TIME ZONE,
  urgency TEXT DEFAULT 'medium' CHECK (urgency IN ('low', 'medium', 'high', 'urgent')),
  requester_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  matched_material_id UUID REFERENCES materials(id),
  matched_percentage INTEGER DEFAULT 0,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'fulfilled', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on requests
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

-- Requests policies
CREATE POLICY "Anyone can view requests" ON requests FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert requests" ON requests FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Request creators can update" ON requests FOR UPDATE USING (auth.uid() = requester_id);
CREATE POLICY "Request creators can delete" ON requests FOR DELETE USING (auth.uid() = requester_id);

-- Enable realtime for requests
ALTER PUBLICATION supabase_realtime ADD TABLE requests;

-- ================= NOTIFICATIONS TABLE =================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('opportunity', 'match', 'approval', 'reminder', 'impact', 'system')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can insert notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can update their own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- Enable realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ================= BARTER_EXCHANGES TABLE =================
CREATE TABLE IF NOT EXISTS barter_exchanges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  offerer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  skill_offered TEXT NOT NULL,
  skill_wanted TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'matched', 'in_progress', 'completed', 'cancelled')),
  matched_user_id UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on barter_exchanges
ALTER TABLE barter_exchanges ENABLE ROW LEVEL SECURITY;

-- Barter policies
CREATE POLICY "Anyone can view barter exchanges" ON barter_exchanges FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create exchanges" ON barter_exchanges FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Exchange owners can update" ON barter_exchanges FOR UPDATE USING (auth.uid() = offerer_id);

-- Enable realtime for barter_exchanges
ALTER PUBLICATION supabase_realtime ADD TABLE barter_exchanges;

-- ================= FUNCTIONS & TRIGGERS =================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_opportunities_updated_at BEFORE UPDATE ON opportunities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_requests_updated_at BEFORE UPDATE ON requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_barter_updated_at BEFORE UPDATE ON barter_exchanges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update user's CO2 saved when a material is completed
CREATE OR REPLACE FUNCTION update_user_co2_saved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE profiles
    SET co2_saved = co2_saved + NEW.carbon_saved,
        materials_reused = materials_reused + 1
    WHERE id = NEW.created_by;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_co2_on_material_complete 
AFTER UPDATE ON materials 
FOR EACH ROW 
EXECUTE FUNCTION update_user_co2_saved();

-- ================= STORAGE BUCKET =================
-- Run these commands in Supabase Dashboard > Storage

-- Create a bucket for material images
-- INSERT INTO storage.buckets (id, name, public) VALUES ('materials', 'materials', true);

-- Storage policies (run in SQL editor with proper permissions)
-- CREATE POLICY "Anyone can view material images" ON storage.objects FOR SELECT USING (bucket_id = 'materials');
-- CREATE POLICY "Authenticated users can upload images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'materials' AND auth.uid() IS NOT NULL);

-- ================= E-COMMERCE EXTENSIONS =================

-- Extend profiles table with e-commerce fields
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS address_line1 TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS address_line2 TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS state TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS postal_code TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'India';

-- Add inventory and pricing fields to materials
ALTER TABLE materials ADD COLUMN IF NOT EXISTS stock_quantity INTEGER DEFAULT 1;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS base_price DECIMAL(10, 2);
ALTER TABLE materials ADD COLUMN IF NOT EXISTS is_listed_for_sale BOOLEAN DEFAULT false;
ALTER TABLE materials ADD COLUMN IF NOT EXISTS irs_score INTEGER; -- Innovation Reuse Score
ALTER TABLE materials ADD COLUMN IF NOT EXISTS lifecycle_state TEXT DEFAULT 'detected';

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_materials_listed ON materials(is_listed_for_sale) WHERE is_listed_for_sale = true;
CREATE INDEX IF NOT EXISTS idx_materials_type ON materials(type);
CREATE INDEX IF NOT EXISTS idx_materials_campus ON materials(campus_id);

-- ================= MATERIAL PASSPORTS TABLE =================
CREATE TABLE IF NOT EXISTS material_passports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  defect_classification TEXT,
  allowed_use TEXT,
  certification_status TEXT DEFAULT 'pending' CHECK (certification_status IN ('pending', 'certified', 'rejected')),
  certification_date TIMESTAMP WITH TIME ZONE,
  certifier_id UUID REFERENCES profiles(id),
  quality_grade TEXT CHECK (quality_grade IN ('A', 'B', 'C', 'D')),
  safety_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE material_passports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view material passports" 
  ON material_passports FOR SELECT USING (true);
CREATE POLICY "Admins can manage passports" 
  ON material_passports FOR ALL 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

-- ================= CARTS TABLE =================
CREATE TABLE IF NOT EXISTS carts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE carts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own cart" 
  ON carts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own cart" 
  ON carts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own cart" 
  ON carts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own cart" 
  ON carts FOR DELETE USING (auth.uid() = user_id);

-- ================= CART ITEMS TABLE =================
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id UUID REFERENCES carts(id) ON DELETE CASCADE,
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(cart_id, material_id)
);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their cart items" 
  ON cart_items FOR SELECT 
  USING (cart_id IN (SELECT id FROM carts WHERE user_id = auth.uid()));
CREATE POLICY "Users can manage their cart items" 
  ON cart_items FOR ALL 
  USING (cart_id IN (SELECT id FROM carts WHERE user_id = auth.uid()));

CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_material ON cart_items(material_id);

-- ================= ORDERS TABLE =================
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  shipping_amount DECIMAL(10, 2) DEFAULT 0,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
  shipping_address_line1 TEXT NOT NULL,
  shipping_address_line2 TEXT,
  shipping_city TEXT NOT NULL,
  shipping_state TEXT NOT NULL,
  shipping_postal_code TEXT NOT NULL,
  shipping_country TEXT DEFAULT 'India',
  shipping_phone TEXT,
  tracking_number TEXT,
  notes TEXT,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancelled_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders" 
  ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all orders" 
  ON orders FOR SELECT 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "Users can create orders" 
  ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can update orders" 
  ON orders FOR UPDATE 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

CREATE TRIGGER update_orders_updated_at 
  BEFORE UPDATE ON orders 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at DESC);

ALTER PUBLICATION supabase_realtime ADD TABLE orders;

-- ================= ORDER ITEMS TABLE =================
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  material_id UUID REFERENCES materials(id) ON DELETE SET NULL,
  material_name TEXT NOT NULL,
  material_type TEXT NOT NULL,
  material_image_url TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their order items" 
  ON order_items FOR SELECT 
  USING (order_id IN (SELECT id FROM orders WHERE user_id = auth.uid()));
CREATE POLICY "Admins can view all order items" 
  ON order_items FOR SELECT 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- ================= PAYMENTS TABLE =================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('credit_card', 'debit_card', 'upi', 'net_banking', 'wallet', 'cod')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
  transaction_id TEXT,
  gateway_order_id TEXT,
  gateway_payment_id TEXT,
  gateway_signature TEXT,
  gateway_response JSONB,
  error_message TEXT,
  refund_amount DECIMAL(10, 2),
  refunded_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their payments" 
  ON payments FOR SELECT 
  USING (order_id IN (SELECT id FROM orders WHERE user_id = auth.uid()));
CREATE POLICY "Admins can view all payments" 
  ON payments FOR SELECT 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "System can create payments" 
  ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY "System can update payments" 
  ON payments FOR UPDATE USING (true);

CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(payment_status);

-- ================= ESCROW ACCOUNTS TABLE =================
CREATE TABLE IF NOT EXISTS escrow_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  seller_id UUID REFERENCES profiles(id),
  escrow_amount DECIMAL(10, 2) NOT NULL,
  release_status TEXT DEFAULT 'held' CHECK (release_status IN ('held', 'released', 'refunded', 'disputed')),
  release_amount DECIMAL(10, 2),
  released_at TIMESTAMP WITH TIME ZONE,
  dispute_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE escrow_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage escrow" 
  ON escrow_accounts FOR ALL 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "Sellers can view their escrow" 
  ON escrow_accounts FOR SELECT 
  USING (auth.uid() = seller_id);

-- ================= LIFECYCLE LOGS TABLE =================
CREATE TABLE IF NOT EXISTS lifecycle_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  order_id UUID REFERENCES orders(id),
  state TEXT NOT NULL CHECK (state IN ('detected', 'listed', 'certified', 'carted', 'ordered', 'confirmed', 'processing', 'shipped', 'delivered', 'in_use', 'completed', 'recycled', 'cancelled')),
  description TEXT,
  metadata JSONB,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE lifecycle_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lifecycle logs" 
  ON lifecycle_logs FOR SELECT USING (true);
CREATE POLICY "Authenticated users can add logs" 
  ON lifecycle_logs FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_lifecycle_logs_material ON lifecycle_logs(material_id);
CREATE INDEX IF NOT EXISTS idx_lifecycle_logs_timestamp ON lifecycle_logs(timestamp DESC);

ALTER PUBLICATION supabase_realtime ADD TABLE lifecycle_logs;

-- ================= FEEDBACK TABLE =================
CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  project_success BOOLEAN,
  completion_time INTEGER, -- in days
  images TEXT[], -- URLs to uploaded images
  seller_rating INTEGER CHECK (seller_rating >= 1 AND seller_rating <= 5),
  would_recommend BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view feedback" 
  ON feedback FOR SELECT USING (true);
CREATE POLICY "Users can create feedback" 
  ON feedback FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their feedback" 
  ON feedback FOR UPDATE USING (auth.uid() = user_id);

CREATE TRIGGER update_feedback_updated_at 
  BEFORE UPDATE ON feedback 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_feedback_material ON feedback(material_id);
CREATE INDEX IF NOT EXISTS idx_feedback_user ON feedback(user_id);

-- ================= COMMISSIONS TABLE =================
CREATE TABLE IF NOT EXISTS commissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  seller_id UUID REFERENCES profiles(id),
  order_amount DECIMAL(10, 2) NOT NULL,
  platform_fee_percentage DECIMAL(5, 2) DEFAULT 5.00,
  platform_fee DECIMAL(10, 2) NOT NULL,
  transaction_fee DECIMAL(10, 2) DEFAULT 0,
  seller_payout DECIMAL(10, 2) NOT NULL,
  payout_status TEXT DEFAULT 'pending' CHECK (payout_status IN ('pending', 'processing', 'completed', 'failed')),
  payout_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE commissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all commissions" 
  ON commissions FOR SELECT 
  USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "Sellers can view their commissions" 
  ON commissions FOR SELECT 
  USING (auth.uid() = seller_id);

CREATE INDEX IF NOT EXISTS idx_commissions_seller ON commissions(seller_id);
CREATE INDEX IF NOT EXISTS idx_commissions_status ON commissions(payout_status);

-- ================= DATABASE FUNCTIONS =================

-- Generate unique order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  new_order_number TEXT;
  order_exists BOOLEAN;
BEGIN
  LOOP
    new_order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    SELECT EXISTS(SELECT 1 FROM orders WHERE order_number = new_order_number) INTO order_exists;
    EXIT WHEN NOT order_exists;
  END LOOP;
  RETURN new_order_number;
END;
$$ LANGUAGE plpgsql;

-- Auto-create cart for new users
CREATE OR REPLACE FUNCTION create_user_cart()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO carts (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_cart_on_signup
AFTER INSERT ON profiles
FOR EACH ROW
EXECUTE FUNCTION create_user_cart();

-- Update material stock on order confirmation
CREATE OR REPLACE FUNCTION update_material_stock()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'confirmed' AND OLD.status = 'pending' THEN
    UPDATE materials m
    SET 
      stock_quantity = stock_quantity - oi.quantity,
      lifecycle_state = 'ordered'
    FROM order_items oi
    WHERE oi.order_id = NEW.id AND oi.material_id = m.id;
    
    -- Log lifecycle change
    INSERT INTO lifecycle_logs (material_id, order_id, state, description)
    SELECT 
      oi.material_id,
      NEW.id,
      'ordered',
      'Material ordered by customer'
    FROM order_items oi
    WHERE oi.order_id = NEW.id;
  END IF;
  
  -- Update lifecycle state on delivery
  IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
    UPDATE materials m
    SET lifecycle_state = 'delivered'
    FROM order_items oi
    WHERE oi.order_id = NEW.id AND oi.material_id = m.id;
    
    INSERT INTO lifecycle_logs (material_id, order_id, state, description)
    SELECT 
      oi.material_id,
      NEW.id,
      'delivered',
      'Material delivered to customer'
    FROM order_items oi
    WHERE oi.order_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_on_order_status
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_material_stock();

-- Log material lifecycle state changes
CREATE OR REPLACE FUNCTION log_material_lifecycle()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.lifecycle_state IS DISTINCT FROM OLD.lifecycle_state THEN
    INSERT INTO lifecycle_logs (material_id, state, description, user_id)
    VALUES (
      NEW.id, 
      NEW.lifecycle_state, 
      'State changed from ' || COALESCE(OLD.lifecycle_state, 'none') || ' to ' || NEW.lifecycle_state,
      NEW.created_by
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_lifecycle_changes
AFTER UPDATE ON materials
FOR EACH ROW
EXECUTE FUNCTION log_material_lifecycle();

-- Calculate and create commission on order completion
CREATE OR REPLACE FUNCTION create_commission()
RETURNS TRIGGER AS $$
DECLARE
  v_seller_id UUID;
  v_platform_fee DECIMAL(10, 2);
  v_transaction_fee DECIMAL(10, 2);
  v_seller_payout DECIMAL(10, 2);
BEGIN
  IF NEW.payment_status = 'completed' AND OLD.payment_status != 'completed' THEN
    -- Get seller from first order item
    SELECT m.created_by INTO v_seller_id
    FROM order_items oi
    JOIN materials m ON oi.material_id = m.id
    WHERE oi.order_id = NEW.id
    LIMIT 1;
    
    -- Calculate fees
    v_platform_fee := NEW.total_amount * 0.05; -- 5% platform fee
    v_transaction_fee := NEW.total_amount * 0.02; -- 2% payment gateway fee
    v_seller_payout := NEW.total_amount - v_platform_fee - v_transaction_fee;
    
    -- Create commission record
    INSERT INTO commissions (
      order_id,
      seller_id,
      order_amount,
      platform_fee,
      transaction_fee,
      seller_payout
    ) VALUES (
      NEW.id,
      v_seller_id,
      NEW.total_amount,
      v_platform_fee,
      v_transaction_fee,
      v_seller_payout
    );
    
    -- Create escrow account
    INSERT INTO escrow_accounts (
      order_id,
      seller_id,
      escrow_amount
    ) VALUES (
      NEW.id,
      v_seller_id,
      v_seller_payout
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_commission_on_payment
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION create_commission();

-- ================= SAMPLE DATA (Optional) =================

-- Sample materials (uncomment to use)
/*
INSERT INTO materials (name, type, quantity, condition, location, confidence, status, carbon_saved, base_price, stock_quantity, is_listed_for_sale) VALUES
  ('Arduino Boards', 'Electronic', '5 units', 'Good', 'Lab A - Chemistry', 0.94, 'listed', 0.8, 299.99, 5, true),
  ('Copper Wire Spools', 'Metal', '3 kg', 'Good', 'Lab B - Electronics', 0.89, 'listed', 1.2, 450.00, 3, true),
  ('Acrylic Sheets', 'Plastic', '10 sheets', 'Good', 'Workshop', 0.85, 'listed', 2.5, 150.00, 10, true),
  ('Glass Beakers', 'Glass', '8 units', 'Fair', 'Lab A - Chemistry', 0.72, 'listed', 0.5, 75.00, 8, true);
*/
