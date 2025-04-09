const express = require('express');
const userRepo = require('../utils/user.repository');
const auth = require("../utils/user.auth");


const router = express.Router();

router.get('/list', auth.authorizeRequest("ADMIN"), userListAction);
router.get('/show/:userId', auth.authorizeRequest("ADMIN"), userShowAction);
router.get('/del/:userId', auth.authorizeRequest("ADMIN"), userDelAction);
router.post('/update/:userId', auth.authorizeRequest("ADMIN"), userUpdateAction);

async function userListAction(request, response) {
    try {
        var users = await userRepo.getAllUsers();
        response.send(JSON.stringify(users));
    } catch (error) {
        response.status(500).json({ error: 'Failed to fetch users' });
    }
}

async function userShowAction(request, response) {
    try {
        var oneUser = await userRepo.getUserById(request.params.userId);
        if (oneUser) {
            response.send(JSON.stringify(oneUser));
        } else {
            response.status(404).json({ error: 'User not found' });
        }
    } catch (error) {
        response.status(500).json({ error: 'Failed to fetch user' });
    }
}

async function userDelAction(request, response) {
    try {
        var numRows = await userRepo.deleteUser(request.params.userId);
        let result = { rowsDeleted: numRows };
        response.send(JSON.stringify(result));
    } catch (error) {
        response.status(500).json({ error: 'Failed to delete user' });
    }
}

async function userUpdateAction(request, response) {
    try {
        if (!request.body) {
            return response.status(400).json({ error: 'No data provided in request body' });
        }

        const userId = request.params.userId;
        let result;

        if (userId === "0") {
            // Add new user
            const newUserId = await userRepo.addUser(
                request.body.user_name,
                request.body.user_email,
                request.body.user_password,
                request.body.user_role
            );
            result = { userId: newUserId, message: 'User added successfully' };
        } else {
            // Update existing user
            const numRows = await userRepo.updateUser(
                userId,
                request.body.user_name,
                request.body.user_email,
                request.body.user_password,
                request.body.user_role
            );
            result = { rowsUpdated: numRows };
        }

        response.json(result);
    } catch (error) {
        response.status(500).json({ error: 'Failed to process request' });
    }
}

module.exports = router;