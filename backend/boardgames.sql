DROP DATABASE IF EXISTS boardgames;
CREATE DATABASE boardgames;
USE boardgames;

-- Drop all tables if they exist
DROP TABLE IF EXISTS game_implementations;
DROP TABLE IF EXISTS implementations;
DROP TABLE IF EXISTS game_expansions;
DROP TABLE IF EXISTS expansions;
DROP TABLE IF EXISTS game_families;
DROP TABLE IF EXISTS families;
DROP TABLE IF EXISTS game_mechanics;
DROP TABLE IF EXISTS mechanics;
DROP TABLE IF EXISTS game_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS game_publishers;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS game_artists;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS game_designers;
DROP TABLE IF EXISTS designers;
DROP TABLE IF EXISTS games;

-- Create tables with appropriate data types and constraints

-- Create a table for publishers
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create a table for designers
CREATE TABLE designers (
    designer_id INT AUTO_INCREMENT PRIMARY KEY,
    designer_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create a table for artists
CREATE TABLE artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create a table for categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create a table for mechanics
CREATE TABLE mechanics (
    mechanic_id INT AUTO_INCREMENT PRIMARY KEY,
    mechanic_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create a table for families
CREATE TABLE families (
    family_id INT AUTO_INCREMENT PRIMARY KEY,
    family_name VARCHAR(200) NOT NULL UNIQUE
);

-- Create a table for games
CREATE TABLE games (
    id INT PRIMARY KEY,
    primary_name VARCHAR(255) NOT NULL,
    description TEXT,
    yearpublished INT,
    minplayers INT,
    maxplayers INT,
    playingtime INT,
    minplaytime INT,
    maxplaytime INT,
    minage INT,
    bgg_rank INT,
    average_rating DECIMAL(4,2),
    bayes_average DECIMAL(4,3),
    users_rated INT,
    url VARCHAR(255),
    thumbnail VARCHAR(255),
    owned INT,
    trading INT,
    wanting INT,
    wishing INT -- ,
    -- CONSTRAINT valid_players CHECK (minplayers <= maxplayers),
    -- CONSTRAINT valid_playtime CHECK (minplaytime <= maxplaytime),
    -- CONSTRAINT valid_ratings CHECK (average_rating BETWEEN 1.00 AND 10.00)
);

-- Create junction tables for many-to-many relationships

-- Game-Designer relationship
CREATE TABLE game_designers (
    game_id INT,
    designer_id INT,
    PRIMARY KEY (game_id, designer_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (designer_id) REFERENCES designers(designer_id)
);

-- Game-Artist relationship
CREATE TABLE game_artists (
    game_id INT,
    artist_id INT,
    PRIMARY KEY (game_id, artist_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- Game-Publisher relationship
CREATE TABLE game_publishers (
    game_id INT,
    publisher_id INT,
    PRIMARY KEY (game_id, publisher_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- Game-Category relationship
CREATE TABLE game_categories (
    game_id INT,
    category_id INT,
    PRIMARY KEY (game_id, category_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Game-Mechanic relationship
CREATE TABLE game_mechanics (
    game_id INT,
    mechanic_id INT,
    PRIMARY KEY (game_id, mechanic_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (mechanic_id) REFERENCES mechanics(mechanic_id)
);

-- Game-Family relationship
CREATE TABLE game_families (
    game_id INT,
    family_id INT,
    PRIMARY KEY (game_id, family_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (family_id) REFERENCES families(family_id)
);

-- Create table for expansions
CREATE TABLE expansions (
    expansion_id INT AUTO_INCREMENT PRIMARY KEY,
    expansion_name VARCHAR(255) NOT NULL UNIQUE
);

-- Game-Expansion relationship
CREATE TABLE game_expansions (
    game_id INT,
    expansion_id INT,
    PRIMARY KEY (game_id, expansion_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (expansion_id) REFERENCES expansions(expansion_id)
);

-- Create table for implementations
CREATE TABLE implementations (
    implementation_id INT AUTO_INCREMENT PRIMARY KEY,
    implementation_name VARCHAR(255) NOT NULL UNIQUE
);

-- Game-Implementation relationship
CREATE TABLE game_implementations (
    game_id INT,
    implementation_id INT,
    PRIMARY KEY (game_id, implementation_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (implementation_id) REFERENCES implementations(implementation_id)
);

-- Create indexes for performance
CREATE INDEX idx_game_year ON games(yearpublished);
CREATE INDEX idx_game_rating ON games(average_rating DESC);
CREATE INDEX idx_game_rank ON games(bgg_rank);
CREATE INDEX idx_game_players ON games(minplayers, maxplayers);
CREATE INDEX idx_game_playtime ON games(playingtime);
CREATE INDEX idx_game_users_rated ON games(users_rated DESC);









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