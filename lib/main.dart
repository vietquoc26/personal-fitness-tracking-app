// main.dart
// Flutter single-file front-end for a personal fitness tracking app
// Features: Dashboard, Progress, Workout list (video placeholders), Calorie counter,
// Calendar scheduling, Notes & custom exercises. Modern, interactive UI.

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(FitlyApp());
}

class FitlyApp extends StatefulWidget {
  @override
  _FitlyAppState createState() => _FitlyAppState();
}

class _FitlyAppState extends State<FitlyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitly',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: MainShell(onToggleTheme: toggleTheme),
    );
  }
}

// --- Simple in-memory app state ---
class AppState extends ChangeNotifier {
  List<Workout> workouts = sampleWorkouts;
  Map<DateTime, List<ScheduledWorkout>> calendar = {};
  List<Note> notes = [];
  int caloriesGoal = 2000;
  int caloriesConsumed = 0;
  int totalMinutesThisWeek = 0;
  int workoutsFinished = 12;
  int workoutsInProgress = 1;

  void addNote(Note note) {
    notes.insert(0, note);
    notifyListeners();
  }

  void addCustomExercise(Workout w) {
    workouts.insert(0, w);
    notifyListeners();
  }

  void logCalories(int cals) {
    caloriesConsumed += cals;
    notifyListeners();
  }

  void scheduleWorkout(DateTime day, ScheduledWorkout sw) {
    final key = DateTime(day.year, day.month, day.day);
    calendar.putIfAbsent(key, () => []).add(sw);
    notifyListeners();
  }

  void markWorkoutDone() {
    workoutsFinished += 1;
    workoutsInProgress = max(0, workoutsInProgress - 1);
    notifyListeners();
  }
}

final AppState appState = AppState();

// --- Models ---
class Workout {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final String thumbnail; // asset or network
  final String videoUrl; // placeholder
  Workout({required this.id, required this.title, required this.category, required this.durationMinutes, required this.thumbnail, required this.videoUrl});
}

class ScheduledWorkout {
  final String workoutId;
  final String note;
  ScheduledWorkout({required this.workoutId, this.note = ''});
}

class Note {
  final DateTime time;
  final String text;
  Note({required this.time, required this.text});
}

// --- Sample data ---
final List<Workout> sampleWorkouts = [
  Workout(
    id: 'w1',
    title: 'Full Body HIIT',
    category: 'Cardio',
    durationMinutes: 20,
    thumbnail: '',
    videoUrl: '',
  ),
  Workout(
    id: 'w2',
    title: 'Upper Body Strength',
    category: 'Strength',
    durationMinutes: 30,
    thumbnail: '',
    videoUrl: '',
  ),
  Workout(
    id: 'w3',
    title: 'Yoga Flow',
    category: 'Mobility',
    durationMinutes: 25,
    thumbnail: '',
    videoUrl: '',
  ),
];

// --- Main Shell with Bottom Navigation ---
class MainShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  MainShell({required this.onToggleTheme});

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      DashboardScreen(),
      WorkoutsScreen(),
      CalendarScreen(),
      NutritionScreen(),
      NotesScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitly'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens_outlined),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCustomExercise(context),
              label: Text('Add Exercise'),
              icon: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddCustomExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddExerciseDialog(onCreate: (Workout w) {
        appState.addCustomExercise(w);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exercise added')));
        setState(() {});
      }),
    );
  }
}

// ---------------- Dashboard Screen ----------------
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good evening 👋', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 6),
                  Text('Here's your progress today', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _startQuickWorkout(context),
                icon: Icon(Icons.play_arrow),
                label: Text('Quick Start'),
              ),
            ],
          ),
          SizedBox(height: 18),
          // Core numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCard(title: 'In progress', value: appState.workoutsInProgress.toString(), icon: Icons.schedule),
              _StatCard(title: 'Finished', value: appState.workoutsFinished.toString(), icon: Icons.check_circle),
              _StatCard(title: 'Time (wk)', value: appState.totalMinutesThisWeek.toString() + 'm', icon: Icons.timer),
            ],
          ),

          SizedBox(height: 18),
          // Simple progress chart
          Text('Weekly activity', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 140,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: SimpleBarChart(data: List.generate(7, (i) => Random().nextInt(60) + 10)),
          ),

          SizedBox(height: 18),
          Text('Upcoming', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8),
          Expanded(child: UpcomingList()),
        ],
      ),
    );
  }

  void _startQuickWorkout(BuildContext context) {
    // quick start picks the first workout
    final w = appState.workouts.isNotEmpty ? appState.workouts.first : null;
    if (w == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No workouts available yet')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => StartWorkoutDialog(workout: w, onFinish: () {
        appState.markWorkoutDone();
        setState(() {});
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple bar chart using CustomPaint
class SimpleBarChart extends StatelessWidget {
  final List<int> data; // 7 items
  SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(data: data, color: Theme.of(context).colorScheme.primary),
      child: Container(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  _BarChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.85);
    final barWidth = size.width / (data.length * 2);
    final maxVal = data.reduce(max).toDouble();
    for (int i = 0; i < data.length; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final h = (data[i] / maxVal) * (size.height - 10);
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(6));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UpcomingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final scheduled = appState.calendar[key] ?? [];
    if (scheduled.isEmpty) {
      return Center(child: Text('No workout scheduled for today.'));
    }
    return ListView.builder(
      itemCount: scheduled.length,
      itemBuilder: (_, idx) {
        final s = scheduled[idx];
        final workout = appState.workouts.firstWhere((w) => w.id == s.workoutId, orElse: () => appState.workouts.first);
        return ListTile(
          leading: CircleAvatar(child: Text(workout.title[0])),
          title: Text(workout.title),
          subtitle: Text(s.note),
          trailing: ElevatedButton(onPressed: () {
            showDialog(context: context, builder: (_) => StartWorkoutDialog(workout: workout, onFinish: () { appState.markWorkoutDone(); }));
          }, child: Text('Start')),
        );
      },
    );
  }
}

// ---------------- Workouts Screen ----------------
class WorkoutsScreen extends StatefulWidget {
  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Cardio', 'Strength', 'Mobility'];
    final list = _filter == 'All' ? appState.workouts : appState.workouts.where((w) => w.category == _filter).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: categories.map((c) => Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: ChoiceChip(label: Text(c), selected: _filter==c, onSelected: (_) { setState(() { _filter = c; }); }),
            )).toList(),
          ),
          SizedBox(height:12),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, idx) {
                final w = list[idx];
                return Card(
                  margin: EdgeInsets.only(bottom:10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ),
                      child: Icon(Icons.play_circle_fill),
                    ),
                    title: Text(w.title),
                    subtitle: Text('${w.category} • ${w.durationMinutes} min'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (s) {
                        if (s == 'schedule') {
                          _showSchedulePicker(context, w);
                        } else if (s == 'start') {
                          showDialog(context: context, builder: (_) => StartWorkoutDialog(workout: w, onFinish: () { appState.markWorkoutDone(); setState(() {}); }));
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'start', child: Text('Start')),
                        PopupMenuItem(value: 'schedule', child: Text('Schedule')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSchedulePicker(BuildContext context, Workout w) {
    showDialog(context: context, builder: (_) => ScheduleDialog(onSchedule: (day, note){
      appState.scheduleWorkout(day, ScheduledWorkout(workoutId: w.id, note: note));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scheduled on ${day.month}/${day.day}')));
    }));
  }
}

// ---------------- Calendar Screen ----------------
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focused.year, _focused.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_focused.year, _focused.month);
    final startWeekday = firstDay.weekday % 7; // make Sunday=0

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.chevron_left), onPressed: (){ setState((){ _focused = DateTime(_focused.year, _focused.month -1, 1); });}),
              Text('${_monthName(_focused.month)} ${_focused.year}', style: Theme.of(context).textTheme.titleMedium),
              IconButton(icon: Icon(Icons.chevron_right), onPressed: (){ setState(()=> _focused = DateTime(_focused.year, _focused.month +1, 1));}),
            ],
          ),
          SizedBox(height: 8),
          _buildWeekdaysRow(context),
          SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < startWeekday) return Container();
                final day = idx - startWeekday + 1;
                final date = DateTime(_focused.year, _focused.month, day);
                final key = DateTime(date.year, date.month, date.day);
                final scheduled = appState.calendar[key] ?? [];
                final isToday = DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day;
                return GestureDetector(
                  onTap: () { _showDayDetails(context, date, scheduled); },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isToday ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        if (scheduled.isNotEmpty) Align(alignment: Alignment.bottomRight, child: Icon(Icons.fitness_center, size: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysRow(BuildContext context) {
    final days = ['S','M','T','W','T','F','S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => Expanded(child: Center(child: Text(d)))).toList(),
    );
  }

  String _monthName(int m) {
    const names = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return names[m-1];
  }

  void _showDayDetails(BuildContext context, DateTime date, List<ScheduledWorkout> scheduled) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Details ${date.month}/${date.day}/${date.year}'),
      content: Container(
        width: double.maxFinite,
        child: scheduled.isEmpty ? Text('No scheduled workouts') : Column(
          mainAxisSize: MainAxisSize.min,
          children: scheduled.map((s) {
            final w = appState.workouts.firstWhere((x) => x.id == s.workoutId, orElse: () => sampleWorkouts.first);
            return ListTile(title: Text(w.title), subtitle: Text(s.note));
          }).toList(),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
    ));
  }
}

// ---------------- Nutrition Screen ----------------
class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final goal = appState.caloriesGoal;
    final consumed = appState.caloriesConsumed;
    final remaining = max(0, goal - consumed);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goal', style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(height: 6),
                      Text('$goal kcal', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Consumed', style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(height: 6),
                      Text('$consumed kcal', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text('Remaining: $remaining kcal'),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Add meal calories'),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _addCalories, child: Text('Log')),
            ],
          ),
          SizedBox(height: 18),
          Text('Recent meals', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8),
          Expanded(child: _RecentMealsList()),
        ],
      ),
    );
  }

  void _addCalories() {
    final text = _controller.text.trim();
    final n = int.tryParse(text);
    if (n == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid number')));
      return;
    }
    appState.logCalories(n);
    _controller.clear();
    setState(() {});
  }
}

class _RecentMealsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For demo, just show last 5 calorie entries approximated by random numbers
    final items = List.generate(5, (i) => 150 + i * 50);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, idx) => ListTile(title: Text('Meal ${idx+1}'), trailing: Text('${items[idx]} kcal')),
    );
  }
}

// ---------------- Notes Screen ----------------
class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _noteController, decoration: InputDecoration(hintText: 'Add a workout note...'))),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _submitNote, child: Text('Add')),
            ],
          ),
          SizedBox(height: 12),
          Expanded(child: ListView.builder(itemCount: appState.notes.length, itemBuilder: (_, idx) {
            final n = appState.notes[idx];
            return Card(margin: EdgeInsets.only(bottom:8), child: ListTile(title: Text(n.text), subtitle: Text('${n.time}')));
          })),
        ],
      ),
    );
  }

  void _submitNote() {
    final t = _noteController.text.trim();
    if (t.isEmpty) return;
    final note = Note(time: DateTime.now(), text: t);
    appState.addNote(note);
    _noteController.clear();
    setState(() {});
  }
}

// ---------------- Dialogs & Forms ----------------
class StartWorkoutDialog extends StatefulWidget {
  final Workout workout;
  final VoidCallback onFinish;
  StartWorkoutDialog({required this.workout, required this.onFinish});

  @override
  _StartWorkoutDialogState createState() => _StartWorkoutDialogState();
}

class _StartWorkoutDialogState extends State<StartWorkoutDialog> {
  int _seconds = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _seconds = widget.workout.durationMinutes * 60;
    // for demo we do not run a real timer
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Start ${widget.workout.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Duration: ${widget.workout.durationMinutes} minutes'),
          SizedBox(height: 12),
          LinearProgressIndicator(value: 0),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          widget.onFinish();
        }, child: Text('Finish')),
      ],
    );
  }
}

class ScheduleDialog extends StatefulWidget {
  final void Function(DateTime day, String note) onSchedule;
  ScheduleDialog({required this.onSchedule});

  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  DateTime _picked = DateTime.now();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule workout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(onPressed: _pickDate, icon: Icon(Icons.date_range), label: Text('${_picked.month}/${_picked.day}/${_picked.year}')),
          TextField(controller: _noteController, decoration: InputDecoration(hintText: 'Note (optional)')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: () {
          widget.onSchedule(_picked, _noteController.text.trim());
          Navigator.pop(context);
        }, child: Text('Save')),
      ],
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _picked, firstDate: now.subtract(Duration(days: 365)), lastDate: now.add(Duration(days: 365)));
    if (picked != null) setState((){ _picked = picked; });
  }
}

class AddExerciseDialog extends StatefulWidget {
  final void Function(Workout) onCreate;
  AddExerciseDialog({required this.onCreate});

  @override
  _AddExerciseDialogState createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _duration = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create custom exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: InputDecoration(hintText: 'Title')),
          TextField(controller: _category, decoration: InputDecoration(hintText: 'Category')),
          TextField(controller: _duration, decoration: InputDecoration(hintText: 'Duration (min)', keyboardType: TextInputType.number)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: _create, child: Text('Create')),
      ],
    );
  }

  void _create() {
    final t = _title.text.trim();
    final c = _category.text.trim().isEmpty ? 'Custom' : _category.text.trim();
    final d = int.tryParse(_duration.text.trim()) ?? 10;
    if (t.isEmpty) return;
    final w = Workout(id: 'u${DateTime.now().millisecondsSinceEpoch}', title: t, category: c, durationMinutes: d, thumbnail: '', videoUrl: '');
    widget.onCreate(w);
    Navigator.pop(context);
  }
}

// ---------------- End of file ----------------
