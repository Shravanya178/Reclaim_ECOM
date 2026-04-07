import React from 'react';
import { Leaf, Recycle, Trophy, TrendingUp } from 'lucide-react';

const ImpactDashboard = () => {
  const metrics = [
    {
      icon: <Leaf size={24} />,
      value: '12.5',
      unit: 'kg',
      label: 'CO₂ Saved',
      color: 'var(--success-color)',
      bgColor: 'rgba(16, 185, 129, 0.1)',
    },
    {
      icon: <Recycle size={24} />,
      value: '8',
      unit: '',
      label: 'Materials Reused',
      color: 'var(--primary-color)',
      bgColor: 'rgba(37, 99, 235, 0.1)',
    },
    {
      icon: <Trophy size={24} />,
      value: '#3',
      unit: '',
      label: 'VESIT Campus Rank',
      color: 'var(--warning-color)',
      bgColor: 'rgba(245, 158, 11, 0.1)',
    },
  ];

  const leaderboard = [
    { rank: 1, name: 'Rahul', score: '15kg', isUser: false },
    { rank: 2, name: 'Sneha', score: '13kg', isUser: false },
    { rank: 3, name: 'You', score: '12.5kg', isUser: true },
    { rank: 4, name: 'Amit', score: '10kg', isUser: false },
    { rank: 5, name: 'Priya', score: '9kg', isUser: false },
  ];

  const getRankIcon = (rank) => {
    if (rank === 1) return '🥇';
    if (rank === 2) return '🥈';
    if (rank === 3) return '🥉';
    return `#${rank}`;
  };

  return (
    <div className="dashboard-card">
      <div className="card-title">Your Sustainability Impact</div>
      <div className="card-subtitle">
        Track your contribution and compete with peers
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-3" style={{ marginBottom: '2rem' }}>
        {metrics.map((metric, index) => (
          <div 
            key={index}
            className="metric-card"
            style={{
              backgroundColor: metric.bgColor,
              borderRadius: 'var(--radius)',
              border: `1px solid ${metric.color}20`,
              position: 'relative',
              overflow: 'hidden',
            }}
          >
            <div 
              style={{ 
                display: 'flex', 
                justifyContent: 'center', 
                marginBottom: '0.75rem',
                color: metric.color 
              }}
            >
              {metric.icon}
            </div>
            <div className="metric-value" style={{ color: metric.color }}>
              {metric.value}
              <span style={{ fontSize: '1rem', fontWeight: '500' }}>{metric.unit}</span>
            </div>
            <div className="metric-label">{metric.label}</div>
            
            {/* Decorative background pattern */}
            <div 
              style={{
                position: 'absolute',
                top: '-10px',
                right: '-10px',
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                backgroundColor: `${metric.color}10`,
                zIndex: 0,
              }}
            />
          </div>
        ))}
      </div>

      {/* Progress Indicator */}
      <div 
        style={{ 
          marginBottom: '2rem',
          padding: '1rem',
          backgroundColor: 'var(--background)',
          borderRadius: 'var(--radius)',
          border: '1px solid var(--border-color)'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
          <TrendingUp size={16} color="var(--success-color)" />
          <span style={{ fontSize: '0.875rem', fontWeight: '500' }}>
            Monthly Progress
          </span>
        </div>
        <div 
          style={{ 
            width: '100%', 
            height: '8px', 
            backgroundColor: 'var(--border-color)', 
            borderRadius: '4px',
            overflow: 'hidden',
            marginBottom: '0.5rem'
          }}
        >
          <div 
            style={{ 
              width: '75%', 
              height: '100%', 
              background: 'linear-gradient(90deg, var(--success-color), var(--primary-color))',
              borderRadius: '4px',
              transition: 'width 1s ease-out'
            }}
          />
        </div>
        <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
          75% towards your monthly sustainability goal
        </div>
      </div>

      {/* Leaderboard */}
      <div>
        <div 
          style={{ 
            fontSize: '1.125rem', 
            fontWeight: '600', 
            marginBottom: '1rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}
        >
          <Trophy size={20} color="var(--warning-color)" />
          Leaderboard (Top 5)
        </div>
        
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          {leaderboard.map((item, index) => (
            <div 
              key={index}
              className="leaderboard-item"
              style={{
                backgroundColor: item.isUser ? 'rgba(37, 99, 235, 0.1)' : 'var(--background)',
                border: item.isUser ? '2px solid var(--primary-color)' : '1px solid var(--border-color)',
                transform: item.isUser ? 'scale(1.02)' : 'scale(1)',
                transition: 'all 0.2s ease',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <span 
                  className="leaderboard-rank"
                  style={{ 
                    fontSize: '1.25rem',
                    minWidth: '2rem',
                    textAlign: 'center'
                  }}
                >
                  {getRankIcon(item.rank)}
                </span>
                <span 
                  className="leaderboard-name"
                  style={{ 
                    fontWeight: item.isUser ? '600' : '500',
                    color: item.isUser ? 'var(--primary-color)' : 'var(--text-primary)'
                  }}
                >
                  {item.name}
                  {item.isUser && (
                    <span style={{ 
                      marginLeft: '0.5rem', 
                      fontSize: '0.75rem',
                      color: 'var(--primary-color)',
                      fontWeight: '500'
                    }}>
                      (You)
                    </span>
                  )}
                </span>
              </div>
              <span 
                className="leaderboard-score"
                style={{ 
                  fontWeight: '600',
                  color: item.isUser ? 'var(--primary-color)' : 'var(--text-secondary)'
                }}
              >
                {item.score}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Achievement Badges */}
      <div 
        style={{ 
          marginTop: '1.5rem',
          padding: '1rem',
          backgroundColor: 'rgba(16, 185, 129, 0.05)',
          borderRadius: 'var(--radius)',
          border: '1px solid rgba(16, 185, 129, 0.2)'
        }}
      >
        <div style={{ fontSize: '0.875rem', fontWeight: '500', marginBottom: '0.5rem' }}>
          Recent Achievements
        </div>
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          <span style={{ 
            padding: '0.25rem 0.5rem', 
            backgroundColor: 'var(--success-color)', 
            color: 'white', 
            borderRadius: '12px', 
            fontSize: '0.75rem',
            fontWeight: '500'
          }}>
            🌱 Eco Warrior
          </span>
          <span style={{ 
            padding: '0.25rem 0.5rem', 
            backgroundColor: 'var(--primary-color)', 
            color: 'white', 
            borderRadius: '12px', 
            fontSize: '0.75rem',
            fontWeight: '500'
          }}>
            ♻️ Recycling Champion
          </span>
        </div>
      </div>
    </div>
  );
};

export default ImpactDashboard;