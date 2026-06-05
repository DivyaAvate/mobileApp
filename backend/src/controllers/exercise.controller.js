const exerciseService = require('../services/exercise.service');

exports.getExercises = async (req, res, next) => {
    try {
        const exercises = await exerciseService.getAllExercises(req.query);
        res.json(exercises);
    } catch (e) { next(e); }
};

exports.getExerciseDetail = async (req, res, next) => {
    try {
        const exercise = await exerciseService.getExerciseById(req.params.id);
        if (!exercise) return res.status(404).json({ message: "Not found" });
        res.json(exercise);
    } catch (e) { next(e); }
};