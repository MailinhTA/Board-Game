USE  boardgames;


############################################################################
########################### VIEWS ##########################################
############################################################################

-- View of top-rated games with relevant details
CREATE OR REPLACE VIEW v_top_rated_games AS
SELECT g.id, g.primary_name, g.average_rating, g.users_rated, g.yearpublished, 
    g.minplayers, g.maxplayers, g.playingtime, g.bgg_rank
FROM games g
WHERE g.users_rated > 100
ORDER BY g.average_rating DESC, g.users_rated DESC;

-- View showing game details with designer counts
CREATE OR REPLACE VIEW v_game_designer_counts AS
SELECT g.id, g.primary_name, g.yearpublished, g.average_rating,
    COUNT(gd.designer_id) AS designer_count
FROM games g
LEFT JOIN game_designers gd ON g.id = gd.game_id
GROUP BY g.id;

-- View showing games with their categories as comma-separated list
CREATE OR REPLACE VIEW v_games_with_categories AS
SELECT g.id, g.primary_name, g.average_rating,
    GROUP_CONCAT(c.category_name ORDER BY c.category_name SEPARATOR ', ') AS categories
FROM games g
LEFT JOIN game_categories gc ON g.id = gc.game_id
LEFT JOIN categories c ON gc.category_id = c.category_id
GROUP BY g.id;

-- View showing games with their mechanics as comma-separated list
CREATE OR REPLACE VIEW v_games_with_mechanics AS
SELECT g.id, g.primary_name, g.average_rating,
    GROUP_CONCAT(m.mechanic_name ORDER BY m.mechanic_name SEPARATOR ', ') AS mechanics
FROM games g
LEFT JOIN game_mechanics gm ON g.id = gm.game_id
LEFT JOIN mechanics m ON gm.mechanic_id = m.mechanic_id
GROUP BY g.id;

-- View showing most prolific designers with their game counts
CREATE OR REPLACE VIEW v_designer_game_counts AS
SELECT d.designer_id, d.designer_name, 
    COUNT(gd.game_id) AS game_count,
    AVG(g.average_rating) AS avg_game_rating
FROM designers d
JOIN game_designers gd ON d.designer_id = gd.designer_id
JOIN games g ON gd.game_id = g.id
GROUP BY d.designer_id
ORDER BY game_count DESC;

-- View showing games suitable for families (by age and player count)
CREATE OR REPLACE VIEW v_family_games AS
SELECT g.id, g.primary_name, g.average_rating, g.yearpublished,
    g.minplayers, g.maxplayers, g.playingtime, g.minage
FROM games g
WHERE g.minage <= 10
AND g.maxplayers >= 4
AND g.playingtime <= 90
ORDER BY g.average_rating DESC;

-- View showing user rating activity
CREATE OR REPLACE VIEW v_user_rating_summary AS
SELECT u.user_id, u.user_name,
    COUNT(gr.rating_id) AS total_ratings,
    AVG(gr.rating) AS avg_rating_given,
    MIN(gr.rating_date) AS first_rating,
    MAX(gr.rating_date) AS last_rating
FROM users u
LEFT JOIN game_ratings gr ON u.user_id = gr.user_id
GROUP BY u.user_id, u.user_name;





############################################################################
########################### INDEXES ########################################
############################################################################

-- Create indexes for performance
CREATE INDEX idx_game_year ON games(yearpublished);
CREATE INDEX idx_game_rating ON games(average_rating DESC);
CREATE INDEX idx_game_rank ON games(bgg_rank);
CREATE INDEX idx_game_players ON games(minplayers, maxplayers);
CREATE INDEX idx_game_playtime ON games(playingtime);
CREATE INDEX idx_game_users_rated ON games(users_rated DESC);




############################################################################
########################### TRIGGERS #######################################
############################################################################

-- Trigger to update games table when a rating is added
DROP TRIGGER IF EXISTS after_game_rating_insert;
DELIMITER //
CREATE TRIGGER after_game_rating_insert 
AFTER INSERT ON game_ratings
FOR EACH ROW
BEGIN
    -- Update average_rating and users_rated in games table
    UPDATE games
    SET 
        users_rated = users_rated + 1
        -- average_rating = (
        --     SELECT AVG(rating) 
        --     FROM game_ratings 
        --     WHERE game_id = NEW.game_id
        -- )
    WHERE id = NEW.game_id;
END//
DELIMITER ;

-- Trigger to update games table when a rating is updated
DROP TRIGGER IF EXISTS after_game_rating_update;
DELIMITER //

-- CREATE TRIGGER after_game_rating_update
-- AFTER UPDATE ON game_ratings
-- FOR EACH ROW
-- BEGIN
--     -- Update average_rating in games table (users_rated doesn't change on update)
--     UPDATE games
--     SET 
--         average_rating = (
--             SELECT AVG(rating) 
--             FROM game_ratings 
--             WHERE game_id = NEW.game_id
--         )
--     WHERE id = NEW.game_id;
-- END//
-- DELIMITER ;

-- Trigger to update games table when a rating is deleted
DROP TRIGGER IF EXISTS after_game_rating_delete;
DELIMITER //
CREATE TRIGGER after_game_rating_delete
AFTER DELETE ON game_ratings
FOR EACH ROW
BEGIN
    -- Decrement users_rated and update average_rating
    UPDATE games
    SET 
        users_rated = GREATEST(users_rated - 1, 0)
        -- average_rating = (
        --     SELECT COALESCE(AVG(rating), 0)
        --     FROM game_ratings 
        --     WHERE game_id = OLD.game_id
        -- )
    WHERE id = OLD.game_id;
END//
DELIMITER ;









############################################################################
########################### PROCEDURES #####################################
############################################################################

-- Stored procedure to add or update a game rating
DROP PROCEDURE IF EXISTS add_game_rating;
DELIMITER //
CREATE PROCEDURE add_game_rating(
    IN p_user_id INT,
    IN p_game_id INT,
    IN p_rating DECIMAL(3,1),
    IN p_comment TEXT
)
BEGIN
    -- Check if the user has already rated this game
    DECLARE rating_exists INT;
    
    SELECT COUNT(*) INTO rating_exists
    FROM game_ratings
    WHERE user_id = p_user_id AND game_id = p_game_id;
    
    IF rating_exists > 0 THEN
        -- Update existing rating
        UPDATE game_ratings
        SET rating = p_rating,
            rating_comment = p_comment,
            rating_date = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id AND game_id = p_game_id;
    ELSE
        -- Insert new rating
        INSERT INTO game_ratings (user_id, game_id, rating, rating_comment)
        VALUES (p_user_id, p_game_id, p_rating, p_comment);
    END IF;
END//

DELIMITER ;

-- CALL add_game_rating(1, 1, 8.5, 'Great game!'); -- call the procedure to add a rating




-- Create a procedure to get a specific game by id with all its related information
DROP PROCEDURE IF EXISTS get_game_by_id;
DELIMITER //

CREATE PROCEDURE get_game_by_id(IN game_id INT)
BEGIN
    -- Get the basic game information
    SELECT g.* FROM games g WHERE g.id = game_id;
    
    -- Get designers
    SELECT d.designer_id, d.designer_name 
    FROM designers d 
    JOIN game_designers gd ON d.designer_id = gd.designer_id 
    WHERE gd.game_id = game_id;
    
    -- Get artists
    SELECT a.artist_id, a.artist_name 
    FROM artists a 
    JOIN game_artists ga ON a.artist_id = ga.artist_id 
    WHERE ga.game_id = game_id;
    
    -- Get publishers
    SELECT p.publisher_id, p.publisher_name 
    FROM publishers p 
    JOIN game_publishers gp ON p.publisher_id = gp.publisher_id 
    WHERE gp.game_id = game_id;
    
    -- Get categories
    SELECT c.category_id, c.category_name 
    FROM categories c 
    JOIN game_categories gc ON c.category_id = gc.category_id 
    WHERE gc.game_id = game_id;
    
    -- Get mechanics
    SELECT m.mechanic_id, m.mechanic_name 
    FROM mechanics m 
    JOIN game_mechanics gm ON m.mechanic_id = gm.mechanic_id 
    WHERE gm.game_id = game_id;
    
    -- Get families
    SELECT f.family_id, f.family_name 
    FROM families f 
    JOIN game_families gf ON f.family_id = gf.family_id 
    WHERE gf.game_id = game_id;
    
    -- Get expansions
    SELECT e.expansion_id, e.expansion_name 
    FROM expansions e 
    JOIN game_expansions ge ON e.expansion_id = ge.expansion_id 
    WHERE ge.game_id = game_id;
    
    -- Get implementations
    SELECT i.implementation_id, i.implementation_name 
    FROM implementations i 
    JOIN game_implementations gi ON i.implementation_id = gi.implementation_id 
    WHERE gi.game_id = game_id;
END //

DELIMITER ;
-- CALL get_game_by_id(123); -- Replace 123 with an actual game ID







############################################################################
########################### FUNCTIONS ######################################
############################################################################

-- Create a stored function to get a page of games
DROP FUNCTION IF EXISTS get_page_start;
DELIMITER //

CREATE FUNCTION get_page_start(page INT, page_size INT) 
RETURNS INT DETERMINISTIC
BEGIN
    RETURN (page - 1) * page_size;
END //

DELIMITER ;
-- SELECT * FROM games LIMIT get_page_start(2, 10), 10;  -- Gets page 2 with 10 items per page

-- Stored procedure to return the full result set
DROP PROCEDURE IF EXISTS get_games_page;
DELIMITER //

CREATE PROCEDURE get_games_page(IN page_num INT, IN items_per_page INT)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (page_num - 1) * items_per_page;
    
    SELECT * FROM games 
    ORDER BY id
    LIMIT offset_val, items_per_page;
END //

DELIMITER ;
-- CALL get_games_page(2, 10);  -- Gets page 2 with 10 items per page




-- Create a function to get the total number of games
DROP FUNCTION IF EXISTS get_total_games;
DELIMITER //

CREATE FUNCTION get_total_games() 
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM games;
    RETURN total;
END //

DELIMITER ;
-- SELECT get_total_games(); -- Returns the total number of games



