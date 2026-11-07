import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/models.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/navigation/app_bottom_nav_bar.dart';

// Screens
import 'screens/shared/splash_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/unsupported_role_screen.dart';
import 'screens/siswa/siswa_dashboard_screen.dart';
import 'screens/siswa/siswa_schedule_screen.dart';
import 'screens/siswa/siswa_history_screen.dart';
import 'screens/siswa/siswa_leave_request_screen.dart';
import 'screens/siswa/siswa_leave_status_screen.dart';
import 'screens/guru/guru_dashboard_screen.dart';
import 'screens/guru/guru_schedule_input_screen.dart';
import 'screens/guru/guru_my_schedule_screen.dart';
import 'screens/guru/guru_journal_input_screen.dart';
import 'screens/guru/guru_journal_history_screen.dart';
import 'screens/wali/wali_dashboard_screen.dart';
import 'screens/wali/wali_leave_queue_screen.dart';
import 'screens/wali/wali_leave_detail_screen.dart';
import 'screens/wali/wali_students_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ScpApp());
}

class ScpApp extends StatefulWidget {
  final AppState? appState;

  const ScpApp({
    super.key,
    this.appState,
  });

  @override
  State<ScpApp> createState() => _ScpAppState();
}

class _ScpAppState extends State<ScpApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = widget.appState ?? AppState();
    _appState.checkInitialAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCP Mobile - SMK School Class Progress',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _appState,
        builder: (context, child) {
          return ScpMainShell(state: _appState);
        },
      ),
    );
  }
}

class ScpMainShell extends StatefulWidget {
  final AppState state;

  const ScpMainShell({
    super.key,
    required this.state,
  });

  @override
  State<ScpMainShell> createState() => _ScpMainShellState();
}

class _ScpMainShellState extends State<ScpMainShell> {
  String _currentRoute = '';
  LeaveRequest? _selectedLeaveDetail;

  @override
  void initState() {
    super.initState();
    _syncRouteWithAuthState();
  }

  @override
  void didUpdateWidget(covariant ScpMainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRouteWithAuthState();
  }

  void _syncRouteWithAuthState() {
    final status = widget.state.authStatus;
    if (status == AuthStatus.checking || status == AuthStatus.connectionError) {
      if (_currentRoute != 'splash') {
        _currentRoute = 'splash';
      }
    } else if (status == AuthStatus.unauthenticated) {
      if (_currentRoute != 'login') {
        _currentRoute = 'login';
      }
    } else if (status == AuthStatus.authenticated) {
      if (_currentRoute.isEmpty ||
          _currentRoute == 'splash' ||
          _currentRoute == 'login') {
        _currentRoute = _getDefaultDashboardForRole(widget.state.currentRole);
      }
    }
  }

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _navigateBack() {
    setState(() {
      switch (widget.state.currentRole) {
        case UserRole.siswa:
          _currentRoute = 'siswa_dashboard';
          break;
        case UserRole.guru:
          _currentRoute = 'guru_dashboard';
          break;
        case UserRole.waliKelas:
        case UserRole.guruBk:
          _currentRoute = 'wali_dashboard';
          break;
        case UserRole.unsupported:
          _currentRoute = 'unsupported';
          break;
      }
    });
  }

  List<AppBottomNavItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.siswa:
        return const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
            label: 'Jadwal',
          ),
          AppBottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Perizinan',
          ),
          AppBottomNavItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: 'Riwayat',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ];
      case UserRole.guru:
        return const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Jadwal',
          ),
          AppBottomNavItem(
            icon: Icons.history_edu_outlined,
            activeIcon: Icons.history_edu,
            label: 'Jurnal',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ];
      case UserRole.waliKelas:
      case UserRole.guruBk:
        return const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavItem(
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check,
            label: 'Verifikasi',
          ),
          AppBottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Siswa',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ];
      case UserRole.unsupported:
        return const [];
    }
  }

  int _getCurrentTabIndex(UserRole role) {
    switch (role) {
      case UserRole.siswa:
        if (_currentRoute == 'siswa_dashboard') return 0;
        if (_currentRoute == 'siswa_schedule') return 1;
        if (_currentRoute == 'siswa_leave_status') return 2;
        if (_currentRoute == 'siswa_history') return 3;
        if (_currentRoute == 'profile') return 4;
        return -1;

      case UserRole.guru:
        if (_currentRoute == 'guru_dashboard') return 0;
        if (_currentRoute == 'guru_my_schedule') return 1;
        if (_currentRoute == 'guru_journal_history') return 2;
        if (_currentRoute == 'profile') return 3;
        return -1;

      case UserRole.waliKelas:
      case UserRole.guruBk:
        if (_currentRoute == 'wali_dashboard') return 0;
        if (_currentRoute == 'wali_leave_queue') return 1;
        if (_currentRoute == 'wali_students') return 2;
        if (_currentRoute == 'profile') return 3;
        return -1;

      case UserRole.unsupported:
        return -1;
    }
  }

  void _onTabSelected(int index, UserRole role) {
    switch (role) {
      case UserRole.siswa:
        if (index == 0) _navigateTo('siswa_dashboard');
        if (index == 1) _navigateTo('siswa_schedule');
        if (index == 2) _navigateTo('siswa_leave_status');
        if (index == 3) _navigateTo('siswa_history');
        if (index == 4) _navigateTo('profile');
        break;

      case UserRole.guru:
        if (index == 0) _navigateTo('guru_dashboard');
        if (index == 1) _navigateTo('guru_my_schedule');
        if (index == 2) _navigateTo('guru_journal_history');
        if (index == 3) _navigateTo('profile');
        break;

      case UserRole.waliKelas:
      case UserRole.guruBk:
        if (index == 0) _navigateTo('wali_dashboard');
        if (index == 1) _navigateTo('wali_leave_queue');
        if (index == 2) _navigateTo('wali_students');
        if (index == 3) _navigateTo('profile');
        break;

      case UserRole.unsupported:
        break;
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case 'splash':
        return SplashScreen(state: widget.state);

      case 'login':
        return LoginScreen(
          state: widget.state,
          onLoginSuccess: () {
            setState(() {
              _currentRoute =
                  _getDefaultDashboardForRole(widget.state.currentRole);
            });
          },
        );

      case 'unsupported':
        return UnsupportedRoleScreen(state: widget.state);

      case 'profile':
        return ProfileScreen(
          state: widget.state,
          onLogout: () {
            setState(() {
              _currentRoute = 'login';
            });
          },
        );

      // Siswa screens
      case 'siswa_dashboard':
        return SiswaDashboardScreen(
          state: widget.state,
          onNavigate: _navigateTo,
        );

      case 'siswa_schedule':
        return SiswaScheduleScreen(
          state: widget.state,
          onBack: _navigateBack,
        );

      case 'siswa_history':
        return SiswaHistoryScreen(
          state: widget.state,
          onBack: _navigateBack,
        );

      case 'siswa_leave_request':
        return SiswaLeaveRequestScreen(
          state: widget.state,
          onBack: _navigateBack,
          onSuccess: () => _navigateTo('siswa_leave_status'),
        );

      case 'siswa_leave_status':
        return SiswaLeaveStatusScreen(
          state: widget.state,
          onBack: _navigateBack,
          onNewRequest: () => _navigateTo('siswa_leave_request'),
        );

      // Guru screens
      case 'guru_dashboard':
        return GuruDashboardScreen(
          state: widget.state,
          onNavigate: _navigateTo,
        );

      case 'guru_schedule_input':
        return GuruScheduleInputScreen(
          state: widget.state,
          onBack: _navigateBack,
          onSuccess: () => _navigateTo('guru_my_schedule'),
        );

      case 'guru_my_schedule':
        return GuruMyScheduleScreen(
          state: widget.state,
          onBack: _navigateBack,
          onAddSchedule: () => _navigateTo('guru_schedule_input'),
        );

      case 'guru_journal_input':
        return GuruJournalInputScreen(
          state: widget.state,
          onBack: _navigateBack,
          onSuccess: () => _navigateTo('guru_journal_history'),
        );

      case 'guru_journal_history':
        return GuruJournalHistoryScreen(
          state: widget.state,
          onBack: _navigateBack,
        );

      // Wali Kelas & Guru BK screens
      case 'wali_dashboard':
        return WaliDashboardScreen(
          state: widget.state,
          onNavigate: _navigateTo,
        );

      case 'wali_leave_queue':
        return WaliLeaveQueueScreen(
          state: widget.state,
          onBack: _navigateBack,
          onSelectDetail: (req) {
            setState(() {
              _selectedLeaveDetail = req;
              _currentRoute = 'wali_leave_detail';
            });
          },
        );

      case 'wali_leave_detail':
        final targetRequest = _selectedLeaveDetail ??
            (widget.state.leaveRequests.isNotEmpty
                ? widget.state.leaveRequests.first
                : null);

        if (targetRequest == null) {
          return WaliLeaveQueueScreen(
            state: widget.state,
            onBack: _navigateBack,
            onSelectDetail: (req) {
              setState(() {
                _selectedLeaveDetail = req;
                _currentRoute = 'wali_leave_detail';
              });
            },
          );
        }

        return WaliLeaveDetailScreen(
          state: widget.state,
          request: targetRequest,
          onBack: () => _navigateTo('wali_leave_queue'),
          onCompleted: () => _navigateTo('wali_leave_queue'),
        );

      case 'wali_students':
        return WaliStudentsScreen(
          state: widget.state,
          onBack: _navigateBack,
        );

      default:
        if (widget.state.currentRole == UserRole.unsupported) {
          return UnsupportedRoleScreen(state: widget.state);
        }
        return SiswaDashboardScreen(
          state: widget.state,
          onNavigate: _navigateTo,
        );
    }
  }

  String _getDefaultDashboardForRole(UserRole role) {
    switch (role) {
      case UserRole.siswa:
        return 'siswa_dashboard';
      case UserRole.guru:
        return 'guru_dashboard';
      case UserRole.waliKelas:
      case UserRole.guruBk:
        return 'wali_dashboard';
      case UserRole.unsupported:
        return 'unsupported';
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncRouteWithAuthState();

    final currentRole = widget.state.currentRole;
    final int activeTabIndex = _getCurrentTabIndex(currentRole);
    final bool showBottomNav = activeTabIndex >= 0 &&
        widget.state.isAuthenticated &&
        currentRole != UserRole.unsupported &&
        _currentRoute != 'splash' &&
        _currentRoute != 'login' &&
        _currentRoute != 'unsupported';

    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: showBottomNav
          ? AppBottomNavBar(
              currentIndex: activeTabIndex,
              items: _getNavItemsForRole(currentRole),
              onIndexChanged: (idx) => _onTabSelected(idx, currentRole),
            )
          : null,
    );
  }
}
