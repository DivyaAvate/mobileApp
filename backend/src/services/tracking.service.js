const { WorkoutLog, ExerciseLog, SetLog } = require('../models/tracking.model');
const gamificationService = require('./gamification.service');

class TrackingService {

  // ── Start workout session ──────────────────────────────────
  async startWorkout({ userId, planId, workoutDay }) {
    return await WorkoutLog.create({
      userId,
      planId:     planId ?? null,
      workoutDay: workoutDay ?? null,
      status:    'active',
      startTime:  new Date(),
    });
  }

  // ── Log a single set ───────────────────────────────────────
  async logSet({ userId, sessionId, exerciseId, setNumber, weight, reps }) {
    // Find or create exercise log for this session
    let [exerciseLog] = await ExerciseLog.findOrCreate({
      where: { workoutLogId: sessionId, exerciseId },
      defaults: { workoutLogId: sessionId, exerciseId },
    });

    // PR check — highest weight ever logged for this exercise by this user
    const maxWeight = await SetLog.max('weight', {
      include: [{
        model: ExerciseLog,
        where: { exerciseId },
        include: [{ model: WorkoutLog, where: { userId } }],
      }],
    });

    const isPR = weight > (maxWeight || 0);

    const set = await SetLog.create({
      exerciseLogId: exerciseLog.id,
      setNumber,
      weight,
      reps,
      isPR,
    });

    return { id: set.id, isPR };
  }

  // ── Finish workout session ─────────────────────────────────
  async finishWorkout({ userId, sessionId, durationSec, totalSets, totalVolume, exercises }) {
    const session = await WorkoutLog.findOne({
      where: { id: sessionId, userId }, // ensure user owns this session
    });

    if (!session) throw new Error('Session not found');

    // Save summary to DB
    await session.update({
      endTime:     new Date(),
      status:      'completed',
      durationSec: durationSec ?? 0,
      totalSets:   totalSets   ?? 0,
      totalVolume: totalVolume ?? 0,
    });

    // Award XP and check for new achievements
    const gamification = await gamificationService.processWorkoutCompletion({
      userId,
      durationSec,
      totalVolume,
      totalSets,
    });

    return {
      xpEarned:     gamification.xpEarned,
      newLevel:     gamification.newLevel     ?? null,
      achievements: gamification.achievements ?? [],
    };
  }
}

module.exports = new TrackingService();