import React, { useState, useRef } from 'react';
import { Upload, Camera, Zap, CheckCircle, AlertCircle, Lightbulb } from 'lucide-react';

const AIMaterialDetection = () => {
  const [uploadedImage, setUploadedImage] = useState(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisResult, setAnalysisResult] = useState(null);
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef(null);

  // Fake AI analysis results for different materials
  const aiResults = [
    {
      detected: "Arduino Uno R3",
      condition: "Good",
      confidence: 94,
      suggestedUse: "Electronics Projects, IoT Development, Prototyping",
      estimatedValue: "₹1,200 - ₹1,500",
      compatibility: ["Breadboard", "Sensors", "Motors", "LCD Displays"],
      tips: "Perfect for beginners. Check if USB cable is included."
    },
    {
      detected: "Raspberry Pi 4",
      condition: "Excellent",
      confidence: 98,
      suggestedUse: "Mini Computer Projects, Home Automation, AI/ML",
      estimatedValue: "₹4,000 - ₹5,000",
      compatibility: ["MicroSD Card", "HDMI Cable", "Power Supply", "GPIO Sensors"],
      tips: "High-performance board. Ensure proper cooling for intensive tasks."
    },
    {
      detected: "Breadboard (Half-size)",
      condition: "Fair",
      confidence: 87,
      suggestedUse: "Circuit Prototyping, Electronics Learning",
      estimatedValue: "₹100 - ₹200",
      compatibility: ["Jumper Wires", "Arduino", "Electronic Components"],
      tips: "Check for loose connections. Clean contact points if needed."
    },
    {
      detected: "Ultrasonic Sensor HC-SR04",
      condition: "Good",
      confidence: 91,
      suggestedUse: "Distance Measurement, Obstacle Detection, Robotics",
      estimatedValue: "₹250 - ₹350",
      compatibility: ["Arduino", "Raspberry Pi", "Microcontrollers"],
      tips: "Test with simple distance measurement code before use."
    }
  ];

  const handleFileSelect = (file) => {
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setUploadedImage(e.target.result);
        setAnalysisResult(null);
        simulateAIAnalysis();
      };
      reader.readAsDataURL(file);
    } else {
      alert('Please select a valid image file');
    }
  };

  const simulateAIAnalysis = () => {
    setIsAnalyzing(true);
    
    // Simulate AI processing time
    setTimeout(() => {
      const randomResult = aiResults[Math.floor(Math.random() * aiResults.length)];
      setAnalysisResult(randomResult);
      setIsAnalyzing(false);
    }, 2000 + Math.random() * 1500); // 2-3.5 seconds
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    handleFileSelect(file);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setDragOver(false);
  };

  const handleFileInputChange = (e) => {
    const file = e.target.files[0];
    handleFileSelect(file);
  };

  const handleUploadClick = () => {
    fileInputRef.current?.click();
  };

  const getConditionColor = (condition) => {
    switch (condition.toLowerCase()) {
      case 'excellent': return 'var(--success-color)';
      case 'good': return 'var(--primary-color)';
      case 'fair': return 'var(--warning-color)';
      case 'poor': return 'var(--error-color)';
      default: return 'var(--text-secondary)';
    }
  };

  const getConditionIcon = (condition) => {
    switch (condition.toLowerCase()) {
      case 'excellent': return <CheckCircle size={16} />;
      case 'good': return <CheckCircle size={16} />;
      case 'fair': return <AlertCircle size={16} />;
      case 'poor': return <AlertCircle size={16} />;
      default: return <AlertCircle size={16} />;
    }
  };

  return (
    <div className="dashboard-card">
      <div className="card-title">AI Material Detection</div>
      <div className="card-subtitle">
        Upload an image to automatically identify materials and get detailed information
      </div>

      {/* Upload Area */}
      <div
        className={`upload-area ${dragOver ? 'dragover' : ''}`}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onClick={handleUploadClick}
        style={{
          marginBottom: '1.5rem',
          position: 'relative',
          minHeight: '200px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center'
        }}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileInputChange}
          style={{ display: 'none' }}
        />

        {!uploadedImage ? (
          <>
            <div style={{ marginBottom: '1rem' }}>
              <Upload size={48} color="var(--text-secondary)" />
            </div>
            <div style={{ textAlign: 'center' }}>
              <div style={{ fontWeight: '500', marginBottom: '0.5rem' }}>
                Drop an image here or click to upload
              </div>
              <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                Supports JPG, PNG, WebP up to 10MB
              </div>
            </div>
            <button 
              className="btn btn-primary"
              style={{ marginTop: '1rem' }}
              onClick={handleUploadClick}
            >
              <Camera size={16} />
              Choose Image
            </button>
          </>
        ) : (
          <div style={{ textAlign: 'center', width: '100%' }}>
            <img 
              src={uploadedImage} 
              alt="Uploaded material"
              className="image-preview"
              style={{ maxHeight: '300px', borderRadius: 'var(--radius)' }}
            />
            <button 
              className="btn btn-outline"
              style={{ marginTop: '1rem' }}
              onClick={() => {
                setUploadedImage(null);
                setAnalysisResult(null);
                setIsAnalyzing(false);
              }}
            >
              Upload Different Image
            </button>
          </div>
        )}
      </div>

      {/* Analysis Loading */}
      {isAnalyzing && (
        <div 
          style={{ 
            textAlign: 'center',
            padding: '2rem',
            backgroundColor: 'rgba(37, 99, 235, 0.05)',
            borderRadius: 'var(--radius)',
            border: '1px solid rgba(37, 99, 235, 0.2)',
            marginBottom: '1.5rem'
          }}
        >
          <div style={{ marginBottom: '1rem' }}>
            <Zap size={32} color="var(--primary-color)" className="animate-pulse" />
          </div>
          <div style={{ fontWeight: '500', marginBottom: '0.5rem' }}>
            AI is analyzing your image...
          </div>
          <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            This may take a few seconds
          </div>
          <div 
            style={{
              width: '100%',
              height: '4px',
              backgroundColor: 'var(--border-color)',
              borderRadius: '2px',
              marginTop: '1rem',
              overflow: 'hidden'
            }}
          >
            <div 
              style={{
                width: '30%',
                height: '100%',
                backgroundColor: 'var(--primary-color)',
                borderRadius: '2px',
                animation: 'loading 2s ease-in-out infinite'
              }}
            />
          </div>
        </div>
      )}

      {/* Analysis Results */}
      {analysisResult && !isAnalyzing && (
        <div 
          style={{ 
            backgroundColor: 'var(--background)',
            borderRadius: 'var(--radius)',
            border: '1px solid var(--border-color)',
            overflow: 'hidden'
          }}
        >
          {/* Header */}
          <div 
            style={{ 
              padding: '1.5rem',
              backgroundColor: 'rgba(37, 99, 235, 0.05)',
              borderBottom: '1px solid var(--border-color)'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
              <Zap size={20} color="var(--primary-color)" />
              <span style={{ fontSize: '1.125rem', fontWeight: '600' }}>
                Detection Results
              </span>
              <span 
                style={{ 
                  backgroundColor: 'var(--success-color)',
                  color: 'white',
                  padding: '0.25rem 0.5rem',
                  borderRadius: '12px',
                  fontSize: '0.75rem',
                  fontWeight: '500'
                }}
              >
                {analysisResult.confidence}% confident
              </span>
            </div>
          </div>

          {/* Main Results */}
          <div style={{ padding: '1.5rem' }}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem', marginBottom: '1.5rem' }}>
              <div>
                <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.25rem' }}>
                  Detected Material
                </div>
                <div style={{ fontSize: '1.25rem', fontWeight: '600', color: 'var(--primary-color)' }}>
                  {analysisResult.detected}
                </div>
              </div>
              
              <div>
                <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.25rem' }}>
                  Condition
                </div>
                <div 
                  style={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    gap: '0.5rem',
                    fontSize: '1.125rem', 
                    fontWeight: '600',
                    color: getConditionColor(analysisResult.condition)
                  }}
                >
                  {getConditionIcon(analysisResult.condition)}
                  {analysisResult.condition}
                </div>
              </div>

              <div>
                <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.25rem' }}>
                  Estimated Value
                </div>
                <div style={{ fontSize: '1.125rem', fontWeight: '600', color: 'var(--success-color)' }}>
                  {analysisResult.estimatedValue}
                </div>
              </div>
            </div>

            {/* Suggested Use */}
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>
                Suggested Use Cases
              </div>
              <div 
                style={{ 
                  padding: '1rem',
                  backgroundColor: 'rgba(16, 185, 129, 0.05)',
                  borderRadius: 'var(--radius)',
                  border: '1px solid rgba(16, 185, 129, 0.2)'
                }}
              >
                {analysisResult.suggestedUse}
              </div>
            </div>

            {/* Compatibility */}
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>
                Compatible With
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
                {analysisResult.compatibility.map((item, index) => (
                  <span 
                    key={index}
                    style={{ 
                      padding: '0.25rem 0.75rem',
                      backgroundColor: 'var(--primary-color)',
                      color: 'white',
                      borderRadius: '12px',
                      fontSize: '0.75rem',
                      fontWeight: '500'
                    }}
                  >
                    {item}
                  </span>
                ))}
              </div>
            </div>

            {/* Tips */}
            <div 
              style={{ 
                display: 'flex',
                gap: '0.75rem',
                padding: '1rem',
                backgroundColor: 'rgba(245, 158, 11, 0.05)',
                borderRadius: 'var(--radius)',
                border: '1px solid rgba(245, 158, 11, 0.2)'
              }}
            >
              <Lightbulb size={20} color="var(--warning-color)" style={{ flexShrink: 0, marginTop: '0.125rem' }} />
              <div>
                <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.25rem' }}>
                  Pro Tip
                </div>
                <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                  {analysisResult.tips}
                </div>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div 
            style={{ 
              padding: '1rem 1.5rem',
              backgroundColor: 'var(--background)',
              borderTop: '1px solid var(--border-color)',
              display: 'flex',
              gap: '0.75rem',
              flexWrap: 'wrap'
            }}
          >
            <button className="btn btn-primary">
              🛒 Find Similar Items
            </button>
            <button className="btn btn-outline">
              📊 Add to Inventory
            </button>
            <button className="btn btn-outline">
              🔄 Request Barter
            </button>
          </div>
        </div>
      )}

      {/* Feature Info */}
      <div 
        style={{ 
          marginTop: '1.5rem',
          padding: '1rem',
          backgroundColor: 'rgba(37, 99, 235, 0.05)',
          borderRadius: 'var(--radius)',
          border: '1px solid rgba(37, 99, 235, 0.2)'
        }}
      >
        <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.5rem' }}>
          🤖 AI Detection Features:
        </div>
        <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
          • Identifies 500+ electronic components and materials<br/>
          • Estimates condition and market value<br/>
          • Suggests compatible components and use cases<br/>
          • Works with photos from any angle
        </div>
      </div>

      <style jsx>{`
        @keyframes loading {
          0% { transform: translateX(-100%); }
          50% { transform: translateX(300%); }
          100% { transform: translateX(-100%); }
        }
        
        .animate-pulse {
          animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.5; }
        }
      `}</style>
    </div>
  );
};

export default AIMaterialDetection;