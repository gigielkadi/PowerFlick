# PowerFlick - Smart Energy Management App

## Overview
PowerFlick is a modern energy management application that helps users monitor and control their home's energy consumption. The app provides real-time insights, automated controls, and smart device management to optimize energy usage and reduce costs.

## Features

### 1. Authentication & User Management
- Email/Password authentication with Supabase
- Google Sign-in integration
- User profile management with:
  - Personal information (name, birthdate)
  - Home type selection (Apartment, House, Villa, etc.)
  - Household size configuration
  - Energy priorities setting
- Email verification system
- Secure session management

### 2. Home Setup & Management
- Room configuration:
  - Multiple room types (Bedroom, Living Room, Kitchen, etc.)
  - Room count management
  - Room-specific device organization
- Smart device integration:
  - Device discovery and pairing
  - Room-based device organization
  - Device status monitoring
  - Remote control capabilities
- Home type and size configuration
- Energy priority settings

### 3. Dashboard & Control Panel
- Real-time energy consumption monitoring
- Visual energy usage statistics
- Budget tracking and alerts
- CO2 savings tracking
- Quick controls for device management
- Room-based energy insights

### 4. Device Management
- Smart device integration
- Room-based device organization
- Device status monitoring
- Remote control capabilities
- Device grouping and automation
- Power consumption tracking

### 5. Automation Features
- Night mode automation
- Holiday mode settings
- Low power mode optimization
- Custom automation rules
- Schedule-based controls
- Room-specific automation

## Technical Architecture

### Frontend
- Built with Flutter for cross-platform compatibility
- Material Design 3 implementation
- Dark/Light theme support
- Responsive UI components
- State management using Riverpod
- Clean architecture pattern

### Backend
- Supabase for authentication and database
- PostgreSQL database for data storage
- Real-time data synchronization
- Row Level Security (RLS) policies
- Secure API endpoints

### Database Schema

#### Profiles Table
- User information (id, email, name)
- Personal details (birthdate)
- Home configuration (type, size)
- Energy preferences (priorities)
- Room settings (JSONB)

#### Homes Table
- Home details (id, user_id)
- Room configurations (JSONB)
- Creation and update timestamps

#### Devices Table
- Device information (id, name, type)
- Room association (room_id)
- Status and power consumption
- Timestamps for updates

#### MCP Messages Table
- Message tracking (id, type)
- Sender information
- Content storage (JSONB)
- Timestamp tracking

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Supabase account
- PostgreSQL database
- Google Cloud project (for Google Sign-in)

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Supabase:
   - Update `lib/core/constants/k_supabase.dart` with your credentials
   - Set up database tables using the schema in `docs/database/schema.sql`
4. Run the app:
   ```bash
   flutter run
   ```

## Development Guidelines

### Code Structure
```
lib/
  ├── core/
  │   ├── constants/
  │   ├── theme/
  │   └── routing/
  └── powerflick/
      └── <feature>/
          ├── application/
          ├── domain/
          ├── infrastructure/
          └── presentation/
```

### State Management
- Use Riverpod for state management
- Implement AsyncNotifier for async operations
- Follow unidirectional data flow
- Keep business logic in application layer

### UI Components
- Use Material Design 3 components
- Follow responsive design principles
- Implement dark/light theme support
- Use consistent spacing and typography

## Security Considerations
- Secure API key management
- User authentication with Supabase
- Row Level Security (RLS) policies
- Data encryption
- Input validation
- Error handling

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
[Your License Here]

## Support
For support, email [Your Support Email] 