const { WorkoutPlan, WorkoutDay, WorkoutExercise } = require('../models/workout_plan.model');
const Exercise    = require('../models/exercise.model');
const { Op }      = require('sequelize');

class WorkoutGeneratorService {

  // ── Split templates by days per week ──────────────────────
  static splits = {
    2: ['Full Body', 'Full Body'],
    3: ['Push', 'Pull', 'Legs'],
    4: ['Upper', 'Lower', 'Push', 'Pull'],
    5: ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms'],
    6: ['Push', 'Pull', 'Legs', 'Push', 'Pull', 'Legs'],
  };

  static muscleMapping = {
    'Push':      ['chest', 'shoulders', 'triceps'],
    'Pull':      ['back', 'biceps'],
    'Legs':      ['legs', 'glutes'],
    'Upper':     ['chest', 'back', 'shoulders'],
    'Lower':     ['legs', 'core', 'glutes'],
    'Full Body': ['chest', 'back', 'legs', 'shoulders'],
    'Chest':     ['chest'],
    'Back':      ['back'],
    'Shoulders': ['shoulders'],
    'Arms':      ['biceps', 'triceps'],
  };

  // ── Generate a full plan ───────────────────────────────────
  async generate(userId, { goal, experience, daysPerWeek }) {
    const days = parseInt(daysPerWeek);

    // Fallback to closest supported split
    const supportedDays = Object.keys(WorkoutGeneratorService.splits).map(Number);
    const resolvedDays  = supportedDays.includes(days)
      ? days
      : supportedDays.reduce((a, b) =>
          Math.abs(b - days) < Math.abs(a - days) ? b : a
        );

    // Deactivate all previous plans for this user
    await WorkoutPlan.update({ isActive: false }, { where: { userId } });

    const plan     = await WorkoutPlan.create({ userId, goal, experience, daysPerWeek: resolvedDays, isActive: true });
    const dayNames = WorkoutGeneratorService.splits[resolvedDays];
    const exCount  = experience === 'beginner' ? 4 : experience === 'intermediate' ? 5 : 6;

    for (let i = 0; i < dayNames.length; i++) {
      const dayName      = dayNames[i];
      const targetMuscles = WorkoutGeneratorService.muscleMapping[dayName] ?? ['chest'];

      const day = await WorkoutDay.create({
        planId:    plan.id,
        dayName,
        dayNumber: i + 1,
      });

      // Fetch random exercises safely (works MySQL + PostgreSQL)
      const allExercises = await Exercise.findAll({
        where: { muscleGroup: { [Op.in]: targetMuscles } },
      });

      // Shuffle in JS instead of RAND() / RANDOM() SQL
      const shuffled  = allExercises.sort(() => Math.random() - 0.5);
      const exercises = shuffled.slice(0, exCount);

      if (exercises.length === 0) continue; // skip day if no exercises found

      const rows = exercises.map((ex, idx) => {
        const isCompound         = idx === 0;
        const { sets, reps }     = this._setsReps(goal, isCompound);
        return {
          dayId:      day.id,
          exerciseId: ex.id,
          sets,
          reps,
          order:      idx,
        };
      });

      await WorkoutExercise.bulkCreate(rows);
    }

    return this.getPlanDetails(plan.id);
  }

  // ── Sets/reps logic by goal ────────────────────────────────
  _setsReps(goal, isCompound) {
    switch (goal) {
      case 'strength':
        return { sets: 5,                    reps: isCompound ? '3-5'   : '6-8'   };
      case 'muscle_gain':
        return { sets: isCompound ? 4 : 3,   reps: isCompound ? '6-10'  : '10-12' };
      case 'fat_loss':
        return { sets: 3,                    reps: '12-15' };
      default:
        return { sets: 3,                    reps: '10-12' };
    }
  }

  // ── Fetch full plan with days + exercises ──────────────────
  async getPlanDetails(planId) {
    return await WorkoutPlan.findByPk(planId, {
      include: [{
        model: WorkoutDay,
        as:    'days',
        include: [{
          model: WorkoutExercise,
          as:    'exercises',
          include: [{
            model: Exercise,   // explicit model ref instead of string alias
            as:    'details',
          }],
        }],
      }],
    });
  }
}

module.exports = new WorkoutGeneratorService();