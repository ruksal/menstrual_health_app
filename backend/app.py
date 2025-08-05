from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
from tensorflow.keras.models import load_model

app = Flask(__name__)
CORS(app)  # allows requests from frontend (Flutter)

# Load models and scalers
clf = joblib.load("models/menstrual_condition_classifier.pkl")
lstm_model = load_model("models/cycle_anomaly_lstm_model.h5")
ts_scaler = joblib.load("models/lstm_timeseries_scaler.pkl")

LABELS = ['Oligomenorrhea', 'Polymenorrhea', 'Menorrhagia', 'Amenorrhea', 'Intermenstrual']
STAGES = ["adolescent", "reproductive", "perimenopausal", "postmenopausal"]

LABEL_DESCRIPTIONS = {
    'Oligomenorrhea': 'Infrequent periods (cycle > 35 days)',
    'Polymenorrhea': 'Frequent periods (cycle < 21 days)',
    'Menorrhagia': 'Heavy or prolonged menstrual bleeding',
    'Amenorrhea': 'No periods for 3 or more months',
    'Intermenstrual': 'Bleeding or spotting between periods'
}

@app.route("/predict-condition", methods=["POST"])
def predict_condition():
    data = request.json

    try:
        # Encode life stage
        life_stage_encoded = STAGES.index(data["life_stage"])

        features = np.array([[data["age"], data["bmi"], life_stage_encoded,
                              data["tracking_duration"], data["pain_score"],
                              data["avg_cycle_length"], data["cycle_length_variation"],
                              data["avg_bleeding_days"], data["bleeding_volume_score"],
                              data["intermenstrual_episodes"], data["cycle_variation_coeff"],
                              data["pattern_disruption_score"]]])

        preds = clf.predict(features)[0]  # Use features directly

        result = {label: int(pred) for label, pred in zip(LABELS, preds)}
        return jsonify({"result": result})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/predict-cycle-anomaly", methods=["POST"])
def predict_anomaly():
    data = request.json

    try:
        # Parse cycle history
        series = np.array([float(x.strip()) for x in data["cycle_history"].split(",")])
        if len(series) < 10:
            return jsonify({"error": "Minimum 10 cycle entries required."}), 400

        series_scaled = ts_scaler.transform(series.reshape(-1, 1))
        window = series_scaled[-10:].reshape(1, 10, 1)
        pred_scaled = lstm_model.predict(window)[0][0]
        pred_unscaled = ts_scaler.inverse_transform([[pred_scaled]])[0][0]

        # Anomaly detection
        mean = np.mean(series)
        std = np.std(series)
        anomaly = abs(pred_unscaled - mean) > 2 * std

        return jsonify({
            "predicted": round(float(pred_unscaled), 2),
            "anomaly": bool(anomaly)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/")
def index():
    return "Menstrual API is running."


if __name__ == "__main__":
    app.run(debug=True, port=5000)
