# PowerFlick Technical Documentation

## System Architecture

### 1. Frontend Architecture
The app is built using Flutter and follows a clean architecture pattern with the following layers:

#### Presentation Layer
- Located in `lib/powerflick/<feature>/presentation/`
- Contains UI components, pages, and widgets
- Uses Riverpod for state management
- Implements Material Design 3

#### Application Layer
- Located in `lib/powerflick/<feature>/application/`
- Contains business logic and state management
- Uses Riverpod providers and notifiers
- Handles async operations and error states

#### Domain Layer
- Located in `lib/powerflick/<feature>/domain/`
- Contains business models and interfaces
- Defines core business rules
- Independent of external frameworks

#### Infrastructure Layer
- Located in `lib/powerflick/<feature>/infrastructure/`
- Implements data sources and repositories
- Handles external service integration
- Manages data persistence

### 2. Backend Architecture

#### Supabase Integration
- Authentication using Supabase Auth
- Real-time database using PostgreSQL
- Storage for user data and assets
- Row Level Security (RLS) policies

#### Database Schema

##### Profiles Table
```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    birthdate DATE,
    home_type TEXT,
    household_size INTEGER,
    priorities TEXT[],
    rooms JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

##### Homes Table
```sql
CREATE TABLE homes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users NOT NULL,
    rooms JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

##### Devices Table
```sql
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    room_id UUID,
    status BOOLEAN DEFAULT false,
    power_consumption FLOAT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

##### MCP Messages Table
```sql
CREATE TABLE mcp_messages (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    sender_id VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### 3. Authentication Flow

1. User Signup Process:
   - User enters email and password
   - Validates email format and password requirements
   - Creates Supabase auth account
   - Creates initial profile record
   - Navigates to profile form

2. Profile Setup:
   - User enters name/nickname
   - Selects birthdate
   - Chooses home type (Apartment, House, Villa, etc.)
   - Sets household size
   - Selects energy priorities
   - Saves profile data to Supabase

3. Home Setup:
   - User selects rooms (Bedroom, Living Room, Kitchen, etc.)
   - Sets room counts
   - Configures room details
   - Saves home configuration to Supabase

4. Login Process:
   - User enters email and password
   - Validates credentials with Supabase
   - Retrieves user profile and home data
   - Navigates to dashboard

### 4. State Management

#### Riverpod Implementation
```dart
// Provider definition
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, AsyncValue<AuthState>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return LoginNotifier(supabase);
});

// State class
class AuthState {
  final AuthStatus status;
  final String? error;
  final User? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.user,
  });
}

// Notifier implementation
class LoginNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final SupabaseClient _supabase;

  LoginNotifier(this._supabase) : super(AsyncValue.data(const AuthState()));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(AuthState(
        status: AuthStatus.success,
        user: response.user,
      ));
    } catch (e) {
      state = AsyncValue.data(AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }
}
```

### 5. Home Management

#### Room Configuration
```dart
class Room {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> deviceIds;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.deviceIds = const [],
  });
}
```

#### Device Management
```dart
class Device {
  final String id;
  final String name;
  final String type;
  final String roomId;
  final bool status;
  final double? powerConsumption;
  final DateTime lastUpdated;
}
```

### 6. Error Handling

#### Global Error Handler
```dart
void handleError(dynamic error, StackTrace stackTrace) {
  Logger().e('Error occurred: $error');
  // Log to monitoring service
  // Show user-friendly error message
}
```

#### API Error Handling
```dart
try {
  final response = await _supabase.from('profiles').select();
  return response;
} catch (e) {
  Logger().e('Database error: $e');
  throw DatabaseException('Failed to fetch profiles');
}
```

### 7. Testing Strategy

#### Unit Tests
- Test business logic in application layer
- Mock external dependencies
- Test state management
- Verify error handling

#### Widget Tests
- Test UI components
- Verify user interactions
- Test navigation
- Check responsive design

#### Integration Tests
- Test feature workflows
- Verify API integration
- Test authentication flow
- Check data persistence

### 8. Performance Optimization

#### Image Optimization
- Use cached network images
- Implement lazy loading
- Optimize image sizes
- Use appropriate formats

#### State Management
- Minimize rebuilds
- Use const constructors
- Implement proper disposal
- Cache expensive computations

#### Network Optimization
- Implement request caching
- Use pagination
- Optimize payload size
- Handle offline mode

### 9. Security Measures

#### API Security
- Use environment variables for secrets
- Implement rate limiting
- Validate input data
- Sanitize output data

#### Data Security
- Encrypt sensitive data
- Implement proper authentication
- Use secure storage
- Follow GDPR guidelines

### 10. Deployment

#### Build Process
```bash
# Development
flutter run

# Production
flutter build apk --release
flutter build ios --release
flutter build web --release
```

#### CI/CD Pipeline
1. Run tests
2. Build app
3. Deploy to staging
4. Run integration tests
5. Deploy to production

## API Reference

### Authentication Endpoints
- POST /auth/signup
- POST /auth/login
- POST /auth/logout
- GET /auth/user

### Profile Endpoints
- GET /profiles/:id
- PUT /profiles/:id
- DELETE /profiles/:id

### Home Endpoints
- GET /homes/:id
- POST /homes
- PUT /homes/:id
- DELETE /homes/:id

### Device Endpoints
- GET /devices
- POST /devices
- PUT /devices/:id
- DELETE /devices/:id 