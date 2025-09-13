import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:collection';

void main() {
  runApp(VitApp());
}

class VitApp extends StatefulWidget {
  @override
  State<VitApp> createState() => _VitAppState();
}

class _VitAppState extends State<VitApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitApp',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainShell(onToggleTheme: toggleTheme),
    );
  }
}

class MainShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MainShell({required this.onToggleTheme});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    WorkoutsScreen(),
    NutritionScreen(),
    NotesScreen(),
    ProgressScreen(),
    CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VitApp"),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: "Workouts"),
          NavigationDestination(icon: Icon(Icons.restaurant), label: "Nutrition"),
          NavigationDestination(icon: Icon(Icons.notes), label: "Notes"),
          NavigationDestination(icon: Icon(Icons.show_chart), label: "Progress"),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: "Calendar"),
        ],
      ),
    );
  }
}

// ---------------------- HOME SCREEN ----------------------

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int streak = 3; 
  int workoutsToday = 1;
  int caloriesToday = 1200;
  int notesToday = 2;

  final List<int> weeklyWorkouts = [1, 2, 1, 3, 2, 1, 1]; // dummy data
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  final List<String> quotes = [
    "Push yourself, because no one else is going to do it for you.",
    "The body achieves what the mind believes.",
    "Success starts with self-discipline.",
    "Small steps every day lead to big results.",
  ];

  String get randomQuote {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  late AnimationController _controller;
  late Animation<double> _streakAnim;
  late Animation<double> _workoutAnim;
  late Animation<double> _calorieAnim;
  late Animation<double> _notesAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _streakAnim = Tween<double>(begin: 0, end: streak.toDouble()).animate(_controller);
    _workoutAnim = Tween<double>(begin: 0, end: workoutsToday.toDouble()).animate(_controller);
    _calorieAnim = Tween<double>(begin: 0, end: caloriesToday.toDouble()).animate(_controller);
    _notesAnim = Tween<double>(begin: 0, end: notesToday.toDouble()).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Streak Card
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🔥 Streak", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                        SizedBox(height: 8),
                        Text("${_streakAnim.value.toInt()} days in a row", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.local_fire_department, size: 50, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),

          // 📊 Quick Stats
          Text("Quick Stats", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Workouts", _workoutAnim, Icons.fitness_center, Colors.purple),
              _buildStatCard("Calories", _calorieAnim, Icons.restaurant, Colors.green),
              _buildStatCard("Notes", _notesAnim, Icons.notes, Colors.orange),
            ],
          ),
          SizedBox(height: 20),

          // 💡 Motivational Quote Card
          Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
            ),
            padding: EdgeInsets.all(20),
            child: Text(
              "\"$randomQuote\"",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(height: 20),

          // 🎯 Today’s Overview
          Text("Today’s Overview", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _overviewCard("Workouts Completed", workoutsToday.toString(), Icons.fitness_center, Colors.blue),
              _overviewCard("Calories Consumed", "$caloriesToday kcal", Icons.restaurant, Colors.green),
              _overviewCard("Notes Logged", notesToday.toString(), Icons.notes, Colors.orange),
            ],
          ),

          SizedBox(height: 30),

          // 📈 Weekly Progress Chart
          Text("Weekly Progress", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 5))],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= days.length) return Container();
                        return Text(days[index], style: TextStyle(fontWeight: FontWeight.bold));
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      weeklyWorkouts.length,
                      (index) => FlSpot(index.toDouble(), weeklyWorkouts[index].toDouble()),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.deepPurple,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, Animation<double> valueAnim, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: valueAnim,
      builder: (context, _) {
        return Container(
          width: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(valueAnim.value.toInt().toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 5),
              Text(label, style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _overviewCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
// ---------------------- WORKOUTS SCREEN ----------------------

class WorkoutsScreen extends StatefulWidget {
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  int _seconds = 0;
  int _minutes = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  // Dummy workout list
  final List<String> workouts = [
    "Push Ups",
    "Squats",
    "Plank",
    "Running",
    "Cycling"
  ];

  void _startTimer() {
    if (_remainingSeconds == 0) {
      _remainingSeconds = (_minutes * 60) + _seconds;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Workout complete! 🎉")),
        );
      }
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });
  }

  String get _timeDisplay {
    int mins = _remainingSeconds ~/ 60;
    int secs = _remainingSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Workout List",
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),

          // 📝 Workout list
          Column(
            children: workouts.map((w) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                  title: Text(w),
                  trailing: Icon(Icons.play_arrow, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Start $w workout")),
                    );
                  },
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 20),
          Text("Workout Timer",
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),

          // ⏱ Countdown Timer
          Center(
            child: Text(
              _timeDisplay,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          // ⏳ Input for minutes/seconds (only when not running)
          if (!_isRunning && _remainingSeconds == 0) Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeInputField("Min", (val) {
                _minutes = int.tryParse(val) ?? 0;
              }),
              SizedBox(width: 16),
              _timeInputField("Sec", (val) {
                _seconds = int.tryParse(val) ?? 0;
              }),
            ],
          ),

          SizedBox(height: 20),

          // 🎛 Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                child: Text(_isRunning ? "Pause" : "Start"),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _resetTimer,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Reset"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeInputField(String label, Function(String) onChanged) {
    return SizedBox(
      width: 80,
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------- CALENDAR SCREEN ----------------------

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  // Store events {date: [events]}
  final Map<DateTime, List<String>> _events = HashMap();

  // Store reminders {dateTime: message}
  final Map<DateTime, String> _reminders = HashMap();

  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _startReminderChecker();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  // Normalize date (ignore time)
  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _addEvent(String event) {
    if (_selectedDate == null) return;
    final dateKey = _normalize(_selectedDate!);
    if (!_events.containsKey(dateKey)) {
      _events[dateKey] = [];
    }
    setState(() {
      _events[dateKey]!.add(event);
    });
  }

  void _addReminder(DateTime dateTime, String message) {
    setState(() {
      _reminders[dateTime] = message;
    });
  }

  void _startReminderChecker() {
    _reminderTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final currentMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute);

      if (_reminders.containsKey(currentMinute)) {
        final message = _reminders[currentMinute];
        if (message != null) {
          _showReminderAlert(message);
          _reminders.remove(currentMinute); // auto-clear after triggering
        }
      }
    });
  }

  void _showReminderAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("⏰ Reminder"),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final weekdayOfFirst = firstDayOfMonth.weekday;
    final totalCells = ((weekdayOfFirst - 1) + daysInMonth);

    return List.generate(totalCells, (index) {
      if (index < weekdayOfFirst - 1) {
        return Container(); // Empty cell
      } else {
        final day = index - (weekdayOfFirst - 2);
        final currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isSelected = _selectedDate != null && _normalize(_selectedDate!) == _normalize(currentDate);
        final hasEvent = _events.containsKey(_normalize(currentDate));

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasEvent ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: hasEvent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = "${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar & Reminders"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                monthName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ))
                .toList(),
          ),

          // Calendar grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              children: _buildCalendarDays(),
            ),
          ),

          // Events + Reminders section
          Container(
            padding: EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDate != null
                      ? "Events on ${_selectedDate!.day}/${_selectedDate!.month}"
                      : "Select a date",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Event list
                if (_selectedDate != null)
                  ...?_events[_normalize(_selectedDate!)]?.map((e) => ListTile(
                        leading: Icon(Icons.event),
                        title: Text(e),
                      )),

                SizedBox(height: 8),

                // Buttons
                if (_selectedDate != null)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text("Add Event"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final controller = TextEditingController();
                                return AlertDialog(
                                  title: Text("New Event"),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(hintText: "Enter event"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (controller.text.trim().isNotEmpty) {
                                          _addEvent(controller.text.trim());
                                          Navigator.pop(ctx);
                                        }
                                      },
                                      child: Text("Save"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.alarm),
                          label: Text("Add Reminder"),
                          onPressed: () {
                            if (_selectedDate == null) return;
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final controller = TextEditingController();
                                TimeOfDay? pickedTime;
                                return StatefulBuilder(
                                  builder: (ctx, setStateDialog) {
                                    return AlertDialog(
                                      title: Text("New Reminder"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: controller,
                                            decoration: InputDecoration(hintText: "Reminder text"),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final t = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                              );
                                              if (t != null) {
                                                setStateDialog(() {
                                                  pickedTime = t;
                                                });
                                              }
                                            },
                                            child: Text(pickedTime == null
                                                ? "Pick Time"
                                                : "Picked: ${pickedTime!.format(context)}"),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (controller.text.trim().isNotEmpty && pickedTime != null) {
                                              final reminderDateTime = DateTime(
                                                _selectedDate!.year,
                                                _selectedDate!.month,
                                                _selectedDate!.day,
                                                pickedTime!.hour,
                                                pickedTime!.minute,
                                              );
                                              _addReminder(reminderDateTime, controller.text.trim());
                                              Navigator.pop(ctx);
                                            }
                                          },
                                          child: Text("Save"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}



// ---------------------- NUTRITION SCREEN ----------------------

class NutritionScreen extends StatefulWidget {
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final int _calorieGoal = 2000;
  int _consumedCalories = 0;

  final List<Map<String, dynamic>> _meals = [];

  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();

  void _addMeal() {
    final meal = _mealController.text.trim();
    final calories = int.tryParse(_calorieController.text.trim()) ?? 0;

    if (meal.isEmpty || calories <= 0) return;

    setState(() {
      _meals.add({"meal": meal, "calories": calories});
      _consumedCalories += calories;
    });

    _mealController.clear();
    _calorieController.clear();
  }

  double get _progress {
    return _consumedCalories / _calorieGoal;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nutrition Tracker",
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),

          // 📊 Progress bar
          LinearProgressIndicator(
            value: _progress > 1 ? 1 : _progress,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 12,
          ),
          SizedBox(height: 10),
          Text("$_consumedCalories / $_calorieGoal kcal consumed"),

          SizedBox(height: 20),

          // ➕ Add meal
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mealController,
                  decoration: InputDecoration(
                    labelText: "Meal",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _calorieController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Calories",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addMeal,
                child: Text("Add"),
              ),
            ],
          ),

          SizedBox(height: 20),

          // 📋 Meal list
          Text("Today’s Meals",
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 10),
          Column(
            children: _meals.map((meal) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.restaurant, color: Colors.green),
                  title: Text(meal["meal"]),
                  trailing: Text("${meal["calories"]} kcal"),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------- NOTES SCREEN ----------------------

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  final List<Map<String, dynamic>> _notes = [];

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _notes.insert(0, {
        "text": text,
        "date": DateTime.now(),
      });
    });

    _noteController.clear();
  }

  void _deleteNoteAt(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input field
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Write a note...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addNote,
                child: Text("Add"),
              ),
            ],
          ),
        ),

        // Notes list
        Expanded(
          child: _notes.isEmpty
              ? Center(child: Text("No notes yet. Add your first one!"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final date = note["date"] as DateTime;
                    final formatted =
                        "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.note_alt, color: Colors.orange),
                        title: Text(note["text"]),
                        subtitle: Text(formatted),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNoteAt(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------- Profile SCREEN ----------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for fields
  final _nameController = TextEditingController(text: "John Doe");
  final _ageController = TextEditingController(text: "25");
  final _heightController = TextEditingController(text: "175");
  final _weightController = TextEditingController(text: "70");
  final _goalController = TextEditingController(text: "Build muscle");

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your $label";
          }
          return null;
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage("assets/avatar.png"),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Fields
              _buildTextField("Name", _nameController),
              _buildTextField("Age", _ageController,
                  inputType: TextInputType.number),
              _buildTextField("Height (cm)", _heightController,
                  inputType: TextInputType.number),
              _buildTextField("Weight (kg)", _weightController,
                  inputType: TextInputType.number),
              _buildTextField("Fitness Goal", _goalController),

              const SizedBox(height: 20),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- Progress SCREEN ----------------------
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Progress Screen Coming Soon...",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}



