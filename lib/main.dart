
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const SmartCampusApp());
}

// USER MODEL
class CampusUser {
  final String name;
  final String username;
  final String password;
  final String role;

  CampusUser({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });
}

// MAIN APPLICATION
class SmartCampusApp extends StatefulWidget {
  const SmartCampusApp({super.key});

  @override
  State<SmartCampusApp> createState() => _SmartCampusAppState();
}

class _SmartCampusAppState extends State<SmartCampusApp> {
  final List<CampusUser> users = [];
  CampusUser? currentUser;

  @override
  void initState() {
    super.initState();

    users.addAll([
      CampusUser(
        name: 'Sample Student',
        username: 'student',
        password: 'student123',
        role: 'Student',
      ),
      CampusUser(
        name: 'Sample Teacher',
        username: 'teacher',
        password: 'teacher123',
        role: 'Teacher',
      ),
      CampusUser(
        name: 'Campus Administrator',
        username: 'admin',
        password: 'admin123',
        role: 'Admin',
      ),
    ]);
  }

  void registerUser(CampusUser user) {
    setState(() => users.add(user));
  }

  bool login(String username, String password) {
    for (final user in users) {
      if (user.username.toLowerCase() ==
              username.trim().toLowerCase() &&
          user.password == password) {
        setState(() => currentUser = user);
        return true;
      }
    }
    return false;
  }

  void logout() {
    setState(() => currentUser = null);
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Widget authPage() {
    return AuthScreen(
      users: users,
      onRegister: registerUser,
      onLogin: login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185ADB),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/login': (context) => authPage(),

        '/dashboard': (context) {
          if (currentUser == null) return authPage();

          return DashboardScreen(
            user: currentUser!,
            onLogout: logout,
          );
        },

        '/profile': (context) {
          if (currentUser == null) return authPage();

          return ProfileScreen(user: currentUser!);
        },

        '/showcase': (context) {
          if (currentUser == null) return authPage();

          return const UIShowcaseScreen();
        },
      },
    );
  }
}

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF176B87),
              Color(0xFF64B6AC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 88,
                color: Colors.white,
              ),
              SizedBox(height: 18),
              Text(
                'Smart Campus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your university, all in one place',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 28),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// AUTHENTICATION SCREEN
class AuthScreen extends StatefulWidget {
  final List<CampusUser> users;
  final void Function(CampusUser) onRegister;
  final bool Function(String, String) onLogin;

  const AuthScreen({
    super.key,
    required this.users,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginUsername = TextEditingController();
  final _loginPassword = TextEditingController();
  final _name = TextEditingController();
  final _registerUsername = TextEditingController();
  final _registerPassword = TextEditingController();

  String _role = 'Student';
  bool _isRegistering = false;
  bool _hideLoginPassword = true;
  bool _hideRegisterPassword = true;

  @override
  void dispose() {
    _loginUsername.dispose();
    _loginPassword.dispose();
    _name.dispose();
    _registerUsername.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_loginFormKey.currentState!.validate()) return;

    final success = widget.onLogin(
      _loginUsername.text,
      _loginPassword.text,
    );

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Check your username and password.'),
        ),
      );
    }
  }

  void _submitRegistration() {
    if (!_registerFormKey.currentState!.validate()) return;

    final username = _registerUsername.text.trim();

    final alreadyExists = widget.users.any(
      (user) => user.username.toLowerCase() == username.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That username is already registered.'),
        ),
      );
      return;
    }

    widget.onRegister(
      CampusUser(
        name: _name.text.trim(),
        username: username,
        password: _registerPassword.text,
        role: _role,
      ),
    );

    _loginUsername.text = username;
    _loginPassword.clear();

    setState(() => _isRegistering = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful. Please log in.'),
      ),
    );
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isRegistering
                      ? _buildRegisterForm()
                      : _buildLoginForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandHeader() {
    return Column(
      children: [
        Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFE7EEFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 38,
            color: Color(0xFF185ADB),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Smart Campus',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your university, all in one place',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _brandHeader(),
          const Text(
            'Login',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginUsername,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => _requiredField(value, 'a username'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPassword,
            obscureText: _hideLoginPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hideLoginPassword = !_hideLoginPassword;
                  });
                },
                icon: Icon(
                  _hideLoginPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) => _requiredField(value, 'a password'),
            onFieldSubmitted: (_) => _submitLogin(),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _submitLogin,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Login'),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isRegistering = true),
            child: const Text('New here? Create an account'),
          ),
          const Divider(height: 24),
          const Text(
            'Demo accounts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text('Student: student / student123'),
          const Text('Teacher: teacher / teacher123'),
          const Text('Admin: admin / admin123'),
          const SizedBox(height: 5),
          const Text(
            'Demo only: accounts are stored temporarily in memory.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _brandHeader(),
          const Text(
            'Create an account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) => _requiredField(value, 'your full name'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _registerUsername,
            decoration: const InputDecoration(
              labelText: 'Choose a username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              final error = _requiredField(value, 'a username');
              if (error != null) return error;
              if (value!.trim().length < 3) {
                return 'Username must have at least 3 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _registerPassword,
            obscureText: _hideRegisterPassword,
            decoration: InputDecoration(
              labelText: 'Choose a password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hideRegisterPassword = !_hideRegisterPassword;
                  });
                },
                icon: Icon(
                  _hideRegisterPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              final error = _requiredField(value, 'a password');
              if (error != null) return error;
              if (value!.length < 6) {
                return 'Password must have at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(
              labelText: 'Register as',
              prefixIcon: Icon(Icons.admin_panel_settings_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Student', child: Text('Student')),
              DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _submitRegistration,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Register'),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isRegistering = false),
            child: const Text('Already registered? Back to login'),
          ),
          const Text(
            'Role selection is demonstrational. A real app must enforce '
            'privileged roles on a secure backend.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// NAVIGATION DRAWER
class CampusDrawer extends StatelessWidget {
  final CampusUser user;
  final VoidCallback onLogout;

  const CampusDrawer({
    super.key,
    required this.user,
    required this.onLogout,
  });

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF185ADB), Color(0xFF4979E8)],
              ),
            ),
            accountName: Text(user.name),
            accountEmail: Text('${user.role} • ${user.username}'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 38,
                color: Color(0xFF185ADB),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _navigate(context, '/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () => _navigate(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('UI Showcase'),
            onTap: () => _navigate(context, '/showcase'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

// INTERACTIVE ANIMATED WELCOME CARD
class AnimatedWelcomeCard extends StatefulWidget {
  final String name;

  const AnimatedWelcomeCard({
    super.key,
    required this.name,
  });

  @override
  State<AnimatedWelcomeCard> createState() => _AnimatedWelcomeCardState();
}

class _AnimatedWelcomeCardState extends State<AnimatedWelcomeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _expanded ? 190 : 150,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _expanded
                ? [
                    const Color(0xFF176B87),
                    const Color(0xFF64B6AC),
                  ]
                : [
                    const Color(0xFF185ADB),
                    const Color(0xFF4979E8),
                  ],
          ),
          borderRadius: BorderRadius.circular(
            _expanded ? 30 : 22,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.waving_hand,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome, ${widget.name}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _expanded
                  ? 'Your Smart Campus workspace is ready. Tap again to close.'
                  : 'Tap this card to see the animation.',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// DASHBOARD
class DashboardScreen extends StatelessWidget {
  final CampusUser user;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  List<CampusFeature> _featuresForRole(String role) {
    if (role == 'Teacher') {
      return const [
        CampusFeature(
          title: 'Class overview',
          description: 'Review your teaching and class information.',
          icon: Icons.groups_outlined,
        ),
        CampusFeature(
          title: 'Assignments',
          description: 'Manage assignment-related information.',
          icon: Icons.assignment_outlined,
        ),
        CampusFeature(
          title: 'Announcements',
          description: 'Prepare notices for students.',
          icon: Icons.campaign_outlined,
        ),
      ];
    }

    if (role == 'Admin') {
      return const [
        CampusFeature(
          title: 'User management',
          description: 'Administrative user options.',
          icon: Icons.manage_accounts_outlined,
        ),
        CampusFeature(
          title: 'Campus announcements',
          description: 'Review campus-wide notices.',
          icon: Icons.campaign_outlined,
        ),
        CampusFeature(
          title: 'System overview',
          description: 'View a sample administration overview.',
          icon: Icons.dashboard_outlined,
        ),
      ];
    }

    return const [
      CampusFeature(
        title: 'Attendance',
        description: 'View your attendance information.',
        icon: Icons.fact_check_outlined,
      ),
      CampusFeature(
        title: 'Assignments',
        description: 'Review assignment information.',
        icon: Icons.assignment_outlined,
      ),
      CampusFeature(
        title: 'Announcements',
        description: 'Read university notices.',
        icon: Icons.campaign_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final features = _featuresForRole(user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Campus'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: CampusDrawer(
        user: user,
        onLogout: onLogout,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AnimatedWelcomeCard(name: user.name),
            const SizedBox(height: 24),
            const Text(
              'Your campus services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (feature) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE7EEFF),
                    child: Icon(
                      feature.icon,
                      color: const Color(0xFF185ADB),
                    ),
                  ),
                  title: Text(feature.title),
                  subtitle: Text(feature.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${feature.title}: demo feature'),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('My Profile'),
                subtitle: const Text('View your account information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.widgets),
                title: const Text('UI Showcase'),
                subtitle: const Text('Explore Flutter widgets'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/showcase');
                },
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Educational prototype: university records are not connected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  final CampusUser user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      drawer: CampusDrawer(
        user: user,
        onLogout: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFE7EEFF),
            child: Icon(
              Icons.person,
              size: 65,
              color: Color(0xFF185ADB),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user.role,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Full Name'),
                  subtitle: Text(user.name),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Username'),
                  subtitle: Text(user.username),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Account Role'),
                  subtitle: Text(user.role),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// UI SHOWCASE SCREEN
class UIShowcaseScreen extends StatelessWidget {
  const UIShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Showcase'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Flutter Widget Gallery',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Examples of common Flutter widgets and layouts.',
            style: TextStyle(color: Colors.black54),
          ),

          // TEXT
          const SizedBox(height: 20),
          const Text(
            '1. Text Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('This is an example of a Flutter Text widget.'),

          // BUTTONS
          const SizedBox(height: 20),
          const Text(
            '2. Buttons',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Text Button'),
              ),
            ],
          ),

          // ICON
          const SizedBox(height: 20),
          const Text(
            '3. Icon Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Row(
            children: [
              Icon(Icons.school, size: 35, color: Colors.blue),
              SizedBox(width: 15),
              Icon(Icons.computer, size: 35, color: Colors.green),
              SizedBox(width: 15),
              Icon(Icons.book, size: 35, color: Colors.orange),
            ],
          ),

          // CONTAINER
          const SizedBox(height: 20),
          const Text(
            '4. Container Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 90,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Flutter Container',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // ROW AND COLUMN
          const SizedBox(height: 20),
          const Text(
            '5. Row and Column',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.home, size: 30),
                    Icon(Icons.person, size: 30),
                    Icon(Icons.settings, size: 30),
                  ],
                ),
                SizedBox(height: 15),
                Text('Widgets arranged using Row and Column'),
              ],
            ),
          ),

          // CARD
          const SizedBox(height: 20),
          const Text(
            '6. Card Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.school, color: Colors.blue),
              title: Text('Campus Card'),
              subtitle: Text('An example of a Flutter Card.'),
            ),
          ),

          // EXPANDED AND FLEXIBLE
          const SizedBox(height: 20),
          const Text(
            '7. Expanded and Flexible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Expanded',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Card(
                  color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Flexible',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // STACK
          const SizedBox(height: 20),
          const Text(
            '8. Stack and Positioned',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 130,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Positioned(
                  right: 15,
                  top: 15,
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                const Positioned(
                  left: 15,
                  bottom: 35,
                  child: Text(
                    'Stack Example',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // GRID
          const SizedBox(height: 20),
          const Text(
            '9. GridView',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width < 400 ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: const [
              ShowcaseGridItem(icon: Icons.book, title: 'Books'),
              ShowcaseGridItem(icon: Icons.people, title: 'Students'),
              ShowcaseGridItem(icon: Icons.event, title: 'Events'),
              ShowcaseGridItem(icon: Icons.computer, title: 'Computer'),
              ShowcaseGridItem(icon: Icons.school, title: 'Education'),
              ShowcaseGridItem(icon: Icons.settings, title: 'Settings'),
            ],
          ),

          // IMAGE
          const SizedBox(height: 20),
          const Text(
            '10. Image Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Image.network(
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const Text('Image unavailable'),
              );
            },
          ),

          // WEBVIEW
          const SizedBox(height: 20),
          const Text(
            '11. Embedded WebView',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const WebPagePanel(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

// GRID ITEM
class ShowcaseGridItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ShowcaseGridItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}

// WEBVIEW PANEL
class WebPagePanel extends StatefulWidget {
  const WebPagePanel({super.key});

  @override
  State<WebPagePanel> createState() => _WebPagePanelState();
}

class _WebPagePanelState extends State<WebPagePanel> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev/'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

// CAMPUS FEATURE MODEL
class CampusFeature {
  final String title;
  final String description;
  final IconData icon;

  const CampusFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}
