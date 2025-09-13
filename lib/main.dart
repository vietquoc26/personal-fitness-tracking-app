import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const MainShell(),
    );
  }
}

/// GLOBAL STATE (keeps workouts, meals, notes shared across screens)
class AppState extends ChangeNotifier {
  final List<Workout> workouts = [];
  final List<Meal> meals = [];
  final List<Note> notes = [];

  void addWorkout(Workout w) {
    workouts.add(w);
    notifyListeners();
  }

  void addMeal(Meal m) {
    meals.add(m);
    notifyListeners();
  }

  void addNote(Note n) {
    notes.insert(0, n);
    notifyListeners();
  }
}

/// ROOT WITH BOTTOM NAVIGATION
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final AppState appState = AppState();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(appState: appState),
      WorkoutScreen(appState: appState),
      NutritionScreen(appState: appState),
      NotesScreen(appState: appState),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Nutrition"),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

//
// MODELS
//
class Workout {
  final String type;
  final double distance; // km
  final double duration; // hours
  final int steps;
  final DateTime date;

  Workout({
    required this.type,
    required this.distance,
    required this.duration,
    required this.steps,
    required this.date,
  });
}

class Meal {
  final String meal;
  final int calories;
  final DateTime date;

  Meal({required this.meal, required this.calories, required this.date});
}

class Note {
  final String text;
  final DateTime date;

  Note({required this.text, required this.date});
}

//
// HOME / DASHBOARD
//
class DashboardScreen extends StatelessWidget {
  final AppState appState;
  const DashboardScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    int totalSteps = appState.workouts.fold(0, (sum, w) => sum + w.steps);
    int consumedCalories = appState.meals.fold(0, (sum, m) => sum + m.calories);
    String latestNote =
        appState.notes.isNotEmpty ? appState.notes.first.text : "No notes yet";

    final todayQuote = [
      "Stay consistent! 💪 Even 15 minutes counts.",
      "Discipline beats motivation. Show up!",
      "One step at a time. Progress is progress.",
      "Your only limit is you. Keep pushing!"
    ][DateTime.now().day % 4];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Good Morning 👋",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    Text("Ho Viet",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Steps
            Text("Total Steps",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text("$totalSteps",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // Nutrition Progress
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nutrition",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: consumedCalories / 2000,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text("$consumedCalories / 2000 kcal consumed"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Latest Note
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.note_alt_outlined, color: Colors.blue),
                title: Text(latestNote,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),

            const SizedBox(height: 20),

            // Motivation
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.deepPurple[50],
              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
                title: Text(todayQuote),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// WORKOUTS
//
class WorkoutScreen extends StatelessWidget {
  final AppState appState;
  const WorkoutScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Workouts")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.workouts.length,
        itemBuilder: (context, index) {
          final w = appState.workouts[index];
          return Card(
            child: ListTile(
              leading: Icon(
                w.type == "Run" ? Icons.directions_run : Icons.directions_bike,
                color: Colors.deepPurple,
              ),
              title: Text("${w.type} - ${w.distance} km"),
              subtitle: Text("${w.duration} h • ${w.steps} steps"),
              trailing: Text(DateFormat("MMM d").format(w.date)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final workout = await showDialog<Workout>(
            context: context,
            builder: (_) => const StartWorkoutDialog(),
          );
          if (workout != null) {
            appState.addWorkout(workout);
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StartWorkoutDialog extends StatefulWidget {
  const StartWorkoutDialog({super.key});

  @override
  State<StartWorkoutDialog> createState() => _StartWorkoutDialogState();
}

class _StartWorkoutDialogState extends State<StartWorkoutDialog> {
  int seconds = 10;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Workout Timer"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$seconds s remaining",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (10 - seconds) / 10,
            color: Colors.deepPurple,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              Workout(
                type: "Run",
                distance: Random().nextDouble() * 5,
                duration: Random().nextDouble() * 1.5,
                steps: Random().nextInt(5000) + 1000,
                date: DateTime.now(),
              ),
            );
          },
          child: const Text("Finish"),
        ),
      ],
    );
  }
}

//
// NUTRITION
//
class NutritionScreen extends StatelessWidget {
  final AppState appState;
  const NutritionScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    int consumed = appState.meals.fold(0, (sum, m) => sum + m.calories);

    return Scaffold(
      appBar: AppBar(title: const Text("Nutrition")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: consumed / 2000,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text("$consumed / 2000 kcal consumed"),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: appState.meals.map((m) {
                  return Card(
                    child: ListTile(
                      title: Text(m.meal),
                      subtitle: Text("${m.calories} kcal"),
                      trailing: Text(DateFormat("hh:mm a").format(m.date)),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final meal = await showDialog<Meal>(
            context: context,
            builder: (_) => const AddMealDialog(),
          );
          if (meal != null) appState.addMeal(meal);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddMealDialog extends StatefulWidget {
  const AddMealDialog({super.key});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final mealCtrl = TextEditingController();
  final calCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Meal"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: mealCtrl, decoration: const InputDecoration(labelText: "Meal")),
          TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Calories")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              Meal(meal: mealCtrl.text, calories: int.tryParse(calCtrl.text) ?? 0, date: DateTime.now()),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

//
// NOTES
//
class NotesScreen extends StatelessWidget {
  final AppState appState;
  const NotesScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.notes.length,
        itemBuilder: (context, index) {
          final n = appState.notes[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.note, color: Colors.blue),
              title: Text(n.text),
              subtitle: Text(DateFormat("MMM d, hh:mm a").format(n.date)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final note = await showDialog<Note>(
            context: context,
            builder: (_) => const AddNoteDialog(),
          );
          if (note != null) appState.addNote(note);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Note"),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "Note")),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, Note(text: ctrl.text, date: DateTime.now()));
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

//
// PROFILE
//
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50, backgroundImage: AssetImage("assets/profile.jpg")),
          SizedBox(height: 16),
          Text("Ho Viet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Account Manager & Fitness Enthusiast"),
        ],
      ),
    );
  }
}
