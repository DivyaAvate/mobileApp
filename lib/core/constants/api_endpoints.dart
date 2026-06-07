class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base ──────────────────────────────────────────────────
  // Android emulator → 10.0.2.2 maps to your PC's localhost
  // Real device (same WiFi) → use your PC IP e.g. 192.168.1.5
  static const baseUrl = 'http://10.0.2.2:5000';

  // ─── Auth → /api/auth ──────────────────────────────────────
  static const login        = '/api/auth/login';
  static const register     = '/api/auth/register';
  static const googleAuth   = '/api/auth/google';
  static const refreshToken = '/api/auth/refresh-token';
  static const logout       = '/api/auth/logout';
  static const profile      = '/api/auth/profile';

  // ─── Exercises → /api/exercises ────────────────────────────
  static const exercises      = '/api/exercises';
  static const exerciseDetail = '/api/exercises/:id';

  static const workoutGenerate = '/api/workout/generate';
  static const workoutCurrent  = '/api/workout/current';

  // ─── Gym → /api/gyms ───────────────────────────────────────
  static const gyms           = '/api/gyms';
  static const joinGym        = '/api/gyms/join';
  static const myGym          = '/api/gyms/my-gym';
  static const createGym      = '/api/gyms/create';
  static String gymMembers(String gymId)         => '/api/gyms/$gymId/members';
  static String memberData(String gymId, String memberId) => '/api/gyms/$gymId/members/$memberId';
  static String gymOffers(String gymId)          => '/api/gyms/$gymId/offers';
  static String deleteOffer(String gymId, String offerId) => '/api/gyms/$gymId/offers/$offerId';

  // ─── Progress → /api/progress ─────────────────────────────
  static const progress    = '/api/progress';
  static const progressLog = '/api/progress/log';

  // ─── Steps → /api/steps ────────────────────────────────────
  static const stepsSync   = '/api/steps/sync';
  static const stepsTrends = '/api/steps/trends';
  static const stepsToday  = '/api/steps/today';

  // ─── AI Coach → /api/coach ─────────────────────────────────
  static const aiChat = '/api/coach/ask';
  static const workoutFinish = '/api/tracking/finish'; // append /:id in code
  static const logSet        = '/api/tracking/set';

  // ─── Dashboard → /api/dashboard ────────────────────────────
  static const dashboard    = '/api/dashboard';
  static const achievements = '/api/dashboard/achievements';
  static const leaderboard  = '/api/dashboard/leaderboard';
  static const recovery     = '/api/dashboard/recovery';
}