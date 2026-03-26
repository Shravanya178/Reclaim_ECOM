import React, { useState, useEffect } from 'react';
import { MapPin, Filter } from 'lucide-react';

const CampusFilter = ({ onFilterChange, initialCampus = "VESIT" }) => {
  const [selectedCampus, setSelectedCampus] = useState(initialCampus);
  const [materials, setMaterials] = useState([]);

  // Dummy data with campus information
  const allMaterials = [
    { id: 1, name: 'Arduino Uno R3', campus: 'VESIT', category: 'Electronics', price: '₹1,200', stock: 15 },
    { id: 2, name: 'Breadboard Large', campus: 'SPIT', category: 'Electronics', price: '₹150', stock: 25 },
    { id: 3, name: 'Ultrasonic Sensor', campus: 'VESIT', category: 'Sensors', price: '₹300', stock: 8 },
    { id: 4, name: 'Raspberry Pi 4', campus: 'DJ Sanghvi', category: 'Electronics', price: '₹4,500', stock: 5 },
    { id: 5, name: 'Jumper Wires Set', campus: 'VESIT', category: 'Electronics', price: '₹80', stock: 30 },
    { id: 6, name: 'LCD Display 16x2', campus: 'SPIT', category: 'Display', price: '₹250', stock: 12 },
    { id: 7, name: 'Servo Motor SG90', campus: 'VESIT', category: 'Motors', price: '₹200', stock: 18 },
    { id: 8, name: 'Temperature Sensor', campus: 'DJ Sanghvi', category: 'Sensors', price: '₹120', stock: 20 },
    { id: 9, name: 'LED Strip 5m', campus: 'SPIT', category: 'Lighting', price: '₹400', stock: 7 },
    { id: 10, name: 'Resistor Kit', campus: 'VESIT', category: 'Electronics', price: '₹180', stock: 22 },
  ];

  const campuses = ['VESIT', 'SPIT', 'DJ Sanghvi'];

  useEffect(() => {
    filterMaterials(selectedCampus);
  }, [selectedCampus]);

  const filterMaterials = (campus) => {
    const filtered = allMaterials.filter(material => material.campus === campus);
    setMaterials(filtered);
    
    if (onFilterChange) {
      onFilterChange(filtered, campus);
    }
  };

  const handleCampusChange = (e) => {
    const newCampus = e.target.value;
    setSelectedCampus(newCampus);
  };

  const getCampusStats = (campus) => {
    const campusMaterials = allMaterials.filter(m => m.campus === campus);
    const totalStock = campusMaterials.reduce((sum, m) => sum + m.stock, 0);
    const categories = [...new Set(campusMaterials.map(m => m.category))].length;
    
    return { count: campusMaterials.length, totalStock, categories };
  };

  const currentStats = getCampusStats(selectedCampus);

  return (
    <div className="dashboard-card">
      <div className="card-title">Materials Near You</div>
      <div className="card-subtitle">
        Find materials available at your campus and nearby locations
      </div>

      {/* Campus Selector */}
      <div className="form-group" style={{ marginBottom: '1.5rem' }}>
        <label className="form-label">
          <MapPin size={16} style={{ display: 'inline', marginRight: '0.5rem' }} />
          Select Campus
        </label>
        <select 
          className="form-select"
          value={selectedCampus}
          onChange={handleCampusChange}
        >
          {campuses.map(campus => (
            <option key={campus} value={campus}>
              {campus}
            </option>
          ))}
        </select>
      </div>

      {/* Campus Stats */}
      <div 
        style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(3, 1fr)', 
          gap: '1rem',
          marginBottom: '1.5rem'
        }}
      >
        <div 
          style={{ 
            textAlign: 'center',
            padding: '1rem',
            backgroundColor: 'rgba(37, 99, 235, 0.1)',
            borderRadius: 'var(--radius)',
            border: '1px solid rgba(37, 99, 235, 0.2)'
          }}
        >
          <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--primary-color)' }}>
            {currentStats.count}
          </div>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            Materials
          </div>
        </div>
        <div 
          style={{ 
            textAlign: 'center',
            padding: '1rem',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            borderRadius: 'var(--radius)',
            border: '1px solid rgba(16, 185, 129, 0.2)'
          }}
        >
          <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--success-color)' }}>
            {currentStats.totalStock}
          </div>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            Total Stock
          </div>
        </div>
        <div 
          style={{ 
            textAlign: 'center',
            padding: '1rem',
            backgroundColor: 'rgba(245, 158, 11, 0.1)',
            borderRadius: 'var(--radius)',
            border: '1px solid rgba(245, 158, 11, 0.2)'
          }}
        >
          <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--warning-color)' }}>
            {currentStats.categories}
          </div>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            Categories
          </div>
        </div>
      </div>

      {/* Materials List */}
      <div>
        <div 
          style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '0.5rem',
            marginBottom: '1rem',
            fontSize: '1rem',
            fontWeight: '500'
          }}
        >
          <Filter size={16} />
          {selectedCampus} Materials ({materials.length})
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {materials.map(material => (
            <div 
              key={material.id}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '1rem',
                backgroundColor: 'var(--background)',
                borderRadius: 'var(--radius)',
                border: '1px solid var(--border-color)',
                transition: 'all 0.2s ease'
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.boxShadow = 'var(--shadow)';
                e.currentTarget.style.transform = 'translateY(-1px)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.boxShadow = 'none';
                e.currentTarget.style.transform = 'translateY(0)';
              }}
            >
              <div>
                <div style={{ fontWeight: '500', marginBottom: '0.25rem' }}>
                  {material.name}
                </div>
                <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                  {material.category} • Stock: {material.stock}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontWeight: '600', color: 'var(--primary-color)' }}>
                  {material.price}
                </div>
                <div 
                  style={{ 
                    fontSize: '0.75rem',
                    color: material.stock > 10 ? 'var(--success-color)' : 
                           material.stock > 5 ? 'var(--warning-color)' : 'var(--error-color)',
                    fontWeight: '500'
                  }}
                >
                  {material.stock > 10 ? 'In Stock' : 
                   material.stock > 5 ? 'Low Stock' : 'Very Low'}
                </div>
              </div>
            </div>
          ))}
        </div>

        {materials.length === 0 && (
          <div 
            style={{ 
              textAlign: 'center',
              padding: '2rem',
              color: 'var(--text-secondary)',
              backgroundColor: 'var(--background)',
              borderRadius: 'var(--radius)',
              border: '2px dashed var(--border-color)'
            }}
          >
            <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📦</div>
            <div>No materials found at {selectedCampus}</div>
            <div style={{ fontSize: '0.875rem', marginTop: '0.5rem' }}>
              Try selecting a different campus
            </div>
          </div>
        )}
      </div>

      {/* Quick Actions */}
      <div 
        style={{ 
          marginTop: '1.5rem',
          padding: '1rem',
          backgroundColor: 'rgba(37, 99, 235, 0.05)',
          borderRadius: 'var(--radius)',
          border: '1px solid rgba(37, 99, 235, 0.2)'
        }}
      >
        <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.75rem' }}>
          Quick Actions:
        </div>
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          <button 
            className="btn btn-outline"
            style={{ fontSize: '0.75rem', padding: '0.375rem 0.75rem' }}
            onClick={() => alert('Request new material feature coming soon!')}
          >
            📝 Request Material
          </button>
          <button 
            className="btn btn-outline"
            style={{ fontSize: '0.75rem', padding: '0.375rem 0.75rem' }}
            onClick={() => alert('Donate material feature coming soon!')}
          >
            🎁 Donate Material
          </button>
          <button 
            className="btn btn-outline"
            style={{ fontSize: '0.75rem', padding: '0.375rem 0.75rem' }}
            onClick={() => alert('Campus map feature coming soon!')}
          >
            🗺️ Campus Map
          </button>
        </div>
      </div>
    </div>
  );
};

export default CampusFilter;