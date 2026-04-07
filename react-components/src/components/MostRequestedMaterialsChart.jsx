import React from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Bar } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const MostRequestedMaterialsChart = () => {
  const data = {
    labels: ['Electronic Components', 'Plastic', 'Metal', 'Glass', 'Chemical'],
    datasets: [
      {
        label: 'Number of Requests',
        data: [18, 12, 9, 7, 5],
        backgroundColor: [
          'rgba(37, 99, 235, 0.8)',
          'rgba(16, 185, 129, 0.8)',
          'rgba(245, 158, 11, 0.8)',
          'rgba(139, 92, 246, 0.8)',
          'rgba(239, 68, 68, 0.8)',
        ],
        borderColor: [
          'rgba(37, 99, 235, 1)',
          'rgba(16, 185, 129, 1)',
          'rgba(245, 158, 11, 1)',
          'rgba(139, 92, 246, 1)',
          'rgba(239, 68, 68, 1)',
        ],
        borderWidth: 2,
        borderRadius: 6,
        borderSkipped: false,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        titleColor: '#ffffff',
        bodyColor: '#ffffff',
        borderColor: 'rgba(255, 255, 255, 0.1)',
        borderWidth: 1,
        cornerRadius: 8,
        displayColors: false,
        callbacks: {
          title: (context) => context[0].label,
          label: (context) => `${context.parsed.y} requests`,
        },
      },
    },
    scales: {
      x: {
        grid: {
          display: false,
        },
        ticks: {
          color: '#64748b',
          font: {
            size: 12,
            weight: '500',
          },
        },
      },
      y: {
        beginAtZero: true,
        grid: {
          color: 'rgba(226, 232, 240, 0.5)',
        },
        ticks: {
          color: '#64748b',
          font: {
            size: 12,
          },
          stepSize: 2,
        },
      },
    },
    interaction: {
      intersect: false,
      mode: 'index',
    },
    animation: {
      duration: 1000,
      easing: 'easeOutQuart',
    },
  };

  return (
    <div className="dashboard-card">
      <div className="card-title">Most Requested Materials (Last 30 Days)</div>
      <div style={{ height: '400px', position: 'relative' }}>
        <Bar data={data} options={options} />
      </div>
      <div 
        style={{ 
          marginTop: '1rem', 
          fontSize: '0.875rem', 
          color: 'var(--text-secondary)',
          fontStyle: 'italic',
          textAlign: 'center'
        }}
      >
        Data driven from student requests
      </div>
    </div>
  );
};

export default MostRequestedMaterialsChart;