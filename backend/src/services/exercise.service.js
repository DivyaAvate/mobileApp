const Exercise = require('../models/exercise.model');
const { Op } = require('sequelize');

class ExerciseService {
    async getAllExercises(filters) {
        const { search, muscleGroup, equipment } = filters;
        let queryOptions = { where: {} };

        if (search) {
            queryOptions.where.name = { [Op.like]: `%${search}%` };
        }
        if (muscleGroup) {
            queryOptions.where.muscleGroup = muscleGroup;
        }
        if (equipment) {
            queryOptions.where.equipment = equipment;
        }

        return await Exercise.findAll(queryOptions);
    }

    async getExerciseById(id) {
        return await Exercise.findByPk(id);
    }
}

module.exports = new ExerciseService();