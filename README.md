# Menstrual Health App

A comprehensive Flutter application with AI-powered backend for menstrual health monitoring and condition prediction. This app helps users track their menstrual cycles and provides intelligent insights about potential health conditions.

## 🌟 Features

### Frontend (Flutter)
- **Modern Dark UI**: Beautiful dark theme with pink accent colors
- **Comprehensive Health Form**: Collects detailed menstrual health data
- **Real-time Predictions**: Instant feedback on health conditions
- **Cross-platform**: Works on Android, iOS, Web, and Desktop

### Backend (Flask + AI)
- **Condition Classification**: Predicts 5 different menstrual conditions:
  - Oligomenorrhea (infrequent periods)
  - Polymenorrhea (frequent periods)
  - Menorrhagia (heavy bleeding)
  - Amenorrhea (absence of periods)
  - Intermenstrual bleeding
- **Cycle Anomaly Detection**: Uses LSTM model to detect unusual cycle patterns
- **Life Stage Analysis**: Considers different life stages (adolescent, reproductive, perimenopausal, postmenopausal)

## 🏗️ Architecture

```
menstrual_health_app/
├── lib/                    # Flutter frontend
│   └── main.dart          # Main app entry point
├── backend/               # Python Flask backend
│   ├── app.py            # Main Flask application
│   ├── models/           # AI models and scalers
│   └── requirements.txt  # Python dependencies
└── [platform folders]    # Platform-specific configurations
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (^3.8.1)
- Python 3.8+
- Git

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the Flask server:**
   ```bash
   python app.py
   ```
   The backend will run on `http://localhost:5000`

### Frontend Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## 📱 Usage

1. **Launch the app** - You'll see a comprehensive health form
2. **Fill in your details**:
   - Age and BMI
   - Life stage (adolescent, reproductive, perimenopausal, postmenopausal)
   - Tracking duration and pain scores
   - Cycle length and variation data
   - Bleeding patterns and volume
   - Cycle history (comma-separated values)
3. **Submit the form** - Get instant predictions for:
   - Potential menstrual conditions
   - Cycle anomaly detection

## 🔧 Configuration

### Backend Configuration
- **Port**: Default 5000 (configurable in `app.py`)
- **CORS**: Enabled for cross-origin requests
- **Models**: Pre-trained models stored in `backend/models/`

### Frontend Configuration
- **API Endpoint**: Configured to `localhost:5000`
- **Theme**: Dark theme with pink accent colors
- **Form Validation**: Built-in validation for all inputs

## 🤖 AI Models

The backend uses two main AI models:

1. **Menstrual Condition Classifier** (`menstrual_condition_classifier.pkl`)
   - Predicts 5 different menstrual conditions
   - Uses features like age, BMI, cycle patterns, pain scores

2. **LSTM Cycle Anomaly Detector** (`cycle_anomaly_lstm_model.h5`)
   - Detects unusual patterns in cycle history
   - Requires minimum 10 cycle entries
   - Uses time series analysis

## 📊 Data Patterns & Condition Indicators

Based on the AI model features, here are the data patterns that typically indicate each condition:

### 🔍 **Oligomenorrhea** (Infrequent Periods)
- **Cycle Length**: >35 days average
- **Cycle Variation**: High variation (>7 days)
- **Life Stage**: Often adolescent or perimenopausal
- **Pattern Disruption**: High disruption scores
- **Tracking Duration**: Longer tracking periods show patterns

### 🔍 **Polymenorrhea** (Frequent Periods)
- **Cycle Length**: <21 days average
- **Cycle Variation**: Low to moderate variation
- **Bleeding Days**: Shorter bleeding periods (2-3 days)
- **Life Stage**: Often reproductive age
- **Pain Score**: Usually low to moderate

### 🔍 **Menorrhagia** (Heavy Bleeding)
- **Bleeding Volume Score**: High scores (3-4)
- **Bleeding Days**: Longer periods (7+ days)
- **Pain Score**: High pain scores (3-4)
- **Age**: Often reproductive age
- **BMI**: May be related to weight factors

### 🔍 **Amenorrhea** (Absence of Periods)
- **Cycle Length**: No recent cycles
- **Life Stage**: Often adolescent or postmenopausal
- **Age**: Very young (<16) or older (>45)
- **BMI**: Extreme values (very low or very high)
- **Pattern Disruption**: Very high disruption scores

### 🔍 **Intermenstrual Bleeding**
- **Intermenstrual Episodes**: >0 episodes
- **Cycle Variation**: High variation
- **Bleeding Volume**: Variable scores
- **Pain Score**: Moderate to high
- **Life Stage**: Often reproductive age

### 🔍 **Cycle Anomaly Detection**
- **Unusual Patterns**: Cycles that deviate >2 standard deviations from mean
- **Sudden Changes**: Abrupt changes in cycle length
- **Inconsistent Patterns**: Irregular cycle lengths over time
- **Minimum Data**: Requires at least 10 cycle entries for accurate detection

## 📊 API Endpoints

### POST `/predict-condition`
Predicts menstrual health conditions based on user data.

**Request Body:**
```json
{
  "age": 25,
  "bmi": 22.5,
  "life_stage": "reproductive",
  "tracking_duration": 12,
  "pain_score": 2,
  "avg_cycle_length": 28.0,
  "cycle_length_variation": 3.0,
  "avg_bleeding_days": 5.0,
  "bleeding_volume_score": 1,
  "intermenstrual_episodes": 0,
  "cycle_variation_coeff": 15.0,
  "pattern_disruption_score": 40.0
}
```

**Response:**
```json
{
  "result": {
    "Oligomenorrhea": 0,
    "Polymenorrhea": 0,
    "Menorrhagia": 0,
    "Amenorrhea": 0,
    "Intermenstrual": 0
  }
}
```

### POST `/predict-cycle-anomaly`
Detects anomalies in cycle patterns using LSTM model.

**Request Body:**
```json
{
  "cycle_history": "28,29,30,31,27,28,29,26,32,30,31,28,29,30,31"
}
```

**Response:**
```json
{
  "predicted": 29.5,
  "anomaly": false
}
```

## 🛠️ Development

### Adding New Features
1. **Backend**: Add new endpoints in `backend/app.py`
2. **Frontend**: Create new widgets in `lib/` directory
3. **Models**: Train new models and add to `backend/models/`

### Testing
```bash
# Test Flutter app
flutter test

# Test backend (manual testing)
curl -X POST http://localhost:5000/predict-condition \
  -H "Content-Type: application/json" \
  -d '{"age": 25, "bmi": 22.5, ...}'
```

## 📦 Dependencies

### Frontend Dependencies
- `flutter`: ^3.8.1
- `http`: ^0.13.6
- `flutter_form_builder`: ^9.1.1
- `cupertino_icons`: ^1.0.8

### Backend Dependencies
- `Flask`: 2.3.2
- `flask-cors`: 3.0.10
- `numpy`: 1.24.4
- `pandas`: 2.0.3
- `joblib`: 1.3.2
- `scikit-learn`: 1.3.0
- `tensorflow`: 2.13.0

## 🚀 Deployment

### Backend Deployment
The backend includes a `render.yaml` file for easy deployment on Render:
```bash
# Deploy to Render
git push origin main
```

### Frontend Deployment
```bash
# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🆘 Support

If you encounter any issues:
1. Check the console logs for error messages
2. Ensure both backend and frontend are running
3. Verify API endpoints are accessible
4. Check Flutter and Python dependencies are installed correctly

## 🔮 Future Enhancements

- [ ] User authentication and data persistence
- [ ] Push notifications for cycle tracking
- [ ] Integration with health apps
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Offline mode support

---

**Note**: This app is for educational and informational purposes only. It should not replace professional medical advice. Always consult with healthcare providers for medical concerns.
