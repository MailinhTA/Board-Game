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
-- SELECT * FROM v_top_rated_games WHERE yearpublished > 2000; -- Example usage:

-- View showing game details with designer counts
CREATE OR REPLACE VIEW v_game_designer_counts AS
SELECT g.id, g.primary_name, g.yearpublished, g.average_rating,
    COUNT(gd.designer_id) AS designer_count
FROM games g
LEFT JOIN game_designers gd ON g.id = gd.game_id
GROUP BY g.id;
-- SELECT * FROM v_game_designer_counts WHERE designer_count > 1; -- Example usage:

-- View showing games with their categories as comma-separated list
CREATE OR REPLACE VIEW v_games_with_categories AS
SELECT g.id, g.primary_name, g.average_rating,
    GROUP_CONCAT(c.category_name ORDER BY c.category_name SEPARATOR ', ') AS categories
FROM games g
LEFT JOIN game_categories gc ON g.id = gc.game_id
LEFT JOIN categories c ON gc.category_id = c.category_id
GROUP BY g.id;
-- SELECT * FROM v_games_with_categories WHERE categories LIKE '%Strategy%'; -- Example usage:

-- View showing games with their mechanics as comma-separated list
CREATE OR REPLACE VIEW v_games_with_mechanics AS
SELECT g.id, g.primary_name, g.average_rating,
    GROUP_CONCAT(m.mechanic_name ORDER BY m.mechanic_name SEPARATOR ', ') AS mechanics
FROM games g
LEFT JOIN game_mechanics gm ON g.id = gm.game_id
LEFT JOIN mechanics m ON gm.mechanic_id = m.mechanic_id
GROUP BY g.id;
-- SELECT * FROM v_games_with_mechanics WHERE mechanics LIKE '%Worker Placement%'; -- Example usage:

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
-- CALL add_game_rating(1, 1, 8.5, 'Great game!'); -- Example usage to trigger the insert

-- Trigger to update games table when a rating is updated
-- DROP TRIGGER IF EXISTS after_game_rating_update;
-- DELIMITER //
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




-- Trigger to audit changes to important game information
DROP TRIGGER IF EXISTS after_game_update;
DELIMITER //
CREATE TRIGGER after_game_update
AFTER UPDATE ON games
FOR EACH ROW
BEGIN
    -- Track changes to primary name
    IF NEW.primary_name <> OLD.primary_name THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'primary_name', OLD.primary_name, NEW.primary_name, CURRENT_USER());
    END IF;
    
    -- Track changes to description
    IF NOT (NEW.description <=> OLD.description) THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'description', OLD.description, NEW.description, CURRENT_USER());
    END IF;
    
    -- Track changes to year published
    IF NEW.yearpublished <> OLD.yearpublished THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'yearpublished', OLD.yearpublished, NEW.yearpublished, CURRENT_USER());
    END IF;
    
    -- Track changes to player count
    IF NEW.minplayers <> OLD.minplayers THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'minplayers', OLD.minplayers, NEW.minplayers, CURRENT_USER());
    END IF;
    
    IF NEW.maxplayers <> OLD.maxplayers THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'maxplayers', OLD.maxplayers, NEW.maxplayers, CURRENT_USER());
    END IF;
    
    -- Track changes to playtime
    IF NEW.playingtime <> OLD.playingtime THEN
        INSERT INTO game_changes_audit (game_id, field_changed, old_value, new_value, changed_by)
        VALUES (NEW.id, 'playingtime', OLD.playingtime, NEW.playingtime, CURRENT_USER());
    END IF;
END//
DELIMITER ;








############################################################################
########################### PROCEDURES #####################################
############################################################################

-- Stored procedure to get a page of games
DROP PROCEDURE IF EXISTS get_games_page;
DELIMITER //

CREATE PROCEDURE get_games_page(
    IN page_num INT, 
    IN items_per_page INT,
    IN sort_by VARCHAR(20) -- Options: 'id', 'yearpublished', 'average_rating', 'users_rated'
)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (page_num - 1) * items_per_page;
    
    -- Set default sorting if NULL or invalid value provided
    IF sort_by IS NULL OR sort_by NOT IN ('id', 'yearpublished', 'average_rating', 'bayes_average', 'bgg_rank', 'users_rated') THEN
        SET sort_by = 'id';
    END IF;
    
    -- Dynamic sorting based on parameter
    CASE sort_by
        WHEN 'yearpublished' THEN
            SELECT * FROM games 
            ORDER BY yearpublished DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'average_rating' THEN
            SELECT * FROM games 
            ORDER BY average_rating DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'users_rated' THEN
            SELECT * FROM games 
            ORDER BY users_rated DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'bayes_average' THEN
            SELECT * FROM games 
            ORDER BY bayes_average DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'bgg_rank' THEN
            SELECT * FROM games 
            ORDER BY bgg_rank ASC, id
            LIMIT offset_val, items_per_page;
        ELSE
            -- Default is sorting by id
            SELECT * FROM games 
            ORDER BY id
            LIMIT offset_val, items_per_page;
    END CASE;
END //

DELIMITER ;

-- CALL get_games_page(1, 10, 'average_rating'); -- Example usage to get the first page of games sorted by average rating



-- Create a procedure to get a specific game by id with all its related information
DROP PROCEDURE IF EXISTS get_game_by_id;
DELIMITER //

CREATE PROCEDURE get_game_by_id(IN game_id INT)
BEGIN
    -- Get the basic game information
    SELECT g.*, game_total_rating(game_id) AS total_rating FROM games g WHERE g.id = game_id;
    
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



-- Stored procedure to add or update a game rating (with transaction handling)
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

    -- Declare variables for error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred while updating game rating';
    END;
    
    START TRANSACTION;

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
    
    COMMIT;
END//
DELIMITER ;

-- CALL add_game_rating(1, 1, 8.5, 'Great game!'); -- call the procedure to add a rating


-- Add a procedure to delete a game rating with transaction handling
DROP PROCEDURE IF EXISTS delete_game_rating;
DELIMITER //
CREATE PROCEDURE delete_game_rating(
    IN p_user_id INT,
    IN p_game_id INT
)
BEGIN
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred while deleting the rating';
    END;
    
    START TRANSACTION;
    
    -- Delete the rating
    DELETE FROM game_ratings
    WHERE user_id = p_user_id AND game_id = p_game_id;
    
    -- The trigger after_game_rating_delete will handle updating the games table
    
    COMMIT;
END//
DELIMITER ;



-- Stored procedure to get all ratings made by a specific user
DROP PROCEDURE IF EXISTS get_user_ratings;
DELIMITER //

CREATE PROCEDURE get_user_ratings(
    IN p_user_id INT
)
BEGIN
    SELECT gr.*, g.primary_name FROM game_ratings gr
    JOIN games g ON gr.game_id = g.id
    WHERE gr.user_id = p_user_id
    ORDER BY gr.rating_date DESC;
END //

DELIMITER ;

-- CALL get_user_ratings(1); -- Replace with a valid user_id




-- Stored procedure to get the last 3 ratings for a specific game
DROP PROCEDURE IF EXISTS get_latest_game_ratings;
DELIMITER //

CREATE PROCEDURE get_latest_game_ratings(
    IN p_game_id INT
)
BEGIN
    SELECT gr.rating_id, gr.user_id, u.user_name, gr.rating, 
           gr.rating_comment, gr.rating_date
    FROM game_ratings gr
    JOIN users u ON gr.user_id = u.user_id
    WHERE gr.game_id = p_game_id
    ORDER BY gr.rating_date DESC
    LIMIT 3;
END //

DELIMITER ;

-- CALL get_latest_game_ratings(123); -- Replace with a valid game_id





-- Stored procedure to search games by name with pagination and sorting
DROP PROCEDURE IF EXISTS search_games_by_name;
DELIMITER //

CREATE PROCEDURE search_games_by_name(
    IN search_term VARCHAR(255),
    IN page_num INT, 
    IN items_per_page INT,
    IN sort_by VARCHAR(20) -- Options: 'id', 'yearpublished', 'average_rating', 'users_rated', etc.
)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (page_num - 1) * items_per_page;
    
    -- Set default sorting if NULL or invalid value provided
    IF sort_by IS NULL OR sort_by NOT IN ('id', 'yearpublished', 'average_rating', 'bayes_average', 'bgg_rank', 'users_rated') THEN
        SET sort_by = 'id';
    END IF;
    
    -- Dynamic sorting based on parameter with name search
    CASE sort_by
        WHEN 'yearpublished' THEN
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY yearpublished DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'average_rating' THEN
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY average_rating DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'users_rated' THEN
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY users_rated DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'bayes_average' THEN
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY bayes_average DESC, id
            LIMIT offset_val, items_per_page;
        WHEN 'bgg_rank' THEN
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY bgg_rank ASC, id
            LIMIT offset_val, items_per_page;
        ELSE
            -- Default is sorting by id
            SELECT * FROM games 
            WHERE primary_name LIKE CONCAT('%', search_term, '%')
            ORDER BY id
            LIMIT offset_val, items_per_page;
    END CASE;
END //

DELIMITER ;

-- CALL search_games_by_name('Catan', 1, 10, 'average_rating'); -- Example usage:




-- Stored procedure to get games filtered by category with pagination and sorting
DROP PROCEDURE IF EXISTS get_games_by_category;
DELIMITER //

CREATE PROCEDURE get_games_by_category(
    IN p_category_name VARCHAR(50),
    IN page_num INT, 
    IN items_per_page INT,
    IN sort_by VARCHAR(20) -- Options: 'id', 'yearpublished', 'average_rating', 'users_rated', 'bayes_average', 'bgg_rank'
)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (page_num - 1) * items_per_page;
    
    -- Set default sorting if NULL or invalid value provided
    IF sort_by IS NULL OR sort_by NOT IN ('id', 'yearpublished', 'average_rating', 'bayes_average', 'bgg_rank', 'users_rated') THEN
        SET sort_by = 'id';
    END IF;
    
    -- Dynamic sorting based on parameter with category filter
    CASE sort_by
        WHEN 'yearpublished' THEN
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.yearpublished DESC, g.id
            LIMIT offset_val, items_per_page;
        WHEN 'average_rating' THEN
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.average_rating DESC, g.id
            LIMIT offset_val, items_per_page;
        WHEN 'users_rated' THEN
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.users_rated DESC, g.id
            LIMIT offset_val, items_per_page;
        WHEN 'bayes_average' THEN
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.bayes_average DESC, g.id
            LIMIT offset_val, items_per_page;
        WHEN 'bgg_rank' THEN
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.bgg_rank ASC, g.id
            LIMIT offset_val, items_per_page;
        ELSE
            -- Default is sorting by id
            SELECT g.* FROM games g
            JOIN game_categories gc ON g.id = gc.game_id
            JOIN categories c ON gc.category_id = c.category_id
            WHERE c.category_name = p_category_name
            ORDER BY g.id
            LIMIT offset_val, items_per_page;
    END CASE;
    
    -- Return total count for pagination
    SELECT COUNT(DISTINCT g.id) AS total_games
    FROM games g
    JOIN game_categories gc ON g.id = gc.game_id
    JOIN categories c ON gc.category_id = c.category_id
    WHERE c.category_name = p_category_name;
END //

DELIMITER ;

-- CALL get_games_by_category('Fantasy', 1, 10, 'average_rating'); -- Example usage















############################################################################
########################### FUNCTIONS ######################################
############################################################################


-- (Duplicate) Create a function to get a page of games
DROP FUNCTION IF EXISTS get_page_start;
DELIMITER //

CREATE FUNCTION get_page_start(page INT, page_size INT) 
RETURNS INT DETERMINISTIC
BEGIN
    RETURN (page - 1) * page_size;
END //

DELIMITER ;
-- SELECT * FROM games LIMIT get_page_start(2, 10), 10;  -- Gets page 2 with 10 items per page


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


-- Function to calculate the average user rating for a specific game
DROP FUNCTION IF EXISTS game_total_rating;
DELIMITER //

CREATE FUNCTION game_total_rating(game_id_param INT) 
RETURNS DECIMAL(4,2) DETERMINISTIC
BEGIN
    DECLARE avg_user_rating DECIMAL(4,2);
    
    SELECT AVG(rating) INTO avg_user_rating
    FROM game_ratings
    WHERE game_id = game_id_param;
    
    RETURN COALESCE(avg_user_rating, 0.00);
END //

DELIMITER ;
-- SELECT game_total_rating(123); -- Replace 123 with an actual game ID




-- Function to calculate the average rating of games by a specific designer
DROP FUNCTION IF EXISTS designer_average_rating;
DELIMITER //

CREATE FUNCTION designer_average_rating(designer_id_param INT) 
RETURNS DECIMAL(4,2) DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(4,2);
    
    SELECT AVG(g.average_rating) INTO avg_rating
    FROM games g
    JOIN game_designers gd ON g.id = gd.game_id
    WHERE gd.designer_id = designer_id_param;
    
    RETURN COALESCE(avg_rating, 0.00);
END //

DELIMITER ;
-- SELECT designer_name, designer_average_rating(designer_id) FROM designers LIMIT 10;


-- Function to get the count of games in a specific category
DROP FUNCTION IF EXISTS category_game_count;
DELIMITER //

CREATE FUNCTION category_game_count(category_id_param INT) 
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE game_count INT;
    
    SELECT COUNT(*) INTO game_count
    FROM game_categories
    WHERE category_id = category_id_param;
    
    RETURN game_count;
END //

DELIMITER ;
-- SELECT category_name, category_game_count(category_id) FROM categories ORDER BY category_game_count(category_id) DESC LIMIT 10;


