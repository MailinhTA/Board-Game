-- Create a stored function to get a page of games
DELIMITER //

CREATE FUNCTION get_page_start(page INT, page_size INT) 
RETURNS INT DETERMINISTIC
BEGIN
    RETURN (page - 1) * page_size;
END //

DELIMITER ;
-- SELECT * FROM games LIMIT get_page_start(2, 10), 10;  -- Gets page 2 with 10 items per page

-- Stored procedure to return the full result set
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



-- Create a procedure to get a specific game by id with all its related information
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