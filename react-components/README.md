# Material Management Dashboard Components

A collection of 6 modern React components for material management, sustainability tracking, and campus-based resource sharing.

## 🚀 Components Overview

### 1. **MostRequestedMaterialsChart**
- Interactive bar chart showing material request trends
- Built with Chart.js and react-chartjs-2
- Responsive design with hover tooltips
- Data-driven insights from student requests

### 2. **SupplyDemandTable**
- Comprehensive supply vs demand analysis
- Color-coded status indicators (Surplus, Deficit, Critical, Balanced)
- Visual progress bars for stock levels
- Supply ratio calculations

### 3. **ImpactDashboard**
- Sustainability metrics tracking (CO₂ saved, materials reused)
- Campus leaderboard with rankings
- Achievement badges and progress indicators
- Gamified user engagement

### 4. **ProductCard**
- E-commerce style product display
- Dual action buttons (Buy Now / Barter)
- Modal-based barter system with form validation
- Campus-specific product information

### 5. **CampusFilter**
- Multi-campus material filtering (VESIT, SPIT, DJ Sanghvi)
- Real-time statistics and inventory counts
- Category-based organization
- Quick action buttons for requests and donations

### 6. **AIMaterialDetection**
- AI-powered material identification from images
- Drag-and-drop file upload interface
- Detailed analysis results with confidence scores
- Compatibility suggestions and pro tips

## 🎨 Design System

### Color Palette
- **Primary**: `#2563eb` (Blue)
- **Success**: `#10b981` (Green)
- **Warning**: `#f59e0b` (Amber)
- **Error**: `#ef4444` (Red)
- **Background**: `#f8fafc` (Slate)

### Key Features
- **Consistent Design Language**: All components follow the same design system
- **Responsive Layout**: Mobile-first approach with CSS Grid and Flexbox
- **Accessibility**: Proper color contrast and keyboard navigation
- **Modern UI**: Clean cards, subtle shadows, and smooth transitions
- **Interactive Elements**: Hover effects, loading states, and animations

## 📦 Installation

```bash
# Navigate to the react-components directory
cd react-components

# Install dependencies
npm install

# Start development server
npm start
```

## 🛠️ Dependencies

```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "chart.js": "^4.4.0",
  "react-chartjs-2": "^5.2.0",
  "lucide-react": "^0.263.1",
  "react-scripts": "5.0.1"
}
```

## 📱 Component Usage

### Basic Import
```jsx
import MostRequestedMaterialsChart from './components/MostRequestedMaterialsChart';
import SupplyDemandTable from './components/SupplyDemandTable';
import ImpactDashboard from './components/ImpactDashboard';
import ProductCard from './components/ProductCard';
import CampusFilter from './components/CampusFilter';
import AIMaterialDetection from './components/AIMaterialDetection';
```

### ProductCard with Custom Handlers
```jsx
<ProductCard
  name="Arduino Uno R3"
  price="₹1,200"
  campus="VESIT"
  onBuyNow={(product) => console.log('Buy:', product)}
  onBarterSubmit={(data) => console.log('Barter:', data)}
/>
```

### CampusFilter with Callback
```jsx
<CampusFilter
  initialCampus="VESIT"
  onFilterChange={(materials, campus) => {
    console.log(`${materials.length} materials from ${campus}`);
  }}
/>
```

## 🎯 Features Implemented

### Interactive Elements
- ✅ Fully functional barter modal with form validation
- ✅ Campus filtering with real-time updates
- ✅ AI detection simulation with realistic results
- ✅ Chart interactions with hover tooltips
- ✅ Responsive design for all screen sizes

### Data Management
- ✅ Static dummy data for all components
- ✅ Realistic material categories and pricing
- ✅ Campus-specific inventory management
- ✅ Supply/demand calculations with status logic

### UI/UX Excellence
- ✅ Professional dashboard aesthetics
- ✅ Consistent color coding and typography
- ✅ Smooth animations and transitions
- ✅ Loading states and user feedback
- ✅ Accessibility considerations

## 🚀 Getting Started

1. **Clone or download** the react-components folder
2. **Install dependencies**: `npm install`
3. **Start development**: `npm start`
4. **View in browser**: `http://localhost:3000`

## 🔧 Customization

### Styling
- Modify `src/styles/globals.css` for global theme changes
- CSS custom properties (variables) for easy color customization
- Component-specific styles are inline for better maintainability

### Data
- Update dummy data arrays in each component
- Replace with API calls for dynamic data
- Customize campus names and material categories

### Functionality
- Add real API integrations
- Implement user authentication
- Connect to backend services for barter system

## 📊 Component Specifications

| Component | Lines of Code | Key Features | Dependencies |
|-----------|---------------|--------------|--------------|
| MostRequestedMaterialsChart | ~120 | Chart.js integration, responsive | chart.js, react-chartjs-2 |
| SupplyDemandTable | ~180 | Status logic, progress bars | - |
| ImpactDashboard | ~220 | Leaderboard, metrics, achievements | lucide-react |
| ProductCard | ~280 | Modal system, form validation | lucide-react |
| CampusFilter | ~250 | Filtering logic, statistics | lucide-react |
| AIMaterialDetection | ~320 | File upload, AI simulation | lucide-react |

## 🎨 Screenshots

The components create a cohesive dashboard experience with:
- Modern card-based layouts
- Consistent spacing and typography
- Professional color scheme
- Interactive elements with visual feedback
- Mobile-responsive design

## 🤝 Contributing

Feel free to customize these components for your specific needs:
- Add new material categories
- Implement real AI detection APIs
- Connect to actual databases
- Add more campus locations
- Enhance the barter system

## 📄 License

These components are provided as educational examples and can be freely modified and used in your projects.