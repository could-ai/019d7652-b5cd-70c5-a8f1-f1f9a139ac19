# NzaroMill Manager

A comprehensive Flutter application for managing industrial machinery maintenance, spare parts inventory, and replacement tracking.

## Features

- **Machine Management**: Track 4 industrial machines (Gongoni, Mikoroshini, Lebanoni, Buyuni) with status monitoring
- **Spare Parts Inventory**: Manage inventory with multi-machine compatibility, stock levels, and critical alerts
- **Replacement Recording**: Record maintenance activities with photo attachments and cost tracking
- **Reporting System**: Generate monthly cost reports, usage frequency analysis, and inventory status with charts
- **Real-time Sync**: Designed for multi-device access with cloud backend (Firebase/Supabase integration pending)

## Technical Stack

- Flutter with Material Design 3
- State management with Provider
- Chart visualization with Syncfusion Flutter Charts
- Image handling with Image Picker
- Industrial color scheme (Blue #1E3A8A, Orange #F97316)

## Getting Started

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## App Architecture

The app follows a modular structure with:
- Clean separation of data models, providers, and UI screens
- Mock data implementation ready for backend integration
- Responsive design for industrial use cases

## Future Enhancements

- Firebase/Supabase backend integration
- Authentication system with role-based access
- PDF/Excel export functionality
- Real-time notifications
- Advanced analytics and predictive maintenance