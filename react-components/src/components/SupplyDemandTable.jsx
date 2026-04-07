import React from 'react';

const SupplyDemandTable = () => {
  const data = [
    { material: 'Electronic Components', requests: 24, stock: 38, status: 'Surplus' },
    { material: 'Plastic Polymers', requests: 18, stock: 7, status: 'Deficit' },
    { material: 'Glassware', requests: 14, stock: 12, status: 'Moderate' },
    { material: 'Metal Alloys', requests: 9, stock: 3, status: 'Critical' },
    { material: 'Chemical Reagents', requests: 6, stock: 6, status: 'Balanced' },
  ];

  const getStatusBadge = (status, requests, stock) => {
    let statusClass = '';
    let displayStatus = status;

    if (stock > requests) {
      statusClass = 'status-surplus';
      displayStatus = 'Surplus';
    } else if (stock < requests) {
      if (stock < requests * 0.5) {
        statusClass = 'status-critical';
        displayStatus = 'Critical';
      } else {
        statusClass = 'status-deficit';
        displayStatus = 'Deficit';
      }
    } else if (stock === requests) {
      statusClass = 'status-balanced';
      displayStatus = 'Balanced';
    } else {
      statusClass = 'status-moderate';
      displayStatus = 'Moderate';
    }

    return (
      <span className={`status-badge ${statusClass}`}>
        {displayStatus}
      </span>
    );
  };

  const getStockPercentage = (stock, requests) => {
    if (requests === 0) return 100;
    return Math.round((stock / requests) * 100);
  };

  return (
    <div className="dashboard-card">
      <div className="card-title">Supply vs Demand Gap Analysis</div>
      <div className="card-subtitle">
        This helps labs prioritize materials based on real demand
      </div>
      
      <div style={{ overflowX: 'auto' }}>
        <table className="table">
          <thead>
            <tr>
              <th>Material Type</th>
              <th>Requests (Demand)</th>
              <th>Stock (Supply)</th>
              <th>Supply Ratio</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {data.map((item, index) => (
              <tr key={index}>
                <td style={{ fontWeight: '500' }}>{item.material}</td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <span style={{ fontWeight: '600', color: 'var(--error-color)' }}>
                      {item.requests}
                    </span>
                    <div 
                      style={{ 
                        width: '60px', 
                        height: '4px', 
                        backgroundColor: 'var(--border-color)', 
                        borderRadius: '2px',
                        overflow: 'hidden'
                      }}
                    >
                      <div 
                        style={{ 
                          width: `${Math.min((item.requests / 24) * 100, 100)}%`, 
                          height: '100%', 
                          backgroundColor: 'var(--error-color)' 
                        }}
                      />
                    </div>
                  </div>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <span style={{ fontWeight: '600', color: 'var(--success-color)' }}>
                      {item.stock}
                    </span>
                    <div 
                      style={{ 
                        width: '60px', 
                        height: '4px', 
                        backgroundColor: 'var(--border-color)', 
                        borderRadius: '2px',
                        overflow: 'hidden'
                      }}
                    >
                      <div 
                        style={{ 
                          width: `${Math.min((item.stock / 38) * 100, 100)}%`, 
                          height: '100%', 
                          backgroundColor: 'var(--success-color)' 
                        }}
                      />
                    </div>
                  </div>
                </td>
                <td>
                  <span 
                    style={{ 
                      fontWeight: '600',
                      color: getStockPercentage(item.stock, item.requests) >= 100 
                        ? 'var(--success-color)' 
                        : getStockPercentage(item.stock, item.requests) >= 80
                        ? 'var(--warning-color)'
                        : 'var(--error-color)'
                    }}
                  >
                    {getStockPercentage(item.stock, item.requests)}%
                  </span>
                </td>
                <td>{getStatusBadge(item.status, item.requests, item.stock)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div 
        style={{ 
          marginTop: '1.5rem', 
          padding: '1rem', 
          backgroundColor: 'var(--background)', 
          borderRadius: 'var(--radius)',
          border: '1px solid var(--border-color)'
        }}
      >
        <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.5rem' }}>
          Status Legend:
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '1rem', fontSize: '0.75rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <span className="status-badge status-surplus">Surplus</span>
            <span>Stock > Demand</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <span className="status-badge status-balanced">Balanced</span>
            <span>Stock = Demand</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <span className="status-badge status-deficit">Deficit</span>
            <span>Stock &lt; Demand</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <span className="status-badge status-critical">Critical</span>
            <span>Stock &lt; 50% Demand</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SupplyDemandTable;