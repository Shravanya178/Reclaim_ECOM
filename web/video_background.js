// Video Background JavaScript for Flutter Web
function initVideoBackground(videoPath, opacity = 0.7) {
  // Remove any existing video background
  const existingVideo = document.getElementById('flutter-video-bg');
  if (existingVideo) {
    existingVideo.remove();
  }

  // Create video element
  const video = document.createElement('video');
  video.id = 'flutter-video-bg';
  video.src = videoPath;
  video.autoplay = true;
  video.muted = true;
  video.loop = true;
  video.playsInline = true;
  
  // Style the video
  video.style.position = 'fixed';
  video.style.top = '0';
  video.style.left = '0';
  video.style.width = '100vw';
  video.style.height = '100vh';
  video.style.objectFit = 'cover';
  video.style.zIndex = '-1';
  video.style.opacity = opacity.toString();
  video.style.pointerEvents = 'none';

  // Add to body
  document.body.appendChild(video);

  // Handle video events
  video.addEventListener('loadeddata', () => {
    console.log('Video background loaded successfully');
  });

  video.addEventListener('error', (e) => {
    console.error('Video background failed to load:', e);
    // Fallback: remove video element if it fails
    video.remove();
  });

  // Ensure video plays (handle autoplay restrictions)
  video.addEventListener('canplay', () => {
    video.play().catch(error => {
      console.warn('Video autoplay failed:', error);
    });
  });

  return video;
}

function removeVideoBackground() {
  const video = document.getElementById('flutter-video-bg');
  if (video) {
    video.pause();
    video.remove();
  }
}

// Make functions available globally
window.initVideoBackground = initVideoBackground;
window.removeVideoBackground = removeVideoBackground;