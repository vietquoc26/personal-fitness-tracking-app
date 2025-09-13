# Fitly - Fitness Tracking App

## Overview
Fitly is a Flutter web application for personal fitness tracking. It features a dashboard, workout management, calendar scheduling, calorie counter, and notes system. The app provides a modern, interactive UI with light/dark theme support.

## Project Setup
- **Language**: Dart with Flutter framework
- **Target Platform**: Web application
- **Port**: 5000 (configured for Replit environment)
- **Development Server**: Flutter web server with host 0.0.0.0

## Recent Changes (September 13, 2025)
- Converted single-file Dart project to proper Flutter project structure
- Created `pubspec.yaml` with Flutter dependencies
- Moved `main.dart` to `lib/` directory following Flutter conventions
- Created `web/` directory with proper index.html and manifest.json
- Fixed syntax errors in main.dart (escaped apostrophes, fixed keyboardType parameter)
- Configured Flutter web development server for Replit proxy compatibility
- Set up deployment configuration for autoscale hosting

## Project Architecture
### File Structure
```
/
├── lib/
│   └── main.dart          # Main Flutter application code
├── web/
│   ├── index.html         # Web entry point
│   └── manifest.json      # PWA manifest
├── pubspec.yaml           # Flutter dependencies
└── replit.md             # Project documentation
```

### Key Features
- **Dashboard**: Progress tracking with stats and charts
- **Workouts**: Filterable workout library with custom exercise creation
- **Calendar**: Monthly view with workout scheduling
- **Nutrition**: Calorie tracking and meal logging
- **Notes**: Personal fitness notes and observations
- **Responsive Design**: Works across different screen sizes
- **Theme Support**: Light and dark mode toggle

### Technical Stack
- Flutter 3.32.0
- Dart 3.8.1
- Material Design 3
- Custom painting for charts
- In-memory state management

## User Preferences
- None specified yet

## Development Notes
- App is configured to run on port 5000 for Replit environment
- Uses Flutter web server with hostname 0.0.0.0 for proxy compatibility
- Deployment configured for autoscale with build and release commands
- No external dependencies beyond standard Flutter packages