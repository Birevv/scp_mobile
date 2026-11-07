import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';

enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
  connectionError,
}

class AppState extends ChangeNotifier {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  AppState({
    ApiService? apiService,
    TokenStorage? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? const SecureTokenStorage() {
    _apiService.onUnauthorized = _handleUnauthorizedSession;
  }

  factory AppState.forTesting({
    UserProfile? user,
    TokenStorage? tokenStorage,
    ApiService? apiService,
  }) {
    final state = AppState(
      apiService: apiService,
      tokenStorage: tokenStorage ?? MemoryTokenStorage(),
    );
    if (user != null) {
      state._currentUser = user;
      state._authStatus = AuthStatus.authenticated;
    }
    return state;
  }

  void setTestUser(UserProfile user) {
    _currentUser = user;
    _authStatus = AuthStatus.authenticated;
    notifyListeners();
  }

  ApiService get apiService => _apiService;
  TokenStorage get tokenStorage => _tokenStorage;

  // ===========================================================================
  // AUTHENTICATION & SESSION STATE
  // ===========================================================================
  AuthStatus _authStatus = AuthStatus.checking;
  AuthStatus get authStatus => _authStatus;
  bool get isAuthenticated =>
      _authStatus == AuthStatus.authenticated && _currentUser != null;

  String? _authErrorMessage;
  String? get authErrorMessage => _authErrorMessage;

  UserProfile? _currentUser;
  UserProfile get currentUser =>
      _currentUser ??
      const UserProfile(
        id: '',
        name: '-',
        identifier: '-',
        role: UserRole.unsupported,
        className: '-',
        email: '-',
        avatarUrl: '',
      );

  UserRole get currentRole => _currentUser?.role ?? UserRole.unsupported;

  // ===========================================================================
  // GLOBAL ACADEMIC CONFIGURATION STATE (FROM BACKEND)
  // ===========================================================================
  CycleType _activeCycle = CycleType.putaran1;
  CycleType get activeCycle => _activeCycle;

  bool _isScheduleLocked = false;
  bool get isScheduleLocked => _isScheduleLocked;

  String _currentDateLabel = '';
  String get currentDateLabel => _currentDateLabel.isNotEmpty
      ? _currentDateLabel
      : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

  String _currentTimeLabel = '';
  String get currentTimeLabel => _currentTimeLabel.isNotEmpty
      ? _currentTimeLabel
      : DateFormat('HH:mm').format(DateTime.now());

  AcademicEventInfo _todayEvent = const AcademicEventInfo(
    title: 'Hari Sekolah Efektif (KBM Normal)',
    category: 'effective_day',
    categoryLabel: 'Hari Sekolah Efektif',
    isHoliday: false,
    disableKbm: false,
    requiresAttendance: true,
  );
  AcademicEventInfo get todayEvent => _todayEvent;

  // ===========================================================================
  // LOADING & ERROR STATES PER FEATURE
  // ===========================================================================
  bool _isLoadingDashboard = false;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? _dashboardError;
  String? get dashboardError => _dashboardError;

  bool _isLoadingSchedules = false;
  bool get isLoadingSchedules => _isLoadingSchedules;
  String? _schedulesError;
  String? get schedulesError => _schedulesError;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;
  String? _historyError;
  String? get historyError => _historyError;

  bool _isLoadingLeaves = false;
  bool get isLoadingLeaves => _isLoadingLeaves;
  String? _leavesError;
  String? get leavesError => _leavesError;

  bool _isLoadingJournals = false;
  bool get isLoadingJournals => _isLoadingJournals;
  String? _journalsError;
  String? get journalsError => _journalsError;

  bool _isLoadingRoster = false;
  bool get isLoadingRoster => _isLoadingRoster;
  String? _rosterError;
  String? get rosterError => _rosterError;

  bool _isLoadingReferences = false;
  bool get isLoadingReferences => _isLoadingReferences;
  String? _referencesError;
  String? get referencesError => _referencesError;

  // ===========================================================================
  // OPERATIONAL DATA STORES (POPULATED EXCLUSIVELY FROM BACKEND API)
  // ===========================================================================
  StudentAttendanceSummary _studentSummary = const StudentAttendanceSummary();
  StudentAttendanceSummary get studentSummary => _studentSummary;

  HomeroomAttendanceSummary _homeroomSummary =
      const HomeroomAttendanceSummary();
  HomeroomAttendanceSummary get homeroomSummary => _homeroomSummary;

  int _pendingLeaveCount = 0;
  int get pendingLeaveCount => _pendingLeaveCount;

  List<TeachingSchedule> _todaySchedules = [];
  List<TeachingSchedule> get todaySchedules => _todaySchedules;

  List<TeachingSchedule> _teachingSchedules = [];
  List<TeachingSchedule> get teachingSchedules => _teachingSchedules;

  List<DelayedJournalAlert> _delayedJournalAlerts = [];
  List<DelayedJournalAlert> get delayedJournalAlerts => _delayedJournalAlerts;

  List<LeaveRequest> _leaveRequests = [];
  List<LeaveRequest> get leaveRequests => _leaveRequests;

  List<StudentAttendance> _personalHistory = [];
  List<StudentAttendance> get personalHistory => _personalHistory;

  List<StudentAttendance> _classRoster = [];
  List<StudentAttendance> get classRoster => _classRoster;

  TeachingSchedule? _selectedJournalSchedule;
  TeachingSchedule? get selectedJournalSchedule => _selectedJournalSchedule;

  List<TeachingJournal> _teachingJournals = [];
  List<TeachingJournal> get teachingJournals => _teachingJournals;

  List<ReferenceOption> _classrooms = [];
  List<ReferenceOption> get classrooms => _classrooms;

  List<ReferenceOption> _rooms = [];
  List<ReferenceOption> get rooms => _rooms;

  List<ReferenceOption> _subjects = [];
  List<ReferenceOption> get subjects => _subjects;

  int? _selectedHomeroomClassroomId;
  int? get selectedHomeroomClassroomId => _selectedHomeroomClassroomId;

  // Computed Teacher Schedule Metrics (From Today's Backend Schedules)
  List<TeachingSchedule> get activeCycleSchedules => _todaySchedules.isNotEmpty
      ? _todaySchedules
      : _teachingSchedules.where((s) => s.cycle == _activeCycle).toList();

  int get totalTodaySchedulesCount => _todaySchedules.length;
  int get filledJournalsTodayCount =>
      _todaySchedules.where((s) => s.hasJournal).length;
  int get unfilledJournalsTodayCount =>
      _todaySchedules.where((s) => !s.hasJournal).length;

  void selectScheduleForJournal(TeachingSchedule schedule) {
    _selectedJournalSchedule = schedule;
    notifyListeners();
  }

  // ===========================================================================
  // 1. TOKEN VALIDATION ON APP START (`GET /api/me`)
  // ===========================================================================
  Future<AuthStatus> checkInitialAuth() async {
    _authStatus = AuthStatus.checking;
    _authErrorMessage = null;
    notifyListeners();

    final savedUrl = await _tokenStorage.readBaseUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _apiService.setBaseUrl(savedUrl);
    }

    final savedToken = await _tokenStorage.readToken();
    if (savedToken == null || savedToken.isEmpty) {
      // Kondisi C — Tidak ada token
      _apiService.setAuthToken(null);
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return _authStatus;
    }

    _apiService.setAuthToken(savedToken);
    final res = await _apiService.fetchMe();

    if (res.success && res.data is Map<String, dynamic>) {
      // Kondisi A — Token valid
      final userMap = res.data['user'] is Map<String, dynamic>
          ? res.data['user'] as Map<String, dynamic>
          : res.data as Map<String, dynamic>;
      _currentUser = UserProfile.fromJson(userMap);
      _authStatus = AuthStatus.authenticated;
      notifyListeners();
      await loadInitialDataForCurrentRole();
      return _authStatus;
    }

    if (res.isNetworkError) {
      // Kondisi D — Backend tidak dapat dihubungi
      _authStatus = AuthStatus.connectionError;
      _authErrorMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      notifyListeners();
      return _authStatus;
    }

    // Kondisi B — Token tidak valid atau kedaluwarsa (HTTP 401 / 403)
    await _tokenStorage.deleteToken();
    _apiService.setAuthToken(null);
    _currentUser = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
    return _authStatus;
  }

  // ===========================================================================
  // 2. REAL BACKEND LOGIN (`POST /api/login`)
  // ===========================================================================
  Future<ApiResponse> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
  }) async {
    _authErrorMessage = null;
    final res = await _apiService.login(
      loginIdentifier: identifier.trim(),
      password: password,
    );

    if (!res.success) {
      if (res.isNetworkError) {
        _authErrorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (res.statusCode == 401 || res.statusCode == 422) {
        _authErrorMessage = 'Username atau kata sandi tidak sesuai.';
      } else {
        _authErrorMessage = res.message;
      }
      notifyListeners();
      return ApiResponse(
        success: false,
        statusCode: res.statusCode,
        message: _authErrorMessage!,
        errors: res.errors,
      );
    }

    final dataMap = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final token = dataMap['token']?.toString() ?? _apiService.authToken;

    if (token == null || token.isEmpty) {
      _authErrorMessage = 'Token autentikasi tidak ditemukan dari server.';
      notifyListeners();
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: _authErrorMessage!,
      );
    }

    _apiService.setAuthToken(token);
    await _tokenStorage.saveToken(token);
    if (rememberMe) {
      await _tokenStorage.saveUsername(identifier.trim());
    } else {
      await _tokenStorage.saveUsername(null);
    }

    if (dataMap['user'] is Map<String, dynamic>) {
      _currentUser = UserProfile.fromJson(
        dataMap['user'] as Map<String, dynamic>,
      );
    } else {
      final meRes = await _apiService.fetchMe();
      if (meRes.success && meRes.data is Map<String, dynamic>) {
        _currentUser = UserProfile.fromJson(
          meRes.data as Map<String, dynamic>,
        );
      }
    }

    if (_currentUser == null) {
      await _tokenStorage.deleteToken();
      _apiService.setAuthToken(null);
      _authStatus = AuthStatus.unauthenticated;
      _authErrorMessage = 'Gagal memuat profil pengguna dari server.';
      notifyListeners();
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: _authErrorMessage!,
      );
    }

    _authStatus = AuthStatus.authenticated;
    notifyListeners();
    await loadInitialDataForCurrentRole();

    return res;
  }

  // ===========================================================================
  // 3. LOGOUT & SESSION CLEANUP (`POST /api/logout`)
  // ===========================================================================
  Future<void> logout() async {
    try {
      if (_apiService.hasToken) {
        await _apiService.logout();
      }
    } catch (_) {}
    await _clearSessionData();
  }

  void _handleUnauthorizedSession() {
    _clearSessionData();
  }

  Future<void> _clearSessionData() async {
    await _tokenStorage.deleteToken();
    _apiService.setAuthToken(null);
    _currentUser = null;
    _authStatus = AuthStatus.unauthenticated;
    _authErrorMessage = null;

    _studentSummary = const StudentAttendanceSummary();
    _homeroomSummary = const HomeroomAttendanceSummary();
    _pendingLeaveCount = 0;
    _todaySchedules = [];
    _teachingSchedules = [];
    _delayedJournalAlerts = [];
    _leaveRequests = [];
    _personalHistory = [];
    _classRoster = [];
    _selectedJournalSchedule = null;
    _teachingJournals = [];
    _classrooms = [];
    _rooms = [];
    _subjects = [];
    _selectedHomeroomClassroomId = null;

    _dashboardError = null;
    _schedulesError = null;
    _historyError = null;
    _leavesError = null;
    _journalsError = null;
    _rosterError = null;
    _referencesError = null;
    notifyListeners();
  }

  Future<void> updateServerBaseUrl(String newUrl) async {
    _apiService.setBaseUrl(newUrl);
    await _tokenStorage.saveBaseUrl(_apiService.baseUrl);
    notifyListeners();
  }

  // ===========================================================================
  // 4. ROLE-BASED INITIAL DATA LOADING
  // ===========================================================================
  Future<void> loadInitialDataForCurrentRole() async {
    if (!isAuthenticated || _currentUser == null) return;

    switch (_currentUser!.role) {
      case UserRole.siswa:
        await Future.wait([
          fetchStudentDashboardData(),
          fetchStudentLeavesData(),
          fetchStudentHistoryData(),
        ]);
        break;
      case UserRole.guru:
        await Future.wait([
          fetchTeacherDashboardData(),
          fetchTeacherSchedulesData(),
          fetchTeacherJournalsData(),
          fetchReferenceData(),
        ]);
        break;
      case UserRole.waliKelas:
      case UserRole.guruBk:
        await Future.wait([
          fetchHomeroomDashboardData(),
          fetchHomeroomLeavesData(),
        ]);
        break;
      case UserRole.unsupported:
        break;
    }
  }

  // ===========================================================================
  // 5. STUDENT API INTEGRATIONS (`/api/student/*`)
  // ===========================================================================
  Future<void> fetchStudentDashboardData() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    final dashRes = await _apiService.fetchStudentDashboard();
    if (!dashRes.success) {
      _isLoadingDashboard = false;
      _dashboardError = dashRes.message;
      notifyListeners();
      return;
    }

    if (dashRes.data is Map<String, dynamic>) {
      final map = dashRes.data as Map<String, dynamic>;
      final classroom = (map['classroom'] ?? '').toString();
      if (classroom.isNotEmpty && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(className: classroom);
      }

      if (map['current_date'] != null) {
        _currentDateLabel = map['current_date'].toString();
      }

      if (map['attendance_summary'] is Map<String, dynamic>) {
        _studentSummary = StudentAttendanceSummary.fromJson(
          map['attendance_summary'] as Map<String, dynamic>,
        );
      }

      _pendingLeaveCount = (map['pending_leave_count'] as num?)?.toInt() ?? 0;

      final rawSchedules = map['today_schedules'];
      if (rawSchedules is List) {
        _todaySchedules = rawSchedules
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => TeachingSchedule.fromJson(
                item,
                fallbackCycle: _activeCycle,
              ),
            )
            .toList();
        if (_todaySchedules.isNotEmpty) {
          _activeCycle = _todaySchedules.first.cycle;
        }
      }
    }

    // Fetch today's academic event status from attendance-summary endpoint
    final summaryRes = await _apiService.fetchStudentAttendanceSummary();
    if (summaryRes.success && summaryRes.data is Map<String, dynamic>) {
      final sumMap = summaryRes.data as Map<String, dynamic>;
      if (sumMap['today_event'] is Map<String, dynamic>) {
        _todayEvent = AcademicEventInfo.fromJson(
          sumMap['today_event'] as Map<String, dynamic>,
        );
      } else {
        _todayEvent = const AcademicEventInfo(
          title: 'Hari Sekolah Efektif (KBM Normal)',
          category: 'effective_day',
          categoryLabel: 'Hari Sekolah Efektif',
          isHoliday: false,
          disableKbm: false,
          requiresAttendance: true,
        );
      }
    }

    _isLoadingDashboard = false;
    notifyListeners();
  }

  Future<void> fetchStudentSchedulesData() async {
    _isLoadingSchedules = true;
    _schedulesError = null;
    notifyListeners();

    final res = await _apiService.fetchStudentTodaySchedules();
    if (!res.success) {
      _isLoadingSchedules = false;
      _schedulesError = res.message;
      notifyListeners();
      return;
    }

    final list = _extractList(res.data);
    _todaySchedules = list
        .map(
          (item) => TeachingSchedule.fromJson(
            item,
            fallbackCycle: _activeCycle,
          ),
        )
        .toList();
    _teachingSchedules = List<TeachingSchedule>.from(_todaySchedules);
    if (_todaySchedules.isNotEmpty) {
      _activeCycle = _todaySchedules.first.cycle;
    }

    _isLoadingSchedules = false;
    notifyListeners();
  }

  Future<void> fetchStudentHistoryData({int? month, int? year}) async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    final res = await _apiService.fetchStudentAttendanceHistory(
      month: month,
      year: year,
    );
    if (!res.success) {
      _isLoadingHistory = false;
      _historyError = res.message;
      notifyListeners();
      return;
    }

    final list = _extractList(res.data);
    _personalHistory = list
        .map(
          (item) => StudentAttendance.fromHistoryJson(
            item,
            fallbackStudentName: currentUser.name,
            fallbackNisn: currentUser.identifier,
            fallbackClassName: currentUser.className,
          ),
        )
        .toList();

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> fetchStudentLeavesData() async {
    _isLoadingLeaves = true;
    _leavesError = null;
    notifyListeners();

    final res = await _apiService.fetchStudentLeaveRequests();
    if (!res.success) {
      _isLoadingLeaves = false;
      _leavesError = res.message;
      notifyListeners();
      return;
    }

    final list = _extractList(res.data);
    _leaveRequests = list
        .map(
          (item) => LeaveRequest.fromJson(
            item,
            fallbackStudentName: currentUser.name,
            fallbackNisn: currentUser.identifier,
            fallbackClass: currentUser.className,
          ),
        )
        .toList();
    _pendingLeaveCount =
        _leaveRequests.where((r) => r.status == LeaveStatus.pending).length;

    _isLoadingLeaves = false;
    notifyListeners();
  }

  Future<ApiResponse> submitStudentLeaveRequest({
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? leaveTime,
    String? attachmentFilePath,
    Uint8List? attachmentBytes,
    String? attachmentFileName,
  }) async {
    final res = await _apiService.storeStudentLeaveRequest(
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      reasonType: type.apiValue,
      leaveTime: type.requiresLeaveTime ? leaveTime : null,
      description: reason,
      attachmentFilePath: attachmentFilePath,
      attachmentBytes: attachmentBytes,
      attachmentFileName: attachmentFileName,
    );

    if (res.success) {
      await Future.wait([
        fetchStudentLeavesData(),
        fetchStudentDashboardData(),
      ]);
    }
    return res;
  }

  Future<ApiResponse> cancelStudentLeaveRequest(String requestId) async {
    final res = await _apiService.deleteStudentLeaveRequest(requestId);
    if (res.success) {
      _leaveRequests.removeWhere((r) => r.id == requestId);
      _pendingLeaveCount =
          _leaveRequests.where((r) => r.status == LeaveStatus.pending).length;
      notifyListeners();
      await fetchStudentDashboardData();
    }
    return res;
  }

  // ===========================================================================
  // 6. TEACHER API INTEGRATIONS (`/api/teacher/*`)
  // ===========================================================================
  Future<void> fetchTeacherDashboardData() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    final res = await _apiService.fetchTeacherDashboard();
    if (!res.success) {
      _isLoadingDashboard = false;
      _dashboardError = res.message;
      notifyListeners();
      return;
    }

    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      if (map['current_time'] != null) {
        _currentTimeLabel = map['current_time'].toString();
      }
      if (map['current_date'] != null) {
        _currentDateLabel = map['current_date'].toString();
      }
      if (map['active_cycle'] != null) {
        _activeCycle = CycleType.fromString(map['active_cycle'].toString());
      }
      _isScheduleLocked = map['is_schedule_locked'] == true;

      final todayName = DateFormat('EEEE', 'id_ID').format(DateTime.now());
      final rawToday = _extractList(map['today_schedules']);
      _todaySchedules = rawToday
          .map(
            (item) => TeachingSchedule.fromJson(
              item,
              fallbackTeacher: currentUser.name,
              fallbackDay: todayName,
              fallbackCycle: _activeCycle,
            ),
          )
          .toList();

      if (_selectedJournalSchedule == null && _todaySchedules.isNotEmpty) {
        _selectedJournalSchedule = _todaySchedules.firstWhere(
          (s) => !s.hasJournal,
          orElse: () => _todaySchedules.first,
        );
      }

      final rawPending = _extractList(map['pending_journals']);
      _delayedJournalAlerts = rawPending.map((item) {
        final schedId = (item['schedule_id'] ?? '').toString();
        final match = _todaySchedules
            .where((s) => s.id == schedId)
            .firstOrNull;
        return DelayedJournalAlert(
          scheduleId: schedId,
          subjectName:
              (item['subject_name'] ?? match?.subjectName ?? '-').toString(),
          className:
              (item['classroom_name'] ?? match?.className ?? '-').toString(),
          roomName: (item['room_name'] ?? match?.roomName ?? '-').toString(),
          timeSlot: match != null
              ? '${match.startTime} - ${match.endTime} WIB'
              : (item['time_slot'] ?? '').toString(),
          minutesLate: (item['minutes_late'] as num?)?.toInt() ?? 45,
          message:
              (item['message'] ?? 'Jurnal mengajar belum diisi').toString(),
        );
      }).toList();
    }

    _isLoadingDashboard = false;
    notifyListeners();
  }

  Future<void> fetchTeacherSchedulesData({CycleType? cycle}) async {
    _isLoadingSchedules = true;
    _schedulesError = null;
    notifyListeners();

    final targetCycle = cycle ?? _activeCycle;
    final res = await _apiService.fetchTeacherSchedules(
      cycleType: targetCycle.label,
    );

    if (!res.success) {
      _isLoadingSchedules = false;
      _schedulesError = res.message;
      notifyListeners();
      return;
    }

    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      if (map['active_cycle'] != null && cycle == null) {
        _activeCycle = CycleType.fromString(map['active_cycle'].toString());
      }
      _isScheduleLocked = map['is_schedule_locked'] == true;

      final parsed = <TeachingSchedule>[];
      final schedulesNode = map['schedules'];
      if (schedulesNode is Map<String, dynamic>) {
        schedulesNode.forEach((dayKey, dayList) {
          for (final item in _extractList(dayList)) {
            final sched = TeachingSchedule.fromJson(
              item,
              fallbackTeacher: currentUser.name,
              fallbackDay: dayKey,
              fallbackCycle: targetCycle,
            );
            final todayMatch = _todaySchedules
                .where((t) => t.id == sched.id)
                .firstOrNull;
            parsed.add(
              todayMatch != null
                  ? sched.copyWith(hasJournal: todayMatch.hasJournal)
                  : sched,
            );
          }
        });
      } else if (schedulesNode is List) {
        for (final item in _extractList(schedulesNode)) {
          parsed.add(
            TeachingSchedule.fromJson(
              item,
              fallbackTeacher: currentUser.name,
              fallbackCycle: targetCycle,
            ),
          );
        }
      }
      _teachingSchedules = parsed;
      if (_selectedJournalSchedule == null && _teachingSchedules.isNotEmpty) {
        _selectedJournalSchedule = _teachingSchedules.first;
      }
    }

    _isLoadingSchedules = false;
    notifyListeners();
  }

  Future<void> fetchReferenceData() async {
    _isLoadingReferences = true;
    _referencesError = null;
    notifyListeners();

    final results = await Future.wait([
      _apiService.fetchClassrooms(),
      _apiService.fetchRooms(),
      _apiService.fetchSubjects(),
    ]);

    if (!results[0].success || !results[1].success || !results[2].success) {
      _isLoadingReferences = false;
      _referencesError = results
          .firstWhere((r) => !r.success, orElse: () => results[0])
          .message;
      notifyListeners();
      return;
    }

    _classrooms = _extractList(results[0].data)
        .map(ReferenceOption.fromJson)
        .toList();
    _rooms = _extractList(results[1].data)
        .map(ReferenceOption.fromJson)
        .toList();
    _subjects = _extractList(results[2].data)
        .map(ReferenceOption.fromJson)
        .toList();

    _isLoadingReferences = false;
    notifyListeners();
  }

  Future<ApiResponse> createTeacherSchedule({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required int classroomId,
    required int roomId,
    required int subjectId,
    required CycleType cycle,
  }) async {
    final res = await _apiService.storeTeacherSchedule(
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      classroomId: classroomId,
      roomId: roomId,
      subjectId: subjectId,
      cycleType: cycle.label,
    );

    if (res.success) {
      await Future.wait([
        fetchTeacherDashboardData(),
        fetchTeacherSchedulesData(cycle: cycle),
      ]);
    }
    return res;
  }

  Future<void> fetchScheduleStudentsRoster(String scheduleId) async {
    _isLoadingRoster = true;
    _rosterError = null;
    notifyListeners();

    final res = await _apiService.fetchScheduleStudents(scheduleId);
    if (!res.success) {
      _isLoadingRoster = false;
      _rosterError = res.message;
      notifyListeners();
      return;
    }

    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      String className = '-';
      String subjectName = '-';
      if (map['schedule'] is Map<String, dynamic>) {
        final schedMap = map['schedule'] as Map<String, dynamic>;
        className = (schedMap['classroom_name'] ?? '-').toString();
        subjectName = (schedMap['subject_name'] ?? '-').toString();
        _selectedJournalSchedule = TeachingSchedule.fromJson(
          schedMap,
          fallbackTeacher: currentUser.name,
          fallbackCycle: _activeCycle,
        );
      }

      final studentsList = _extractList(map['students']);
      _classRoster = studentsList
          .map(
            (s) => StudentAttendance.fromScheduleRosterJson(
              s,
              className: className,
              subjectName: subjectName,
              teacherName: currentUser.name,
            ),
          )
          .toList();
    }

    _isLoadingRoster = false;
    notifyListeners();
  }

  Future<ApiResponse> submitTeacherJournalData({
    required String scheduleId,
    required String topic,
    required String notes,
    required List<StudentAttendance> roster,
    String? photoFilePath,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    final attendancesPayload = roster
        .map(
          (s) => <String, dynamic>{
            'student_id': s.studentId ?? int.tryParse(s.id) ?? 0,
            'status': s.status.label,
            if (s.notes != null && s.notes!.isNotEmpty) 'notes': s.notes,
          },
        )
        .toList();

    final res = await _apiService.storeTeacherJournal(
      scheduleId: scheduleId,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      teachingMaterial: topic,
      notes: notes.isNotEmpty ? notes : '-',
      attendances: attendancesPayload,
      photoFilePath: photoFilePath,
      photoBytes: photoBytes,
      photoFileName: photoFileName,
    );

    if (res.success) {
      await Future.wait([
        fetchTeacherDashboardData(),
        fetchTeacherJournalsData(),
      ]);
    }
    return res;
  }

  Future<void> fetchTeacherJournalsData({
    int? month,
    int? year,
    CycleType? cycle,
  }) async {
    _isLoadingJournals = true;
    _journalsError = null;
    notifyListeners();

    final res = await _apiService.fetchTeacherJournals(
      month: month,
      year: year,
      cycleType: cycle?.label,
    );

    if (!res.success) {
      _isLoadingJournals = false;
      _journalsError = res.message;
      notifyListeners();
      return;
    }

    final list = _extractList(res.data);
    _teachingJournals = list
        .map(
          (item) => TeachingJournal.fromJson(
            item,
            teacherName: currentUser.name,
          ),
        )
        .toList();

    _isLoadingJournals = false;
    notifyListeners();
  }

  // ===========================================================================
  // 7. HOMEROOM & GURU BK API INTEGRATIONS (`/api/homeroom/*`)
  // ===========================================================================
  Future<void> fetchHomeroomDashboardData({int? classroomId}) async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    if (classroomId != null) {
      _selectedHomeroomClassroomId = classroomId;
    }
    notifyListeners();

    // For Guru BK, load classrooms reference if not yet loaded so BK can select a classroom
    if (currentRole == UserRole.guruBk && _classrooms.isEmpty) {
      final clsRes = await _apiService.fetchClassrooms();
      if (clsRes.success) {
        _classrooms = _extractList(clsRes.data)
            .map(ReferenceOption.fromJson)
            .toList();
        if (_selectedHomeroomClassroomId == null && _classrooms.isNotEmpty) {
          _selectedHomeroomClassroomId = _classrooms.first.id;
        }
      }
    }

    final dashRes = await _apiService.fetchHomeroomDashboard(
      classroomId: classroomId ?? _selectedHomeroomClassroomId,
    );

    if (!dashRes.success) {
      // If Guru BK has no classrooms in DB or 403, still allow viewing leave requests if leaves succeed
      if (currentRole == UserRole.guruBk && dashRes.statusCode == 403) {
        _homeroomSummary = const HomeroomAttendanceSummary(
          classroomName: 'Seluruh Kelas (Guru BK)',
        );
      } else {
        _isLoadingDashboard = false;
        _dashboardError = dashRes.message;
        notifyListeners();
        return;
      }
    } else if (dashRes.data is Map<String, dynamic>) {
      final map = dashRes.data as Map<String, dynamic>;
      _homeroomSummary = HomeroomAttendanceSummary.fromDashboardJson(map);
      _pendingLeaveCount = _homeroomSummary.pendingCount;

      final clsName = _homeroomSummary.classroomName;
      if (clsName.isNotEmpty && clsName != '-' && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(className: clsName);
      }

      final rawPending = _extractList(map['pending_leave_requests']);
      if (rawPending.isNotEmpty && _leaveRequests.isEmpty) {
        _leaveRequests = rawPending
            .map(
              (item) => LeaveRequest.fromJson(
                item,
                fallbackClass: clsName,
              ),
            )
            .toList();
      }
    }

    _isLoadingDashboard = false;
    notifyListeners();
  }

  Future<void> fetchHomeroomLeavesData({String? status}) async {
    _isLoadingLeaves = true;
    _leavesError = null;
    notifyListeners();

    final res = await _apiService.fetchHomeroomLeaveRequests(status: status);
    if (!res.success) {
      _isLoadingLeaves = false;
      _leavesError = res.message;
      notifyListeners();
      return;
    }

    List<Map<String, dynamic>> list = [];
    if (res.data is Map<String, dynamic> &&
        (res.data as Map<String, dynamic>)['leave_requests'] != null) {
      list = _extractList((res.data as Map<String, dynamic>)['leave_requests']);
    } else {
      list = _extractList(res.data);
    }

    _leaveRequests = list
        .map(
          (item) => LeaveRequest.fromJson(
            item,
            fallbackClass: _homeroomSummary.classroomName != '-'
                ? _homeroomSummary.classroomName
                : currentUser.className,
          ),
        )
        .toList();
    _pendingLeaveCount =
        _leaveRequests.where((r) => r.status == LeaveStatus.pending).length;

    _isLoadingLeaves = false;
    notifyListeners();
  }

  Future<LeaveRequest?> fetchHomeroomLeaveDetailData(String id) async {
    final res = await _apiService.fetchHomeroomLeaveDetail(id);
    if (res.success && res.data is Map<String, dynamic>) {
      final detail = LeaveRequest.fromJson(
        res.data as Map<String, dynamic>,
        fallbackClass: currentUser.className,
      );
      final idx = _leaveRequests.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _leaveRequests[idx] = detail;
        notifyListeners();
      }
      return detail;
    }
    return null;
  }

  Future<ApiResponse> verifyHomeroomLeave({
    required String id,
    required bool approve,
    String? rejectionNote,
  }) async {
    final res = await _apiService.verifyHomeroomLeaveRequest(
      id: id,
      status: approve ? 'Approved' : 'Rejected',
      rejectionNote: approve ? null : rejectionNote,
    );

    if (res.success) {
      await Future.wait([
        fetchHomeroomDashboardData(),
        fetchHomeroomLeavesData(),
      ]);
    }
    return res;
  }

  // ===========================================================================
  // 8. PROFILE & PASSWORD MANAGEMENT (`/api/profile`, `/api/forgot-password/*`)
  // ===========================================================================
  Future<ApiResponse> updateProfileOnServer({
    String? fullName,
    String? name,
    required String email,
    String? phone,
  }) async {
    final effectiveName = fullName ?? name ?? _currentUser?.name ?? '';
    final effectivePhone = phone ?? _currentUser?.phone ?? '-';
    final res = await _apiService.updateProfile(
      fullName: effectiveName,
      email: email,
      phone: effectivePhone,
    );
    if (res.success) {
      if (res.data is Map<String, dynamic>) {
        _currentUser = UserProfile.fromJson(res.data as Map<String, dynamic>);
      } else if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: fullName,
          email: email,
          phone: phone,
        );
      }
      notifyListeners();
    }
    return res;
  }

  Future<ApiResponse> changePasswordOnServer({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  Future<ApiResponse> sendPasswordOtp(String email) {
    return _apiService.sendForgotPasswordOtp(email: email);
  }

  Future<ApiResponse> resetPasswordOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return _apiService.resetPasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // ===========================================================================
  // HELPER: EXTRACT LIST FROM PAGINATED OR DIRECT JSON RESPONSE
  // ===========================================================================
  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is List) {
        return (raw['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return const [];
  }
}
