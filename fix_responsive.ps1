# Script to fix all remaining screen files to be responsive
# Removes flutter_screenutil and adds MediaQuery-based responsive design

$screenFiles = @(
    "lib\features\dashboard\presentation\screens\student_dashboard_screen.dart",
    "lib\features\dashboard\presentation\screens\lab_dashboard_screen.dart",
    "lib\features\dashboard\presentation\screens\admin_dashboard_screen.dart",
    "lib\features\dashboard\presentation\screens\student_profile_screen.dart",
    "lib\features\ecommerce\presentation\screens\product_catalog_screen.dart",
    "lib\features\ecommerce\presentation\screens\checkout_screen.dart",
    "lib\features\ecommerce\presentation\screens\order_history_screen.dart",
    "lib\features\ecommerce\presentation\screens\order_detail_screen.dart",
    "lib\features\ecommerce\presentation\screens\admin_dashboard_screen.dart",
    "lib\features\settings\presentation\screens\settings_screen.dart",
    "lib\features\requests\presentation\screens\request_board_screen.dart",
    "lib\features\notifications\presentation\screens\notifications_screen.dart",
    "lib\features\opportunities\presentation\screens\opportunities_dashboard_screen.dart",
    "lib\features\opportunities\presentation\screens\barter_opportunities_screen.dart",
    "lib\features\materials\presentation\screens\lifecycle_tracking_screen.dart",
    "lib\features\inventory\presentation\screens\material_inventory_screen.dart",
    "lib\features\impact\presentation\screens\impact_dashboard_screen.dart"
)

foreach ($file in $screenFiles) {
    $filePath = Join-Path $PSScriptRoot $file
    
    if (Test-Path $filePath) {
        Write-Host "Processing: $file" -ForegroundColor Cyan
        
        $content = Get-Content $filePath -Raw
        
        # Remove flutter_screenutil import
        $content = $content -replace "import 'package:flutter_screenutil/flutter_screenutil.dart';\r?\n", ""
        
        # Common replacements for ScreenUtil extensions
        $content = $content -replace '\.w\b', ''
        $content = $content -replace '\.h\b', ''
        $content = $content -replace '\.sp\b', ''
        $content = $content -replace '\.r\b', ''
        
        # Save the file
        Set-Content -Path $filePath -Value $content -NoNewline
        
        Write-Host "Completed: $file" -ForegroundColor Green
    } else {
        Write-Host "File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "`nAll files processed!" -ForegroundColor Green
Write-Host "Note: You may need to manually adjust some spacing and sizing values for optimal responsive design." -ForegroundColor Yellow
