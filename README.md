# PowerFlick

A modern energy management application that helps users monitor and control their home's energy consumption. Built with Flutter and Supabase.

## Features

- 🔐 Secure authentication with Supabase
- 🏠 Smart home management
- 📊 Real-time energy monitoring
- 💡 Device control and automation
- 📱 Cross-platform support

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Supabase account
- PostgreSQL database
- Google Cloud project (for Google Sign-in)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/powerflick.git
   cd powerflick
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Create a new Supabase project
   - Set up the database using the schema in `docs/database/schema.sql`
   - Update `lib/core/constants/k_supabase.dart` with your credentials

4. Run the app:
   ```bash
   flutter run
   ```

## Documentation

- [User Guide](docs/README.md)
- [Technical Documentation](docs/TECHNICAL.md)
- [Database Schema](docs/database/schema.sql)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- All contributors who have helped shape this project
