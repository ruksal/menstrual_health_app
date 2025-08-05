import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MenstrualApp());

class MenstrualApp extends StatelessWidget {
  const MenstrualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🌸 Menstrual Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: const Color(0xFF18122B),
        colorScheme: ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.purpleAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D3250),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.pinkAccent),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> labelDescriptions = {
    'Oligomenorrhea': 'Infrequent periods (cycle > 35 days)',
    'Polymenorrhea': 'Frequent periods (cycle < 21 days)',
    'Menorrhagia': 'Heavy or prolonged menstrual bleeding',
    'Amenorrhea': 'No periods for 3 or more months',
    'Intermenstrual': 'Bleeding or spotting between periods',
  };

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
  String cycleHistory = '28,29,30,31,27,28,29,26,32,30,31';

  String conditionResult = '';
  String anomalyResult = '';
  bool loading = false;
  String errorMsg = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _submitForm() async {
    setState(() {
      loading = true;
      errorMsg = '';
    });
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

        if (condData["error"] != null) {
          setState(() {
            errorMsg = "❌ ${condData["error"]}";
            loading = false;
          });
          return;
        }
        if (cycleData["error"] != null) {
          setState(() {
            errorMsg = "❌ ${cycleData["error"]}";
            loading = false;
          });
          return;
        }

        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
          condData['result'],
        );

        setState(() {
          final List<String> detected = resultMap.entries
              .where((e) => e.value == 1)
              .map(
                (e) =>
                    '• ${e.key}: ${labelDescriptions[e.key] ?? "Description not available"}',
              )
              .toList();

          conditionResult = detected.isEmpty
              ? "No abnormal condition detected 🎉"
              : detected.join('\n');

          anomalyResult =
              "📈 Next cycle prediction: ${cycleData['predicted']}\n🚨 Anomaly: ${cycleData['anomaly'] ? "Yes ⚠️" : "No"}";
          loading = false;
        });
      } else {
        setState(() {
          errorMsg = "❌ Error: Could not get predictions.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "❌ Exception: ${e.toString()}";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌸 Menstrual Health Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: "Results"),
            Tab(icon: Icon(Icons.history), text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildResultsTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: _buildFormCard(),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator(color: Colors.pinkAccent)
                  : errorMsg.isNotEmpty
                  ? _buildErrorCard(errorMsg)
                  : Column(
                      children: [
                        _buildResultCard(
                          "🩸 Condition Results",
                          conditionResult,
                        ),
                        _buildResultCard("📊 Anomaly Detection", anomalyResult),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: const Color(0xFF2D3250),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      "Age",
                      age,
                      (val) => age = int.parse(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      "BMI",
                      bmi,
                      (val) => bmi = double.parse(val),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown("Life Stage", lifeStage, [
                      "adolescent",
                      "reproductive",
                      "perimenopausal",
                      "postmenopausal",
                    ], (val) => lifeStage = val!),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      "Tracking Duration",
                      trackingDuration,
                      (val) => trackingDuration = int.parse(val),
                    ),
                  ),
                ],
              ),
              _buildSlider(
                "Pain Score",
                painScore,
                0,
                5,
                (val) => painScore = val.toInt(),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      "Avg Cycle Length",
                      avgCycleLength,
                      (val) => avgCycleLength = double.parse(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      "Cycle Variation",
                      cycleVariation,
                      (val) => cycleVariation = double.parse(val),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      "Avg Bleeding Days",
                      avgBleedingDays,
                      (val) => avgBleedingDays = double.parse(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSlider(
                      "Bleeding Volume Score",
                      bleedingScore,
                      0,
                      3,
                      (val) => bleedingScore = val.toInt(),
                    ),
                  ),
                ],
              ),
              _buildSlider(
                "Intermenstrual Episodes",
                interEpisodes,
                0,
                10,
                (val) => interEpisodes = val.toInt(),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      "Variation Coefficient",
                      variationCoeff,
                      (val) => variationCoeff = double.parse(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      "Disruption Score",
                      disruptionScore,
                      (val) => disruptionScore = double.parse(val),
                    ),
                  ),
                ],
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                initialValue: cycleHistory,
                decoration: const InputDecoration(
                  labelText: "Cycle History (comma-separated)",
                  prefixIcon: Icon(Icons.timeline, color: Colors.pinkAccent),
                ),
                onChanged: (val) => cycleHistory = val,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: loading ? null : _submitForm,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    "Check Health",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String result) {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
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
        style: const TextStyle(color: Colors.white),
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
        dropdownColor: const Color(0xFF2D3250),
        style: const TextStyle(color: Colors.white),
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
        Text("$label: $value", style: const TextStyle(color: Colors.white70)),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: value.toString(),
          activeColor: Colors.pinkAccent,
          onChanged: (val) => setState(() => onChanged(val)),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    // Placeholder for future history feature
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 60, color: Colors.pinkAccent),
          SizedBox(height: 20),
          Text(
            "Cycle history and previous results will appear here.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
