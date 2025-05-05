require('dotenv').config();
const path = require('path');
let dbPath = path.join(__dirname, "db.include.js");
pool = require(dbPath);



module.exports = {

    async addRating(p_user_id, p_game_id, p_rating, p_comment) {
        try {
            let sql = "CALL add_game_rating(?, ?, ?, ?)";
            const [rows, fields] = await pool.execute(sql, [p_user_id, p_game_id, p_rating, p_comment]);
            console.log("ADDED Rating for game " + p_game_id + " by user " + p_user_id);
            return rows;
        }
        catch (err) {
            console.log(err);
            throw err;
        }
    },


};