# AI-Powered Power Consumption Monitoring System

This project implements an AI-powered system for monitoring and predicting power consumption patterns. It uses LSTM neural networks for prediction and anomaly detection, with a modern web dashboard and mobile app for visualization.

## Features

- Real-time power consumption monitoring
- AI-powered consumption prediction for the next 24 hours
- Anomaly detection with severity classification
- Interactive dashboard with charts and metrics
- Mobile app for on-the-go monitoring
- Supabase integration for data storage and real-time updates

## Project Structure

```
.
├── backend/                 # Python FastAPI backend
│   ├── src/
│   │   ├── models/         # ML models
│   │   ├── services/       # Business logic
│   │   ├── utils/          # Helper utilities
│   │   └── database/       # Database clients
│   └── requirements.txt
├── web/                    # React dashboard
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── services/       # API clients
│   │   └── hooks/         # Custom hooks
│   └── package.json
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── services/      # API clients
│   │   └── widgets/       # UI widgets
│   └── pubspec.yaml
└── supabase/              # Database configuration
    ├── migrations/        # SQL migrations
    └── seed/             # Sample data
```

## Setup Instructions

### Prerequisites

- Python 3.9+
- Node.js 16+
- Flutter 3.0+
- Supabase account

### Backend Setup

1. Create a virtual environment:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # or `venv\Scripts\activate` on Windows
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. Run the server:
   ```bash
   uvicorn src.main:app --reload
   ```

### Web Dashboard Setup

1. Install dependencies:
   ```bash
   cd web
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your API and Supabase settings
   ```

3. Start the development server:
   ```bash
   npm start
   ```

### Mobile App Setup

1. Install dependencies:
   ```bash
   cd mobile
   flutter pub get
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your API and Supabase settings
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Database Setup

1. Create a new Supabase project

2. Run migrations:
   ```bash
   cd supabase
   supabase db push
   ```

3. Seed sample data:
   ```bash
   psql -h YOUR_DB_HOST -U postgres -d postgres -f seed/initial_data.sql
   ```

## API Documentation

The backend API documentation is available at `http://localhost:8000/docs` when running the server.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 