# ReClaim Quick Start Script
# Run this after setting up Supabase and Firebase

Write-Host "🚀 ReClaim Setup Script" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

# Check Flutter installation
Write-Host "`n📱 Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found. Please install Flutter first." -ForegroundColor Red
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Please run this script from the ReClaim project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "`n📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n🔧 Generating code..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

Write-Host "`n🎨 Generating launcher icons..." -ForegroundColor Yellow
# Note: You'll need to add an app_icon.png to assets/icons/ first
# flutter pub run flutter_launcher_icons:main

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Set up Supabase project and update lib/core/config/app_config.dart" -ForegroundColor White
Write-Host "2. Set up Firebase project and run 'flutterfire configure --platforms=android'" -ForegroundColor White
Write-Host "3. Add app icon to assets/icons/app_icon.png" -ForegroundColor White
Write-Host "4. Run 'flutter run' to start the Android app" -ForegroundColor White
Write-Host ""
Write-Host "📱 Android-only app - iOS support removed" -ForegroundColor Yellow
Write-Host "🔗 See SETUP.md for detailed instructions" -ForegroundColor Cyan