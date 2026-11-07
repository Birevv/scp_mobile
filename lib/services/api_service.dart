import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiResponse {
  final bool success;
  final int statusCode;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
  });

  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
}

/// ApiService - HTTP Client terintegrasi penuh dengan Laravel Sanctum REST API (`/api/*`)
/// Sesuai dengan kontrak `SCP_SMK/routes/api.php` dan `ApiResponser` Trait.
class ApiService {
  String _baseUrl;
  String? _authToken;
  final http.Client _client;
  void Function()? onUnauthorized;

  ApiService({
    String baseUrl = const String.fromEnvironment(
      'SCP_API_URL',
      defaultValue: 'http://10.0.2.2:8000/api',
    ),
    http.Client? client,
    this.onUnauthorized,
  })  : _baseUrl = baseUrl,
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  bool get hasToken => _authToken != null && _authToken!.isNotEmpty;

  void setBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    _baseUrl =
        trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$cleanPath');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  ApiResponse _parseResponse(http.Response response, {bool isLogin = false}) {
    if (!isLogin && response.statusCode == 401) {
      onUnauthorized?.call();
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final bool isOk = (decoded['success'] == true) ||
            (decoded['status'] == 'success') ||
            (response.statusCode >= 200 &&
                response.statusCode < 300 &&
                decoded['success'] != false);

        String msg =
            (decoded['message'] ?? (isOk ? 'Berhasil' : 'Terjadi kesalahan'))
                .toString();
        if (isLogin && response.statusCode == 401) {
          msg = 'Username atau kata sandi tidak sesuai.';
        }

        return ApiResponse(
          success: isOk,
          statusCode: response.statusCode,
          message: msg,
          data: decoded['data'] ?? decoded,
          errors: decoded['errors'] is Map<String, dynamic>
              ? decoded['errors'] as Map<String, dynamic>
              : null,
        );
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      return const ApiResponse(
        success: false,
        statusCode: 401,
        message: 'Username atau kata sandi tidak sesuai.',
      );
    }

    return ApiResponse(
      success: response.statusCode >= 200 && response.statusCode < 300,
      statusCode: response.statusCode,
      message: response.statusCode >= 500
          ? 'Terjadi gangguan pada server sekolah. Silakan coba beberapa saat lagi.'
          : 'Permintaan tidak dapat diproses (HTTP ${response.statusCode}).',
    );
  }

  static const ApiResponse _networkErrorResponse = ApiResponse(
    success: false,
    statusCode: 0,
    message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
  );

  Future<ApiResponse> get(String path, {Map<String, String>? query}) async {
    try {
      final res = await _client
          .get(_uri(path, query), headers: _headers())
          .timeout(const Duration(seconds: 8));
      return _parseResponse(res);
    } catch (_) {
      return _networkErrorResponse;
    }
  }

  Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    bool isLogin = false,
  }) async {
    try {
      final res = await _client
          .post(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res, isLogin: isLogin);
    } catch (_) {
      return _networkErrorResponse;
    }
  }

  Future<ApiResponse> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .put(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(res);
    } catch (_) {
      return _networkErrorResponse;
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final res = await _client
          .delete(_uri(path), headers: _headers())
          .timeout(const Duration(seconds: 8));
      return _parseResponse(res);
    } catch (_) {
      return _networkErrorResponse;
    }
  }

  Future<ApiResponse> postMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      request.headers.addAll(_headers(isJson: false));
      request.fields.addAll(fields);

      if (fileField != null) {
        if (fileBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
              fileBytes,
              filename: fileName ?? 'upload.jpg',
            ),
          );
        } else if (filePath != null && filePath.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              filePath,
              filename: fileName,
            ),
          );
        }
      }

      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);
      return _parseResponse(response);
    } catch (_) {
      return _networkErrorResponse;
    }
  }

  // ===========================================================================
  // AUTH & PROFILE ENDPOINTS (`routes/api.php`)
  // ===========================================================================

  /// POST `/api/login`
  Future<ApiResponse> login({
    required String loginIdentifier,
    required String password,
  }) async {
    final res = await post(
      '/login',
      {
        'login': loginIdentifier,
        'username': loginIdentifier,
        'identity_number': loginIdentifier,
        'password': password,
      },
      isLogin: true,
    );
    if (res.success && res.data is Map) {
      final token = res.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
      }
    }
    return res;
  }

  /// POST `/api/logout`
  Future<ApiResponse> logout() async {
    final res = await post('/logout', {});
    setAuthToken(null);
    return res;
  }

  /// GET `/api/me`
  Future<ApiResponse> fetchMe() => get('/me');

  /// PUT `/api/profile`
  Future<ApiResponse> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) =>
      put('/profile', {
        'full_name': fullName,
        'email': email,
        'phone': phone,
      });

  /// PUT `/api/profile/password`
  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) =>
      put('/profile/password', {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });

  /// POST `/api/forgot-password/send-otp`
  Future<ApiResponse> sendForgotPasswordOtp({required String email}) =>
      post('/forgot-password/send-otp', {'email': email});

  /// POST `/api/forgot-password/reset`
  Future<ApiResponse> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) =>
      post('/forgot-password/reset', {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

  // ===========================================================================
  // REFERENCE ENDPOINTS (`/api/references/*`)
  // ===========================================================================

  Future<ApiResponse> fetchClassrooms() => get('/references/classrooms');
  Future<ApiResponse> fetchRooms() => get('/references/rooms');
  Future<ApiResponse> fetchSubjects() => get('/references/subjects');
  Future<ApiResponse> fetchCalendarEvents({
    int? month,
    int? year,
    String? grade,
  }) {
    final q = <String, String>{};
    if (month != null) q['month'] = month.toString();
    if (year != null) q['year'] = year.toString();
    if (grade != null) q['grade'] = grade;
    return get('/references/calendar-events', query: q);
  }

  // ===========================================================================
  // STUDENT ENDPOINTS (`/api/student/*`)
  // ===========================================================================

  Future<ApiResponse> fetchStudentDashboard() => get('/student/dashboard');
  Future<ApiResponse> fetchStudentTodaySchedules() =>
      get('/student/schedules/today');
  Future<ApiResponse> fetchStudentAttendanceSummary() =>
      get('/student/attendance-summary');
  Future<ApiResponse> fetchStudentAttendanceHistory({
    int? month,
    int? year,
    int page = 1,
  }) {
    final q = <String, String>{'page': page.toString()};
    if (month != null) q['month'] = month.toString();
    if (year != null) q['year'] = year.toString();
    return get('/student/attendance-history', query: q);
  }

  Future<ApiResponse> fetchStudentLeaveRequests() =>
      get('/student/leave-requests');

  Future<ApiResponse> storeStudentLeaveRequest({
    required String startDate,
    required String endDate,
    required String reasonType,
    String? leaveTime,
    required String description,
    String? attachmentFilePath,
    Uint8List? attachmentBytes,
    String? attachmentFileName,
  }) {
    final fields = <String, String>{
      'start_date': startDate,
      'end_date': endDate,
      'reason_type': reasonType,
      if (leaveTime != null && leaveTime.isNotEmpty) 'leave_time': leaveTime,
      'description': description,
    };

    if (attachmentFilePath != null || attachmentBytes != null) {
      return postMultipart(
        '/student/leave-requests',
        fields: fields,
        fileField: 'attachment_photo',
        filePath: attachmentFilePath,
        fileBytes: attachmentBytes,
        fileName: attachmentFileName,
      );
    }

    return post('/student/leave-requests', fields);
  }

  Future<ApiResponse> deleteStudentLeaveRequest(String id) =>
      delete('/student/leave-requests/$id');

  // ===========================================================================
  // TEACHER ENDPOINTS (`/api/teacher/*`)
  // ===========================================================================

  Future<ApiResponse> fetchTeacherDashboard() => get('/teacher/dashboard');

  Future<ApiResponse> fetchTeacherSchedules({
    String? cycleType,
    String? classroomId,
  }) {
    final q = <String, String>{};
    if (cycleType != null) q['cycle_type'] = cycleType;
    if (classroomId != null) q['classroom_id'] = classroomId;
    return get('/teacher/schedules', query: q);
  }

  Future<ApiResponse> storeTeacherSchedule({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required int classroomId,
    required int roomId,
    required int subjectId,
    required String cycleType,
  }) =>
      post('/teacher/schedules', {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'classroom_id': classroomId,
        'room_id': roomId,
        'subject_id': subjectId,
        'cycle_type': cycleType,
      });

  Future<ApiResponse> fetchScheduleStudents(String scheduleId) =>
      get('/teacher/schedules/$scheduleId/students');

  Future<ApiResponse> fetchTeacherJournals({
    int? month,
    int? year,
    String? cycleType,
  }) {
    final q = <String, String>{};
    if (month != null) q['month'] = month.toString();
    if (year != null) q['year'] = year.toString();
    if (cycleType != null) q['cycle_type'] = cycleType;
    return get('/teacher/journals', query: q);
  }

  Future<ApiResponse> storeTeacherJournal({
    required String scheduleId,
    required String date,
    required String teachingMaterial,
    required String notes,
    required List<Map<String, dynamic>> attendances,
    String? photoFilePath,
    Uint8List? photoBytes,
    String? photoFileName,
  }) {
    final fields = <String, String>{
      'schedule_id': scheduleId,
      'date': date,
      'teaching_material': teachingMaterial,
      'notes': notes,
    };

    for (var i = 0; i < attendances.length; i++) {
      final att = attendances[i];
      fields['attendances[$i][student_id]'] = att['student_id'].toString();
      fields['attendances[$i][status]'] = att['status'].toString();
      if (att['notes'] != null && att['notes'].toString().isNotEmpty) {
        fields['attendances[$i][notes]'] = att['notes'].toString();
      }
    }

    return postMultipart(
      '/teacher/journals',
      fields: fields,
      fileField: 'activity_photo',
      filePath: photoFilePath,
      fileBytes: photoBytes,
      fileName: photoFileName ?? 'activity_photo.jpg',
    );
  }

  // ===========================================================================
  // HOMEROOM & BK ENDPOINTS (`/api/homeroom/*`)
  // ===========================================================================

  Future<ApiResponse> fetchHomeroomDashboard({int? classroomId}) {
    final q = <String, String>{};
    if (classroomId != null) q['classroom_id'] = classroomId.toString();
    return get('/homeroom/dashboard', query: q);
  }

  Future<ApiResponse> fetchHomeroomLeaveRequests({String? status}) {
    final q = <String, String>{};
    if (status != null && status != 'All') q['status'] = status;
    return get('/homeroom/leave-requests', query: q);
  }

  Future<ApiResponse> fetchHomeroomLeaveDetail(String id) =>
      get('/homeroom/leave-requests/$id');

  Future<ApiResponse> verifyHomeroomLeaveRequest({
    required String id,
    required String status, // 'Approved' | 'Rejected'
    String? rejectionNote,
  }) =>
      put('/homeroom/leave-requests/$id/verify', {
        'status': status,
        'rejection_note': ?rejectionNote,
        'notes': ?rejectionNote,
      });
}
