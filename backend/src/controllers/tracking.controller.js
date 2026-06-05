const trackingService = require('../services/tracking.service');

// POST /api/tracking/start
exports.startWorkout = async (req, res, next) => {
  try {
    const session = await trackingService.startWorkout({
      userId:     req.user.id,
      planId:     req.body.planId,
      workoutDay: req.body.workoutDay,
    });
    res.status(201).json({
      sessionId: session.id,
      startTime: session.startTime,
      message:   'Workout session started',
    });
  } catch (e) { next(e); }
};

// POST /api/tracking/set
exports.logSet = async (req, res, next) => {
  try {
    const set = await trackingService.logSet({
      userId:     req.user.id,
      sessionId:  req.body.sessionId,
      exerciseId: req.body.exerciseId,
      setNumber:  req.body.setNumber,
      weight:     req.body.weight,
      reps:       req.body.reps,
    });
    res.status(201).json({
      setId: set.id,
      isPR:  set.isPR,
      message: 'Set logged',
    });
  } catch (e) { next(e); }
};

// POST /api/tracking/finish/:id
exports.finishWorkout = async (req, res, next) => {
  try {
    const result = await trackingService.finishWorkout({
      userId:      req.user.id,
      sessionId:   req.params.id,          // from URL :id
      durationSec: req.body.duration_sec,
      totalSets:   req.body.total_sets,
      totalVolume: req.body.total_volume,
      exercises:   req.body.exercises,
    });
    res.status(200).json({
      xpEarned:    result.xpEarned,
      newLevel:    result.newLevel,
      achievements: result.achievements,   // any new badges unlocked
      message:     'Workout saved successfully',
    });
  } catch (e) { next(e); }
};