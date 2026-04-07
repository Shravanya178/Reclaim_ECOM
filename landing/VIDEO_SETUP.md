# Video Background Setup

## Quick Setup Instructions

1. **Place your video file** in the `assets/videos/` folder
2. **Rename it to**: `26070-357512237_medium.mp4`
3. **Refresh the landing page** to see the video background

## Video Requirements

- **Format**: MP4 (H.264 codec recommended)
- **Resolution**: 1920x1080 or higher
- **Duration**: 10-30 seconds (will loop automatically)
- **File Size**: Under 10MB for optimal web performance
- **Audio**: Not required (will be muted for autoplay compliance)

## Features Added

✅ **Video Background**: Realistic video background with overlay for text readability
✅ **Fallback System**: Three.js animations show if video fails to load
✅ **Enhanced Cards**: Material and feature cards now have improved styling with:
   - Better backdrop blur effects
   - Enhanced hover animations
   - Improved shadows and borders
   - Better text contrast with video background

✅ **Mobile Optimized**: Video background works properly on mobile devices
✅ **Accessibility**: Respects `prefers-reduced-motion` setting
✅ **Performance**: Optimized for web with proper video compression

## How It Works

1. **Video loads** → Three.js opacity reduces to 30% to complement video
2. **Video fails** → Three.js takes over with full opacity (seamless fallback)
3. **Mobile devices** → Video plays after first user interaction (autoplay requirement)
4. **Reduced motion** → Video is hidden, Three.js animations show instead

The landing page now provides a cinematic experience while maintaining all the original functionality and ensuring excellent performance across all devices.