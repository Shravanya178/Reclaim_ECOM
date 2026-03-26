import React, { useState } from 'react';
import './styles/globals.css';

// Import all components
import MostRequestedMaterialsChart from './components/MostRequestedMaterialsChart';
import SupplyDemandTable from './components/SupplyDemandTable';
import ImpactDashboard from './components/ImpactDashboard';
import ProductCard from './components/ProductCard';
import CampusFilter from './components/CampusFilter';
import AIMaterialDetection from './components/AIMaterialDetection';

function App() {
  const [filteredMaterials, setFilteredMaterials] = useState([]);
  const [selectedCampus, setSelectedCampus] = useState('VESIT');

  // Sample products for ProductCard demo
  const sampleProducts = [
    {
      name: "Arduino Uno R3",
      price: "₹1,200",
      campus: "VESIT",
      image: null
    },
    {
      name: "Raspberry Pi 4",
      price: "₹4,500",
      campus: "SPIT",
      image: null
    },
    {
      name: "Ultrasonic Sensor",
      price: "₹300",
      campus: "DJ Sanghvi",
      image: null
    }
  ];

  const handleFilterChange = (materials, campus) => {
    setFilteredMaterials(materials);
    setSelectedCampus(campus);
  };

  const handleBuyNow = (product) => {
    alert(`Purchase initiated for ${product.name} at ${product.price} from ${product.campus}`);
  };

  const handleBarterSubmit = (barterData) => {
    alert(`Barter request submitted!\nProduct: ${barterData.productName}\nOffer: ${barterData.offer}\nMessage: ${barterData.message || 'No message'}`);
  };

  return (
    <div style={{ 
      minHeight: '100vh', 
      backgroundColor: 'var(--background)',
      padding: '2rem 1rem'
    }}>
      <div style={{ maxWidth: '1400px', margin: '0 auto' }}>
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
          <h1 style={{ 
            fontSize: '2.5rem', 
            fontWeight: '700', 
            color: 'var(--text-primary)',
            marginBottom: '0.5rem'
          }}>
            Material Management Dashboard
          </h1>
          <p style={{ 
            fontSize: '1.125rem', 
            color: 'var(--text-secondary)',
            maxWidth: '600px',
            margin: '0 auto'
          }}>
            A comprehensive platform for managing, tracking, and exchanging materials across campuses
          </p>
        </div>

        {/* Dashboard Grid */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
          
          {/* Row 1: Charts and Analytics */}
          <div className="grid grid-cols-2" style={{ gap: '2rem' }}>
            <MostRequestedMaterialsChart />
            <SupplyDemandTable />
          </div>

          {/* Row 2: Impact Dashboard */}
          <ImpactDashboard />

          {/* Row 3: Campus Filter and AI Detection */}
          <div className="grid grid-cols-2" style={{ gap: '2rem' }}>
            <CampusFilter 
              onFilterChange={handleFilterChange}
              initialCampus="VESIT"
            />
            <AIMaterialDetection />
          </div>

          {/* Row 4: Product Cards */}
          <div>
            <div style={{ 
              fontSize: '1.5rem', 
              fontWeight: '600', 
              marginBottom: '1.5rem',
              color: 'var(--text-primary)'
            }}>
              Available Products
            </div>
            <div className="grid grid-cols-3" style={{ gap: '1.5rem' }}>
              {sampleProducts.map((product, index) => (
                <ProductCard
                  key={index}
                  name={product.name}
                  price={product.price}
                  campus={product.campus}
                  image={product.image}
                  onBuyNow={handleBuyNow}
                  onBarterSubmit={handleBarterSubmit}
                />
              ))}
            </div>
          </div>

          {/* Footer */}
          <div style={{ 
            textAlign: 'center', 
            padding: '2rem',
            marginTop: '2rem',
            borderTop: '1px solid var(--border-color)',
            color: 'var(--text-secondary)'
          }}>
            <p>Built with React, Chart.js, and modern design principles</p>
            <p style={{ fontSize: '0.875rem', marginTop: '0.5rem' }}>
              Features: Material tracking, sustainability metrics, AI detection, campus filtering, and barter system
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;