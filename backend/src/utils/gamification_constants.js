module.exports = {
  // ── XP Rewards ─────────────────────────────────────────────
  WORKOUT_COMPLETE_XP: 150,   // matches gamification.service.js
  XP_PER_PR:          50,
  XP_PER_1000_STEPS:  10,

  // ── Level Curve ────────────────────────────────────────────
  LEVEL_BASE_XP:      500,    // XP needed for Level 1 → 2
  LEVEL_MULTIPLIER:   1.5,    // each level is 1.5× harder
};