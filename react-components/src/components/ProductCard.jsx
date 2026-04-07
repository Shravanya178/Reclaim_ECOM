import React, { useState } from 'react';
import { ShoppingCart, ArrowRightLeft, X, Send } from 'lucide-react';

const ProductCard = ({ 
  name = "Arduino Uno R3", 
  price = "₹1,200", 
  image = null,
  campus = "VESIT",
  onBuyNow,
  onBarterSubmit 
}) => {
  const [showBarterModal, setShowBarterModal] = useState(false);
  const [barterOffer, setBarterOffer] = useState('');
  const [barterMessage, setBarterMessage] = useState('');

  const handleBuyNow = () => {
    if (onBuyNow) {
      onBuyNow({ name, price, campus });
    } else {
      alert(`Redirecting to purchase ${name} for ${price}`);
    }
  };

  const handleBarterClick = () => {
    setShowBarterModal(true);
  };

  const handleBarterSubmit = (e) => {
    e.preventDefault();
    if (!barterOffer.trim()) {
      alert('Please enter what you want to offer');
      return;
    }

    const barterData = {
      productName: name,
      productPrice: price,
      offer: barterOffer,
      message: barterMessage,
      campus: campus
    };

    if (onBarterSubmit) {
      onBarterSubmit(barterData);
    } else {
      alert(`Barter request submitted!\nProduct: ${name}\nYour offer: ${barterOffer}\nMessage: ${barterMessage || 'No additional message'}`);
    }

    setShowBarterModal(false);
    setBarterOffer('');
    setBarterMessage('');
  };

  const closeModal = () => {
    setShowBarterModal(false);
    setBarterOffer('');
    setBarterMessage('');
  };

  return (
    <>
      <div className="product-card">
        <div style={{ position: 'relative' }}>
          {image ? (
            <img 
              src={image} 
              alt={name}
              className="product-image"
            />
          ) : (
            <div 
              className="product-image"
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'var(--background)',
                color: 'var(--text-secondary)',
                fontSize: '0.875rem',
                border: '2px dashed var(--border-color)'
              }}
            >
              📦 {name}
            </div>
          )}
          
          <div className="barter-label">
            Barter Available
          </div>
          
          <div 
            style={{
              position: 'absolute',
              top: '0.5rem',
              left: '0.5rem',
              backgroundColor: 'var(--primary-color)',
              color: 'white',
              padding: '0.25rem 0.5rem',
              borderRadius: '4px',
              fontSize: '0.75rem',
              fontWeight: '500'
            }}
          >
            {campus}
          </div>
        </div>

        <div className="product-content">
          <div className="product-name">{name}</div>
          <div className="product-price">{price}</div>
          
          <div 
            style={{ 
              fontSize: '0.875rem', 
              color: 'var(--text-secondary)', 
              marginBottom: '1rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem'
            }}
          >
            <span>📍</span>
            <span>Available at {campus} Campus</span>
          </div>

          <div className="product-actions">
            <button 
              className="btn btn-primary"
              onClick={handleBuyNow}
              style={{ flex: 1 }}
            >
              <ShoppingCart size={16} />
              Buy Now
            </button>
            <button 
              className="btn btn-outline"
              onClick={handleBarterClick}
              style={{ flex: 1 }}
            >
              <ArrowRightLeft size={16} />
              Barter
            </button>
          </div>

          <div 
            style={{ 
              marginTop: '0.75rem',
              fontSize: '0.75rem',
              color: 'var(--text-secondary)',
              textAlign: 'center'
            }}
          >
            💡 Save money by trading your unused items
          </div>
        </div>
      </div>

      {/* Barter Modal */}
      {showBarterModal && (
        <div className="modal-overlay" onClick={closeModal}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '600' }}>
                Barter Request
              </h3>
              <button 
                onClick={closeModal}
                style={{ 
                  background: 'none', 
                  border: 'none', 
                  cursor: 'pointer',
                  padding: '0.25rem',
                  borderRadius: '4px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <X size={20} color="var(--text-secondary)" />
              </button>
            </div>

            <div 
              style={{ 
                padding: '1rem',
                backgroundColor: 'var(--background)',
                borderRadius: 'var(--radius)',
                marginBottom: '1.5rem',
                border: '1px solid var(--border-color)'
              }}
            >
              <div style={{ fontWeight: '500', marginBottom: '0.5rem' }}>
                Product: {name}
              </div>
              <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                Price: {price} • Campus: {campus}
              </div>
            </div>

            <form onSubmit={handleBarterSubmit}>
              <div className="form-group">
                <label className="form-label">
                  What do you want to offer? *
                </label>
                <input
                  type="text"
                  className="form-input"
                  value={barterOffer}
                  onChange={(e) => setBarterOffer(e.target.value)}
                  placeholder="e.g., Raspberry Pi 3, Lab Equipment, Books..."
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">
                  Additional Message (Optional)
                </label>
                <textarea
                  className="form-textarea"
                  value={barterMessage}
                  onChange={(e) => setBarterMessage(e.target.value)}
                  placeholder="Describe the condition, add contact details, or any other relevant information..."
                  rows="3"
                />
              </div>

              <div 
                style={{ 
                  padding: '1rem',
                  backgroundColor: 'rgba(37, 99, 235, 0.05)',
                  borderRadius: 'var(--radius)',
                  marginBottom: '1.5rem',
                  border: '1px solid rgba(37, 99, 235, 0.2)'
                }}
              >
                <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.5rem' }}>
                  💡 Barter Tips:
                </div>
                <ul style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', margin: 0, paddingLeft: '1rem' }}>
                  <li>Be specific about item condition</li>
                  <li>Include estimated value of your offer</li>
                  <li>Mention if you can meet on campus</li>
                </ul>
              </div>

              <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'flex-end' }}>
                <button 
                  type="button"
                  className="btn btn-outline"
                  onClick={closeModal}
                >
                  Cancel
                </button>
                <button 
                  type="submit"
                  className="btn btn-primary"
                >
                  <Send size={16} />
                  Submit Request
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
};

export default ProductCard;