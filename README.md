# Flutter No-Code Builder - Frontend Application

A comprehensive Flutter frontend application for the Flutter No-Code Builder platform. This application allows users to visually create Flutter applications without writing code.

## 🚀 Features

- **Visual App Builder**: Drag-and-drop interface for building Flutter UIs
- **Theme Management**: Create and customize color themes
- **Screen Designer**: Design multiple screens with navigation
- **Widget Library**: Extensive collection of Flutter widgets
- **Data Source Configuration**: Connect to APIs and manage data
- **Build System**: Generate Flutter code and build APK files
- **Template Library**: Pre-built app templates (E-commerce, Social Media, News, Recipe, Marketplace)
- **Real-time Preview**: See your changes instantly
- **Export/Import**: Export applications as JSON for backup or sharing

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- A running instance of the Django backend server

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd flutter_nocode_frontend
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Backend URL

Update the backend URL in `lib/core/constants/api_endpoints.dart`:

```dart
class ApiEndpoints {
  // Update this with your actual backend URL
  static const String baseUrl = 'https://your-backend-url.com';
  // ... rest of the code
}
```

### 4. Generate Model Files

Since we're using json_serializable, you need to generate the model files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Create Required Directories

```bash
mkdir -p assets/images
mkdir -p assets/fonts
```

### 6. Add Fonts (Optional)

If you want to use custom fonts, download Poppins font family and add to `assets/fonts/`:
- Poppins-Regular.ttf
- Poppins-Medium.ttf
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf

## 🏃‍♂️ Running the Application

### Development Mode

```bash
flutter run
```

### Web Version

```bash
flutter run -d chrome
```

### Mobile (Android)

```bash
flutter run -d <device-id>
```

To list available devices:
```bash
flutter devices
```

## 📱 Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                     # App entry point
├── app.dart                       # Main app configuration
│
├── core/                         # Core functionality
│   ├── constants/                # App constants
│   ├── utils/                    # Utility functions
│   └── widgets/                  # Reusable widgets
│
├── data/                         # Data layer
│   ├── models/                   # Data models
│   ├── repositories/             # Data repositories
│   └── services/                 # API services
│
├── presentation/                 # UI layer
│   ├── auth/                     # Authentication screens
│   ├── dashboard/                # Dashboard
│   ├── applications/             # Application management
│   ├── builder/                  # Visual builder
│   ├── themes/                   # Theme management
│   └── build/                    # Build management
│
└── providers/                    # State management
```

## 🔑 Authentication

The app uses JWT authentication. Users need to register/login to access the builder features.

### Default Test Credentials

If your backend has test users:
```
Username: testuser
Password: testpass123
```

## 🎨 Customization

### Changing App Colors

Edit `lib/core/constants/app_colors.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);  // Change primary color
  static const Color accent = Color(0xFFFF4081);   // Change accent color
  // ... other colors
}
```

### Changing App Name

1. Update `lib/core/constants/app_strings.dart`
2. Update `pubspec.yaml` name field
3. Update Android app name in `android/app/src/main/AndroidManifest.xml`
4. Update iOS app name in `ios/Runner/Info.plist`

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter test integration_test
```

## 🐛 Debugging

### Enable Debug Mode

The app shows detailed logs in debug mode. To see API calls:

1. Check the console output when running the app
2. API requests and responses are logged automatically

### Common Issues

**Issue**: Connection refused error
**Solution**: Make sure your backend server is running and the URL is correct

**Issue**: Build fails with "pub get" error
**Solution**: Run `flutter clean` then `flutter pub get`

**Issue**: Model generation fails
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

## 📦 Dependencies

Key packages used in this project:

- **provider**: State management
- **go_router**: Navigation and routing
- **dio**: HTTP client for API calls
- **flutter_colorpicker**: Color picker for theme editor
- **fl_chart**: Charts and visualizations
- **json_annotation**: JSON serialization
- **flutter_secure_storage**: Secure token storage

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
- Create an issue in the GitHub repository
- Contact the development team

## 🔄 API Integration

The frontend expects the following API endpoints to be available:

### Authentication
- POST `/api/auth/login/`
- POST `/api/auth/register/`
- POST `/api/auth/logout/`
- POST `/api/auth/refresh/`

### Applications
- GET/POST `/api/v1/applications/`
- GET/PUT/DELETE `/api/v1/applications/{id}/`
- POST `/api/v1/applications/{id}/build/`
- POST `/api/v1/applications/{id}/clone/`

### Screens & Widgets
- GET/POST `/api/v1/screens/`
- GET/POST `/api/v1/widgets/`
- GET/POST `/api/v1/widget-properties/`

### Themes
- GET/POST `/api/v1/themes/`
- GET `/api/v1/themes/templates/`

### Data Sources
- GET/POST `/api/v1/data-sources/`
- GET/POST `/api/v1/data-source-fields/`

## 🚀 Deployment

### Web Deployment (Firebase Hosting)

1. Build the web version:
```bash
flutter build web --release
```

2. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

3. Initialize Firebase:
```bash
firebase init hosting
```

4. Deploy:
```bash
firebase deploy
```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```bash
docker build -t flutter-nocode-frontend .
docker run -p 8080:80 flutter-nocode-frontend
```

## 📊 Performance Optimization

1. **Enable code splitting**: Already configured with go_router
2. **Optimize images**: Use WebP format for better compression
3. **Enable caching**: Dio cache interceptor is already configured
4. **Lazy loading**: Screens are loaded on demand

## 🔐 Security Best Practices

1. **Secure Storage**: Tokens are stored using flutter_secure_storage
2. **HTTPS Only**: Ensure backend uses HTTPS in production
3. **Input Validation**: All forms have validation
4. **Token Refresh**: Automatic token refresh is implemented

## 🎯 Roadmap

- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Dark mode toggle
- [ ] Advanced widget properties
- [ ] Custom widget creation
- [ ] Team collaboration features
- [ ] Version control for applications
- [ ] Plugin marketplace

## 💡 Tips

1. **Hot Reload**: Use `r` in terminal for hot reload during development
2. **Widget Inspector**: Use Flutter Inspector in VS Code/Android Studio
3. **Performance Profiling**: Use Flutter DevTools for performance analysis
4. **State Management**: The app uses Provider for state management