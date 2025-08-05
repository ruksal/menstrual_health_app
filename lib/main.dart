import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MenstrualApp());

class MenstrualApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menstrual Health Checker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.pink,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pinkAccent),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
      ),
      home: MenstrualForm(),
    );
  }
}

class MenstrualForm extends StatefulWidget {
  @override
  _MenstrualFormState createState() => _MenstrualFormState();
}

class _MenstrualFormState extends State<MenstrualForm> {
  final _formKey = GlobalKey<FormState>();

  int age = 25;
  double bmi = 22.5;
  String lifeStage = 'reproductive';
  int trackingDuration = 12;
  int painScore = 2;
  double avgCycleLength = 28.0;
  double cycleVariation = 3.0;
  double avgBleedingDays = 5.0;
  int bleedingScore = 1;
  int interEpisodes = 0;
  double variationCoeff = 15.0;
  double disruptionScore = 40.0;
  String cycleHistory = '28,29,30,31,27,28,29,26,32,30,31,28,29,30,31';

  String conditionResult = '';
  String anomalyResult = '';

  Future<void> _submitForm() async {
    final Map<String, dynamic> data = {
      "age": age,
      "bmi": bmi,
      "life_stage": lifeStage,
      "tracking_duration": trackingDuration,
      "pain_score": painScore,
      "avg_cycle_length": avgCycleLength,
      "cycle_length_variation": cycleVariation,
      "avg_bleeding_days": avgBleedingDays,
      "bleeding_volume_score": bleedingScore,
      "intermenstrual_episodes": interEpisodes,
      "cycle_variation_coeff": variationCoeff,
      "pattern_disruption_score": disruptionScore,
      "cycle_history": cycleHistory,
    };

    final uri1 = Uri.parse('http://localhost:5000/predict-condition');
    final uri2 = Uri.parse('http://localhost:5000/predict-cycle-anomaly');

    try {
      final condRes = await http.post(
        uri1,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
      final cycleRes = await http.post(
        uri2,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (condRes.statusCode == 200 && cycleRes.statusCode == 200) {
        final condData = jsonDecode(condRes.body);
        final cycleData = jsonDecode(cycleRes.body);

        setState(() {
          setState(() {
            final resultMap = Map<String, dynamic>.from(condData['result']);
            conditionResult = resultMap.entries
                .map((e) => '• ${e.key}: ${e.value}')
                .join('\n');
          });

          anomalyResult =
              'Next cycle: ${cycleData['predicted']}\nAnomaly: ${cycleData['anomaly'] ? "Yes ⚠️" : "No"}';
        });
      } else {
        setState(() {
          conditionResult = "Error: Could not get predictions.";
        });
      }
    } catch (e) {
      setState(() {
        conditionResult = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🌸 Menstrual Checker"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600), // max width in pixels
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildCard([
                    _buildNumberField(
                      "Age",
                      age,
                      (val) => age = int.parse(val),
                    ),
                    _buildNumberField(
                      "BMI",
                      bmi,
                      (val) => bmi = double.parse(val),
                    ),
                    _buildDropdown("Life Stage", lifeStage, [
                      "adolescent",
                      "reproductive",
                      "perimenopausal",
                      "postmenopausal",
                    ], (val) => lifeStage = val!),
                    _buildNumberField(
                      "Tracking Duration",
                      trackingDuration,
                      (val) => trackingDuration = int.parse(val),
                    ),
                  ]),
                  _buildCard([
                    _buildSlider(
                      "Pain Score",
                      painScore,
                      0,
                      5,
                      (val) => painScore = val.toInt(),
                    ),
                    _buildNumberField(
                      "Avg Cycle Length",
                      avgCycleLength,
                      (val) => avgCycleLength = double.parse(val),
                    ),
                    _buildNumberField(
                      "Cycle Variation",
                      cycleVariation,
                      (val) => cycleVariation = double.parse(val),
                    ),
                    _buildNumberField(
                      "Avg Bleeding Days",
                      avgBleedingDays,
                      (val) => avgBleedingDays = double.parse(val),
                    ),
                    _buildSlider(
                      "Bleeding Volume Score",
                      bleedingScore,
                      0,
                      3,
                      (val) => bleedingScore = val.toInt(),
                    ),
                    _buildSlider(
                      "Intermenstrual Episodes",
                      interEpisodes,
                      0,
                      10,
                      (val) => interEpisodes = val.toInt(),
                    ),
                  ]),
                  _buildCard([
                    _buildNumberField(
                      "Variation Coefficient",
                      variationCoeff,
                      (val) => variationCoeff = double.parse(val),
                    ),
                    _buildNumberField(
                      "Disruption Score",
                      disruptionScore,
                      (val) => disruptionScore = double.parse(val),
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      initialValue: cycleHistory,
                      decoration: InputDecoration(
                        labelText: "Cycle History (comma-separated)",
                      ),
                      onChanged: (val) => cycleHistory = val,
                    ),
                  ]),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildResultCard("Condition Result", conditionResult),
                  _buildResultCard("Anomaly Detection", anomalyResult),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildResultCard(String title, String result) {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(result, style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    dynamic value,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField(
        value: value,
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        dropdownColor: Color(0xFF1E1E1E),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value", style: TextStyle(color: Colors.white70)),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: value.toString(),
          activeColor: Colors.pinkAccent,
          onChanged: (val) => setState(() {
            onChanged(val);
          }),
        ),
      ],
    );
  }
}
