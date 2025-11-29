import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_theme') ?? false;
  _themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(const SplitterApp());
}

class SplitterApp extends StatelessWidget {
  const SplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, mode, _) {
        final lightScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF00514A),
          brightness: Brightness.light,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF00514A),
          brightness: Brightness.dark,
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TripTally',
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5FBF9),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFFF5FBF9),
              foregroundColor: lightScheme.onSurface,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D2830),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: lightScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFFE4F5F1),
              selectedColor: lightScheme.primary.withOpacity(0.16),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Roboto',
              bodyColor: const Color(0xFF1D2830),
              displayColor: const Color(0xFF1D2830),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0D1518),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0D1518),
              foregroundColor: darkScheme.onSurface,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF172329),
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: darkScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF22313A),
              selectedColor: darkScheme.primary.withOpacity(0.2),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
          ),
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

// MODELS

enum ExpenseCategory {
  food('Food', Icons.restaurant, Color(0xFFFF6B6B)),
  transport('Transport', Icons.directions_car, Color(0xFF4ECDC4)),
  accommodation('Accommodation', Icons.hotel, Color(0xFF45B7D1)),
  entertainment('Entertainment', Icons.movie, Color(0xFFFFA07A)),
  shopping('Shopping', Icons.shopping_bag, Color(0xFF98D8C8)),
  utilities('Utilities', Icons.bolt, Color(0xFFFFD93D)),
  healthcare('Healthcare', Icons.local_hospital, Color(0xFF6BCB77)),
  other('Other', Icons.category, Color(0xFF95A5A6));

  const ExpenseCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (cat) => cat.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class Member {
  Member({required this.id, required this.name});

  final String id;
  final String name;

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as String, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.involvedMemberIds,
    required this.createdAt,
    this.shares,
    this.category,
  });

  final String id;
  final String title;
  final String description;
  final double amount;
  final String payerId;
  final List<String> involvedMemberIds;
  final DateTime createdAt;
  final Map<String, double>? shares; // optional per-member share (amount)
  final ExpenseCategory? category;

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    amount: (json['amount'] as num).toDouble(),
    payerId: json['payerId'] as String,
    involvedMemberIds: (json['involvedMemberIds'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    shares: (json['shares'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    ),
    category: json['category'] != null
        ? ExpenseCategory.fromString(json['category'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'payerId': payerId,
    'involvedMemberIds': involvedMemberIds,
    'createdAt': createdAt.toIso8601String(),
    if (shares != null) 'shares': shares,
    if (category != null) 'category': category!.name,
  };
}

class Settlement {
  Settlement({
    required this.id,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String fromMemberId;
  final String toMemberId;
  final double amount;
  final DateTime createdAt;

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
    id: json['id'] as String,
    fromMemberId: json['fromMemberId'] as String,
    toMemberId: json['toMemberId'] as String,
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromMemberId': fromMemberId,
    'toMemberId': toMemberId,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };
}

class SplitGroup {
  SplitGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.expenses,
    required this.settlements,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final List<Member> members;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final DateTime createdAt;

  factory SplitGroup.fromJson(Map<String, dynamic> json) => SplitGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    members: (json['members'] as List<dynamic>)
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList(),
    expenses: (json['expenses'] as List<dynamic>)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList(),
    settlements: (json['settlements'] as List<dynamic>)
        .map((e) => Settlement.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'members': members.map((m) => m.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'settlements': settlements.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}

// SIMPLE LOCAL STORAGE SERVICE

class StorageService {
  static const _groupsKey = 'split_groups_v1';

  Future<List<SplitGroup>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groupsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SplitGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGroups(List<SplitGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = groups.map((g) => g.toJson()).toList();
    await prefs.setString(_groupsKey, jsonEncode(jsonList));
  }
}

final _storage = StorageService();

String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

// HOME SCREEN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<SplitGroup>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _storage.loadGroups();
  }

  Future<void> _reload() async {
    setState(() {
      _groupsFuture = _storage.loadGroups();
    });
  }

  Future<void> _createOrEditGroup([SplitGroup? group]) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditGroupScreen(existing: group)));
    await _reload();
  }

  Future<void> _openGroup(SplitGroup group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Trips & Splits'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: _themeModeNotifier,
              builder: (context, mode, _) {
                final isDark = mode == ThemeMode.dark;
                return Icon(isDark ? Icons.dark_mode : Icons.light_mode);
              },
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final isDark = _themeModeNotifier.value == ThemeMode.dark;
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              _themeModeNotifier.value = newMode;
              await prefs.setBool('is_dark_theme', newMode == ThemeMode.dark);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SplitGroup>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade300),
                  title: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          }
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group, size: 80, color: Colors.teal.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'No splits yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first trip/expense group and start splitting smartly.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () => _openGroup(group),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      group.description.isEmpty
                          ? '${group.members.length} members'
                          : group.description,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _createOrEditGroup(group);
                        } else if (value == 'delete') {
                          final confirmed =
                              await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete group?'),
                                  content: Text(
                                    'This will remove "${group.name}" and all its expenses. This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirmed) return;
                          final prefsGroups = await _storage.loadGroups();
                          prefsGroups.removeWhere(
                            (element) => element.id == group.id,
                          );
                          await _storage.saveGroups(prefsGroups);
                          await _reload();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit group & members'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete group'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createOrEditGroup(),
        icon: const Icon(Icons.add),
        label: const Text('Create split/trip'),
      ),
    );
  }
}

// CREATE / EDIT GROUP SCREEN

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key, this.existing});

  final SplitGroup? existing;

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _memberNameController = TextEditingController();
  final List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _descriptionController.text = existing.description;
      _members.addAll(existing.members);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _members.add(Member(id: _generateId(), name: name));
      _memberNameController.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _members.isEmpty) return;
    final allGroups = await _storage.loadGroups();
    if (widget.existing == null) {
      final newGroup = SplitGroup(
        id: _generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        members: List<Member>.from(_members),
        expenses: const [],
        settlements: const [],
        createdAt: DateTime.now(),
      );
      allGroups.add(newGroup);
    } else {
      final idx = allGroups.indexWhere(
        (element) => element.id == widget.existing!.id,
      );
      if (idx != -1) {
        final existing = allGroups[idx];
        allGroups[idx] = SplitGroup(
          id: existing.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          members: List<Member>.from(_members),
          expenses: existing.expenses,
          settlements: existing.settlements,
          createdAt: existing.createdAt,
        );
      }
    }
    await _storage.saveGroups(allGroups);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit split' : 'Create new split'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Goa Trip, Office Lunch, Room Rent...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Members',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberNameController,
                      decoration: const InputDecoration(
                        hintText: 'Add member name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addMember(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add_circle, color: Colors.teal),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _members
                    .map(
                      (m) => Chip(
                        label: Text(m.name),
                        avatar: CircleAvatar(
                          radius: 10,
                          child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        onDeleted: () {
                          setState(() {
                            _members.remove(m);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Create split'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// GROUP DETAIL SCREEN

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

enum ExpenseSortBy { date, amount, payer }

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  SplitGroup? _group;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ExpenseCategory? _filterCategory;
  String? _filterPayerId;
  DateTimeRange? _dateRange;
  ExpenseSortBy _sortBy = ExpenseSortBy.date;
  bool _sortAscending = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate loading delay for skeleton effect
    await Future.delayed(const Duration(milliseconds: 300));
    final groups = await _storage.loadGroups();
    if (mounted) {
      setState(() {
        _group = groups.firstWhere((g) => g.id == widget.groupId);
        _isLoading = false;
      });
    }
  }

  List<Expense> _getFilteredExpenses() {
    if (_group == null) return [];
    var expenses = List<Expense>.from(_group!.expenses);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      expenses = expenses.where((e) {
        return e.title.toLowerCase().contains(_searchQuery) ||
            e.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Category filter
    if (_filterCategory != null) {
      expenses = expenses.where((e) => e.category == _filterCategory).toList();
    }

    // Payer filter
    if (_filterPayerId != null) {
      expenses = expenses.where((e) => e.payerId == _filterPayerId).toList();
    }

    // Date range filter
    if (_dateRange != null) {
      expenses = expenses.where((e) {
        return e.createdAt.isAfter(
              _dateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            e.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort
    expenses.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case ExpenseSortBy.date:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case ExpenseSortBy.amount:
          comparison = a.amount.compareTo(b.amount);
          break;
        case ExpenseSortBy.payer:
          final payerA = _group!.members
              .firstWhere((m) => m.id == a.payerId)
              .name;
          final payerB = _group!.members
              .firstWhere((m) => m.id == b.payerId)
              .name;
          comparison = payerA.compareTo(payerB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return expenses;
  }

  Future<void> _addExpense() async {
    if (_group == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddExpenseScreen(groupId: widget.groupId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
    await _load();
  }

  Future<void> _openSummary() async {
    if (_group == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SummaryScreen(groupId: widget.groupId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    await _load();
  }

  Future<void> _openSettle() async {
    if (_group == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SettleScreen(groupId: widget.groupId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    await _load();
  }

  Future<void> _openExpenseDetail(Expense expense) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExpenseDetailScreen(groupId: widget.groupId, expenseId: expense.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
    await _load();
  }

  Map<ExpenseCategory, double> _getCategoryStatistics(SplitGroup group) {
    final stats = <ExpenseCategory, double>{};
    for (final expense in group.expenses) {
      if (expense.category != null) {
        stats[expense.category!] =
            (stats[expense.category] ?? 0) + expense.amount;
      }
    }
    return stats;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case ExpenseSortBy.date:
        return 'Date';
      case ExpenseSortBy.amount:
        return 'Amount';
      case ExpenseSortBy.payer:
        return 'Payer';
    }
  }

  String _getSortLabelFor(ExpenseSortBy sort) {
    switch (sort) {
      case ExpenseSortBy.date:
        return 'Date';
      case ExpenseSortBy.amount:
        return 'Amount';
      case ExpenseSortBy.payer:
        return 'Payer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    if (group == null || _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search skeleton
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips skeleton
            Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 32,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Expense cards skeleton
            ...List.generate(
              5,
              (index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade300),
                  title: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filteredExpenses = _getFilteredExpenses();
    final categoryStats = _getCategoryStatistics(group);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            tooltip: 'Summary',
            icon: const Icon(Icons.summarize_outlined),
            onPressed: _openSummary,
          ),
          IconButton(
            tooltip: 'Settle up',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _openSettle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                PopupMenuButton<ExpenseCategory?>(
                  icon: Chip(
                    avatar: Icon(
                      _filterCategory?.icon ?? Icons.category,
                      size: 16,
                    ),
                    label: Text(_filterCategory?.label ?? 'Category'),
                    onDeleted: _filterCategory != null
                        ? () {
                            setState(() {
                              _filterCategory = null;
                            });
                          }
                        : null,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...ExpenseCategory.values.map(
                      (cat) => PopupMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.label),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _filterCategory = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Payer filter
                PopupMenuButton<String?>(
                  icon: Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(
                      _filterPayerId != null
                          ? group.members
                                .firstWhere((m) => m.id == _filterPayerId)
                                .name
                          : 'Payer',
                    ),
                    onDeleted: _filterPayerId != null
                        ? () {
                            setState(() {
                              _filterPayerId = null;
                            });
                          }
                        : null,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('All payers')),
                    ...group.members.map(
                      (m) => PopupMenuItem(value: m.id, child: Text(m.name)),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _filterPayerId = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Date range filter
                GestureDetector(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (range != null) {
                      setState(() {
                        _dateRange = range;
                      });
                    }
                  },
                  child: Chip(
                    avatar: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      _dateRange != null
                          ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                          : 'Date',
                    ),
                    onDeleted: _dateRange != null
                        ? () {
                            setState(() {
                              _dateRange = null;
                            });
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                // Sort
                PopupMenuButton<MapEntry<ExpenseSortBy, bool>>(
                  icon: Chip(
                    avatar: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                    ),
                    label: Text(_getSortLabel()),
                  ),
                  itemBuilder: (context) => [
                    ...ExpenseSortBy.values.map(
                      (sort) => PopupMenuItem(
                        value: MapEntry(sort, true),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 16,
                              color: _sortBy == sort && _sortAscending
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(_getSortLabelFor(sort)),
                          ],
                        ),
                      ),
                    ),
                    ...ExpenseSortBy.values.map(
                      (sort) => PopupMenuItem(
                        value: MapEntry(sort, false),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 16,
                              color: _sortBy == sort && !_sortAscending
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(_getSortLabelFor(sort)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value.key;
                      _sortAscending = value.value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Category statistics
          if (categoryStats.isNotEmpty) ...[
            const Text(
              'Category Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryStats.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                return Chip(
                  avatar: Icon(category.icon, color: category.color),
                  label: Text(
                    '${category.label}: ₹${amount.toStringAsFixed(2)}',
                  ),
                  backgroundColor: category.color.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (group.description.isNotEmpty)
            Text(
              group.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.members
                .map(
                  (m) => Chip(
                    label: Text(m.name),
                    avatar: CircleAvatar(
                      radius: 10,
                      child: Text(
                        m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final balances = computeBalances(group);
              final owingCount = balances.where((b) => b.balance > 0.01).length;
              if (owingCount == 0) {
                return const Text(
                  'Everyone is settled up in this group.',
                  style: TextStyle(color: Colors.green),
                );
              }
              return Text(
                '$owingCount member(s) still owe money.',
                style: const TextStyle(color: Colors.red),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (filteredExpenses.length != group.expenses.length)
                Text(
                  '${filteredExpenses.length} of ${group.expenses.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (group.expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('No expenses yet. Tap "Add expense" to start.'),
            )
          else if (filteredExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('No expenses match your filters.'),
            )
          else
            ...filteredExpenses.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              final payer = group.members
                  .firstWhere((m) => m.id == e.payerId)
                  .name;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _openExpenseDetail(e),
                    onLongPress: () async {
                      final confirmed =
                          await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete expense?'),
                              content: Text(
                                'Delete "${e.title}" from this group? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (!confirmed) return;
                      final groups = await _storage.loadGroups();
                      final idx = groups.indexWhere(
                        (g) => g.id == widget.groupId,
                      );
                      if (idx == -1) return;
                      final g = groups[idx];
                      final updated = SplitGroup(
                        id: g.id,
                        name: g.name,
                        description: g.description,
                        members: g.members,
                        expenses: g.expenses
                            .where((ex) => ex.id != e.id)
                            .toList(),
                        settlements: g.settlements,
                        createdAt: g.createdAt,
                      );
                      groups[idx] = updated;
                      await _storage.saveGroups(groups);
                      await _load();
                    },
                    leading: e.category != null
                        ? CircleAvatar(
                            backgroundColor: e.category!.color.withOpacity(0.2),
                            child: Icon(
                              e.category!.icon,
                              color: e.category!.color,
                              size: 20,
                            ),
                          )
                        : null,
                    title: Text(e.title),
                    subtitle: Text(
                      '₹${e.amount.toStringAsFixed(2)} • Paid by $payer${e.category != null ? ' • ${e.category!.label}' : ''}',
                    ),
                    trailing: Text(
                      '${e.involvedMemberIds.length} people',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('New expense'),
      ),
    );
  }
}

// ADD EXPENSE SCREEN

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.groupId, this.expenseId});

  final String groupId;
  final String? expenseId;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  SplitGroup? _group;
  Expense? _editingExpense;
  String? _selectedPayerId;
  final Set<String> _selectedMemberIds = {};
  SplitMode _splitMode = SplitMode.equal;
  ExpenseCategory? _selectedCategory;
  final Map<String, TextEditingController> _customAmountControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};

  TextEditingController _controllerFor(
    Map<String, TextEditingController> map,
    String memberId,
  ) {
    return map.putIfAbsent(memberId, () => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await _storage.loadGroups();
    final group = groups.firstWhere((g) => g.id == widget.groupId);
    Expense? editing;
    if (widget.expenseId != null) {
      editing = group.expenses.cast<Expense?>().firstWhere(
        (e) => e?.id == widget.expenseId,
        orElse: () => null,
      );
    }
    setState(() {
      _group = group;
      _editingExpense = editing;
      if (editing != null) {
        _titleController.text = editing.title;
        _descriptionController.text = editing.description;
        _amountController.text = editing.amount.toStringAsFixed(2);
        _selectedPayerId = editing.payerId;
        _selectedCategory = editing.category;
        _selectedMemberIds
          ..clear()
          ..addAll(editing.involvedMemberIds);
        if (editing.shares != null && editing.shares!.isNotEmpty) {
          _splitMode = SplitMode.customAmount;
          _customAmountControllers.clear();
          editing.shares!.forEach((memberId, share) {
            final c = _controllerFor(_customAmountControllers, memberId);
            c.text = share.toStringAsFixed(2);
          });
        }
      } else if (group.members.isNotEmpty) {
        _selectedPayerId = group.members.first.id;
        _selectedMemberIds
          ..clear()
          ..addAll(group.members.map((e) => e.id));
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final group = _group;
    if (group == null ||
        _selectedPayerId == null ||
        _selectedMemberIds.isEmpty) {
      return;
    }
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    Map<String, double>? shares;
    if (_splitMode == SplitMode.equal) {
      shares = null;
    } else if (_splitMode == SplitMode.customAmount) {
      shares = {};
      double sum = 0;
      for (final id in _selectedMemberIds) {
        final c = _controllerFor(_customAmountControllers, id);
        final v = double.tryParse(c.text.trim()) ?? 0;
        if (v <= 0) continue;
        shares[id] = v;
        sum += v;
      }
      if (shares.isEmpty || (sum - amount).abs() > 0.01) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Custom amounts must add up to total amount.'),
            ),
          );
        }
        return;
      }
    } else if (_splitMode == SplitMode.percentage) {
      shares = {};
      double percentSum = 0;
      for (final id in _selectedMemberIds) {
        final c = _controllerFor(_percentControllers, id);
        final p = double.tryParse(c.text.trim()) ?? 0;
        if (p <= 0) continue;
        percentSum += p;
      }
      if (percentSum <= 0 || (percentSum - 100).abs() > 0.5) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Percentages should add up to ~100%.'),
            ),
          );
        }
        return;
      }
      for (final id in _selectedMemberIds) {
        final c = _controllerFor(_percentControllers, id);
        final p = double.tryParse(c.text.trim()) ?? 0;
        if (p <= 0) continue;
        final shareAmount = amount * (p / percentSum);
        shares[id] = shareAmount;
      }
    }
    final allGroups = await _storage.loadGroups();
    final idx = allGroups.indexWhere((g) => g.id == group.id);
    if (idx == -1) return;

    final base = _editingExpense;
    final updatedExpense = Expense(
      id: base?.id ?? _generateId(),
      title: _titleController.text.trim().isEmpty
          ? 'Expense'
          : _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      payerId: _selectedPayerId!,
      involvedMemberIds: _selectedMemberIds.toList(),
      createdAt: base?.createdAt ?? DateTime.now(),
      shares: shares,
      category: _selectedCategory,
    );

    final List<Expense> newExpenses;
    if (base == null) {
      newExpenses = [...group.expenses, updatedExpense];
    } else {
      newExpenses = group.expenses
          .map((e) => e.id == base.id ? updatedExpense : e)
          .toList();
    }

    final updatedGroup = SplitGroup(
      id: group.id,
      name: group.name,
      description: group.description,
      members: group.members,
      expenses: newExpenses,
      settlements: group.settlements,
      createdAt: group.createdAt,
    );

    allGroups[idx] = updatedGroup;
    await _storage.saveGroups(allGroups);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _customAmountControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEditing = _editingExpense != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit expense' : 'Add expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Expense name',
                  hintText: 'Dinner, Taxi, Hotel...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Amount required';
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 16),
                        const SizedBox(width: 4),
                        Text(category.label),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: category.color.withOpacity(0.2),
                    checkmarkColor: category.color,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Who paid?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPayerId,
                items: group.members
                    .map(
                      (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPayerId = val;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text(
                'Who is in this expense?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: group.members.map((m) {
                  final selected = _selectedMemberIds.contains(m.id);
                  return FilterChip(
                    label: Text(m.name),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedMemberIds.add(m.id);
                        } else {
                          _selectedMemberIds.remove(m.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Split type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<SplitMode>(
                segments: const [
                  ButtonSegment(value: SplitMode.equal, label: Text('Equal')),
                  ButtonSegment(
                    value: SplitMode.customAmount,
                    label: Text('Custom ₹'),
                  ),
                  ButtonSegment(value: SplitMode.percentage, label: Text('%')),
                ],
                selected: {_splitMode},
                onSelectionChanged: (s) {
                  if (s.isEmpty) return;
                  setState(() {
                    _splitMode = s.first;
                  });
                },
              ),
              if (_splitMode != SplitMode.equal) ...[
                const SizedBox(height: 12),
                Text(
                  _splitMode == SplitMode.customAmount
                      ? 'Enter amount per person (must total to amount).'
                      : 'Enter percentage per person (should total ~100%).',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Column(
                  children: group.members.map((m) {
                    final selected = _selectedMemberIds.contains(m.id);
                    if (!selected) {
                      return ListTile(
                        dense: true,
                        title: Text(m.name),
                        subtitle: const Text('Not in this expense'),
                      );
                    }
                    final controller = _splitMode == SplitMode.customAmount
                        ? _controllerFor(_customAmountControllers, m.id)
                        : _controllerFor(_percentControllers, m.id);
                    final label = _splitMode == SplitMode.customAmount
                        ? 'Amount'
                        : '%';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(m.name)),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: label,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Save expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// EXPENSE DETAIL SCREEN

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  final String groupId;
  final String expenseId;

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final two = (int n) => n.toString().padLeft(2, '0');
    final date = '${two(local.day)}/${two(local.month)}/${local.year}';
    final time = '${two(local.hour)}:${two(local.minute)}';
    return '$date  $time';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SplitGroup>>(
      future: _storage.loadGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final groups = snapshot.data ?? [];
        final group = groups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => SplitGroup(
            id: '',
            name: '',
            description: '',
            members: const [],
            expenses: const [],
            settlements: const [],
            createdAt: DateTime.now(),
          ),
        );
        final expense = group.expenses.firstWhere(
          (e) => e.id == expenseId,
          orElse: () => Expense(
            id: '',
            title: 'Expense not found',
            description: '',
            amount: 0,
            payerId: '',
            involvedMemberIds: const [],
            createdAt: DateTime.now(),
          ),
        );

        if (group.id.isEmpty || expense.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Expense details')),
            body: const Center(child: Text('Expense not found.')),
          );
        }

        final payer = group.members.firstWhere(
          (m) => m.id == expense.payerId,
          orElse: () => group.members.first,
        );
        final participants = group.members
            .where((m) => expense.involvedMemberIds.contains(m.id))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(
                        groupId: group.id,
                        expenseId: expense.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ₹${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid by: ${payer.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${_formatDateTime(expense.createdAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                if (expense.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(expense.description),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Participants',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (participants.isEmpty)
                  const Text('No participants recorded.')
                else
                  Wrap(
                    spacing: 8,
                    children: participants
                        .map(
                          (m) => Chip(
                            label: Text(m.name),
                            avatar: CircleAvatar(
                              radius: 10,
                              child: Text(
                                m.name.isNotEmpty
                                    ? m.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// SUMMARY LOGIC

class MemberBalance {
  MemberBalance({required this.member, required this.balance});

  final Member member;
  double balance; // >0 = owes, <0 = should receive
}

List<MemberBalance> computeBalances(SplitGroup group) {
  final paid = <String, double>{};
  final owes = <String, double>{};

  for (final m in group.members) {
    paid[m.id] = 0;
    owes[m.id] = 0;
  }

  for (final e in group.expenses) {
    if (e.involvedMemberIds.isEmpty) continue;
    paid[e.payerId] = (paid[e.payerId] ?? 0) + e.amount;
    if (e.shares != null && e.shares!.isNotEmpty) {
      e.shares!.forEach((id, share) {
        owes[id] = (owes[id] ?? 0) + share;
      });
    } else {
      final share = e.amount / e.involvedMemberIds.length;
      for (final id in e.involvedMemberIds) {
        owes[id] = (owes[id] ?? 0) + share;
      }
    }
  }

  // Apply manual settlements (who paid whom how much)
  for (final s in group.settlements) {
    // fromMember gave cash to toMember
    paid[s.fromMemberId] = (paid[s.fromMemberId] ?? 0) + s.amount;
    owes[s.toMemberId] = (owes[s.toMemberId] ?? 0) + s.amount;
  }

  final balances = <MemberBalance>[];
  for (final m in group.members) {
    final b = (owes[m.id] ?? 0) - (paid[m.id] ?? 0);
    if (b.abs() < 0.01) {
      balances.add(MemberBalance(member: m, balance: 0));
    } else {
      balances.add(MemberBalance(member: m, balance: b));
    }
  }
  return balances;
}

class Transfer {
  Transfer({required this.from, required this.to, required this.amount});

  final Member from;
  final Member to;
  final double amount;
}

class ExpenseTransfer {
  ExpenseTransfer({
    required this.expense,
    required this.from,
    required this.to,
    required this.amount,
  });

  final Expense expense;
  final Member from;
  final Member to;
  final double amount;
}

enum SummaryMode { overall, perExpense }

enum SplitMode { equal, customAmount, percentage }

List<Transfer> computeSuggestedTransfers(List<MemberBalance> balances) {
  final debtors = <MemberBalance>[];
  final creditors = <MemberBalance>[];

  for (final b in balances) {
    if (b.balance > 0.01) {
      debtors.add(MemberBalance(member: b.member, balance: b.balance));
    } else if (b.balance < -0.01) {
      creditors.add(MemberBalance(member: b.member, balance: b.balance));
    }
  }

  debtors.sort((a, b) => b.balance.compareTo(a.balance));
  creditors.sort(
    (a, b) => a.balance.compareTo(b.balance),
  ); // most negative first

  final transfers = <Transfer>[];

  int i = 0;
  int j = 0;
  while (i < debtors.length && j < creditors.length) {
    final debtor = debtors[i];
    final creditor = creditors[j];
    final amount = debtor.balance.min(-creditor.balance);

    transfers.add(
      Transfer(from: debtor.member, to: creditor.member, amount: amount),
    );

    debtor.balance -= amount;
    creditor.balance += amount;

    if (debtor.balance <= 0.01) i++;
    if (creditor.balance >= -0.01) j++;
  }

  return transfers;
}

List<ExpenseTransfer> computePerExpenseTransfers(SplitGroup group) {
  final result = <ExpenseTransfer>[];
  for (final e in group.expenses) {
    if (e.involvedMemberIds.isEmpty) continue;
    final payer = group.members.firstWhere(
      (m) => m.id == e.payerId,
      orElse: () => group.members.first,
    );
    if (e.shares != null && e.shares!.isNotEmpty) {
      e.shares!.forEach((id, share) {
        if (id == payer.id) return;
        final from = group.members.firstWhere(
          (m) => m.id == id,
          orElse: () => payer,
        );
        result.add(
          ExpenseTransfer(expense: e, from: from, to: payer, amount: share),
        );
      });
    } else {
      final share = e.amount / e.involvedMemberIds.length;
      for (final id in e.involvedMemberIds) {
        if (id == payer.id) continue;
        final from = group.members.firstWhere(
          (m) => m.id == id,
          orElse: () => payer,
        );
        result.add(
          ExpenseTransfer(expense: e, from: from, to: payer, amount: share),
        );
      }
    }
  }
  return result;
}

extension on double {
  double min(double other) => this < other ? this : other;
}

// SUMMARY SCREEN

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SplitGroup? _group;
  SummaryMode _mode = SummaryMode.overall;
  String? _selectedReceiverId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await _storage.loadGroups();
    setState(() {
      _group = groups.firstWhere((g) => g.id == widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final balances = computeBalances(group);
    final transfers = computeSuggestedTransfers(balances);
    final expenseTransfers = computePerExpenseTransfers(group);
    final transfersByExpense = <String, List<ExpenseTransfer>>{};
    for (final t in expenseTransfers) {
      transfersByExpense.putIfAbsent(t.expense.id, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<SummaryMode>(
            segments: const [
              ButtonSegment(
                value: SummaryMode.overall,
                label: Text('Overall'),
                icon: Icon(Icons.account_balance_wallet_outlined),
              ),
              ButtonSegment(
                value: SummaryMode.perExpense,
                label: Text('By expense'),
                icon: Icon(Icons.receipt_long_outlined),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() {
                _mode = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_mode == SummaryMode.overall) ...[
            // Filter helpers based on selected receiver
            Builder(
              builder: (context) {
                final receivers = balances
                    .where((b) => b.balance < -0.01)
                    .toList();
                final hasSelection = _selectedReceiverId != null;
                final selectedBalance = hasSelection
                    ? receivers.firstWhere(
                        (b) => b.member.id == _selectedReceiverId,
                        orElse: () => receivers.first,
                      )
                    : null;

                if (receivers.isEmpty) {
                  _selectedReceiverId = null;
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'See who has to receive money',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: receivers.map((b) {
                        final isSelected = _selectedReceiverId == b.member.id;
                        return ChoiceChip(
                          label: Text(b.member.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedReceiverId = selected
                                  ? b.member.id
                                  : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasSelection
                                  ? '${selectedBalance!.member.name} will receive in total'
                                  : 'Overall to receive (all members)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasSelection
                                  ? '₹${(-selectedBalance!.balance).toStringAsFixed(2)}'
                                  : '₹${receivers.fold<double>(0, (sum, b) => sum + (-b.balance)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasSelection) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Selected member has to receive from others. ',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ] else ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Tap on a name above to see full summary only for that member.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Member balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(() {
              final iterable = _selectedReceiverId == null
                  ? balances
                  : balances.where((b) => b.member.id == _selectedReceiverId);
              return iterable.map((b) {
                final amount = b.balance.abs();
                String text;
                Color color;
                if (b.balance > 0.01) {
                  text =
                      '${b.member.name} should pay ₹${amount.toStringAsFixed(2)}';
                  color = Colors.red;
                } else if (b.balance < -0.01) {
                  text =
                      '${b.member.name} will receive ₹${amount.toStringAsFixed(2)}';
                  color = Colors.green;
                } else {
                  text = '${b.member.name} is settled up';
                  color = Colors.grey;
                }
                return ListTile(
                  dense: true,
                  title: Text(text, style: TextStyle(color: color)),
                );
              }).toList();
            })(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Who should pay whom',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (transfers.isEmpty)
              const Text('Everyone is settled up.')
            else
              ...(() {
                final iterable = _selectedReceiverId == null
                    ? transfers
                    : transfers.where(
                        (t) =>
                            t.to.id == _selectedReceiverId ||
                            t.from.id == _selectedReceiverId,
                      );
                return iterable.map(
                  (t) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(
                      '${t.from.name} → ${t.to.name}: ₹${t.amount.toStringAsFixed(2)}',
                    ),
                  ),
                );
              })(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Per member summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(() {
              final membersIterable = _selectedReceiverId == null
                  ? group.members
                  : group.members.where((m) => m.id == _selectedReceiverId);
              return membersIterable.map((m) {
                final balance = balances
                    .firstWhere((b) => b.member.id == m.id)
                    .balance;
                final pays = transfers.where((t) => t.from.id == m.id).toList();
                final receives = transfers
                    .where((t) => t.to.id == m.id)
                    .toList();

                final List<Widget> lines = [];

                if (balance.abs() < 0.01) {
                  lines.add(
                    const Text(
                      'Settled up with everyone.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else if (balance > 0.01) {
                  lines.add(
                    Text(
                      'Total to pay: ₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  lines.add(
                    Text(
                      'Total to receive: ₹${(-balance).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  );
                }

                for (final t in pays) {
                  lines.add(
                    Text('Pay ${t.to.name} ₹${t.amount.toStringAsFixed(2)}'),
                  );
                }
                for (final t in receives) {
                  lines.add(
                    Text(
                      'Receive from ${t.from.name} ₹${t.amount.toStringAsFixed(2)}',
                    ),
                  );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...lines,
                      ],
                    ),
                  ),
                );
              }).toList();
            })(),
          ] else ...[
            const Text(
              'Expense-wise (to payer)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (group.expenses.isEmpty)
              const Text('No expenses yet.')
            else
              ...group.expenses.map((e) {
                final payerName = group.members
                    .firstWhere((m) => m.id == e.payerId)
                    .name;
                final list = transfersByExpense[e.id] ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: ₹${e.amount.toStringAsFixed(2)} • Paid by $payerName',
                        ),
                        const SizedBox(height: 4),
                        if (list.isEmpty)
                          const Text(
                            'No participants for this expense.',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: list
                                .map(
                                  (t) => Text(
                                    '${t.from.name} → ${t.to.name}: ₹${t.amount.toStringAsFixed(2)}',
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

// SETTLE SCREEN

class SettleScreen extends StatefulWidget {
  const SettleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<SettleScreen> createState() => _SettleScreenState();
}

class _SettleScreenState extends State<SettleScreen> {
  SplitGroup? _group;
  String? _fromId;
  String? _toId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await _storage.loadGroups();
    setState(() {
      _group = groups.firstWhere((g) => g.id == widget.groupId);
    });
  }

  Future<void> _saveSettlement() async {
    final group = _group;
    if (group == null || _fromId == null || _toId == null) return;
    if (_fromId == _toId) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final allGroups = await _storage.loadGroups();
    final idx = allGroups.indexWhere((g) => g.id == group.id);
    if (idx == -1) return;

    final settlement = Settlement(
      id: _generateId(),
      fromMemberId: _fromId!,
      toMemberId: _toId!,
      amount: amount,
      createdAt: DateTime.now(),
    );

    final updatedGroup = SplitGroup(
      id: group.id,
      name: group.name,
      description: group.description,
      members: group.members,
      expenses: group.expenses,
      settlements: [...group.settlements, settlement],
      createdAt: group.createdAt,
    );

    allGroups[idx] = updatedGroup;
    await _storage.saveGroups(allGroups);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Record settlement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who paid whom?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fromId,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: group.members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _fromId = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _toId,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: group.members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _toId = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveSettlement,
              child: const Text('Save settlement'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Previous settlements',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: group.settlements.isEmpty
                  ? const Text('No manual settlements recorded yet.')
                  : ListView.builder(
                      itemCount: group.settlements.length,
                      itemBuilder: (context, index) {
                        final s = group.settlements[index];
                        final from = group.members
                            .firstWhere((m) => m.id == s.fromMemberId)
                            .name;
                        final to = group.members
                            .firstWhere((m) => m.id == s.toMemberId)
                            .name;
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.payments_outlined),
                          title: Text(
                            '$from → $to: ₹${s.amount.toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
