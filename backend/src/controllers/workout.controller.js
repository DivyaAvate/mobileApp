const generator = require('../services/workout_generator.service');
const { WorkoutPlan } = require('../models/workout_plan.model');

exports.generatePlan = async (req, res, next) => {
    try {
        const plan = await generator.generate(req.user.id, req.body);
        res.status(201).json(plan);
    } catch (e) { next(e); }
};

exports.getCurrentPlan = async (req, res, next) => {
    try {
        const plan = await WorkoutPlan.findOne({
            where: { userId: req.user.id, isActive: true },
            order: [['createdAt', 'DESC']]
        });
        if (!plan) return res.status(404).json({ message: "No active plan found" });
        const details = await generator.getPlanDetails(plan.id);
        res.json(details);
    } catch (e) { next(e); }
};