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
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS game_ratings;

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
    thumbnail VARCHAR(255)
    -- owned INT,
    -- trading INT,
    -- wanting INT,
    -- wishing INT -- ,
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




CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    user_password VARCHAR(100),
    user_created DATETIME,
    user_role ENUM('ADMIN', 'USER') NOT NULL
);
ALTER TABLE users MODIFY user_password VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY user_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Create a rating history table for logging
CREATE TABLE game_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    rating DECIMAL(3,1) NOT NULL,
    rating_comment TEXT,
    rating_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    -- cascade delete means if a user is deleted, their ratings are also deleted
    CONSTRAINT valid_rating CHECK (rating BETWEEN 1.0 AND 10.0),
    UNIQUE KEY unique_user_game_rating (user_id, game_id)
);


-- Create audit table for tracking changes to games (linked to the after_game_update trigger)
CREATE TABLE game_changes_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
    -- FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
);



INSERT INTO users (user_name, user_email, user_password, user_created, user_role) VALUES
    ('John Doe', 'john.doe@example.com', SHA2(CONCAT(now(), 'password123'), 224), now(), 'USER'),
    ('Jane Smith', 'jane.smith@example.com', SHA2(CONCAT(now(), 'secretpass'), 224), now(), 'USER'),
    ('Emily Clark', 'emily.clark@example.com', SHA2(CONCAT(now(), 'mypassword'), 224), now(), 'USER'),
    ('Sarah Lee', 'sarah.lee@example.com', SHA2(CONCAT(now(), 'letmein'), 224), now(), 'USER'),
    ('Michael Brown', 'michael.brown@example.com', SHA2(CONCAT(now(), 'adminpass'), 224), now(), 'ADMIN'),
    ('Robert Wilson', 'robert.wilson@example.com', SHA2(CONCAT(now(), 'pass123'), 224), now(), 'USER'),
    ('Lisa Anderson', 'lisa.anderson@example.com', SHA2(CONCAT(now(), 'secure456'), 224), now(), 'USER'),
    ('David Chen', 'david.chen@example.com', SHA2(CONCAT(now(), 'chen789'), 224), now(), 'USER'),
    ('Maria Garcia', 'maria.garcia@example.com', SHA2(CONCAT(now(), 'maria123'), 224), now(), 'USER'),
    ('James Johnson', 'james.johnson@example.com', SHA2(CONCAT(now(), 'jj2024'), 224), now(), 'USER'),
    ('Emma Davis', 'emma.davis@example.com', SHA2(CONCAT(now(), 'emma456'), 224), now(), 'USER'),
    ('Thomas White', 'thomas.white@example.com', SHA2(CONCAT(now(), 'white789'), 224), now(), 'USER'),
    ('Sophie Martin', 'sophie.martin@example.com', SHA2(CONCAT(now(), 'sophie123'), 224), now(), 'USER'),
    ('Kevin Taylor', 'kevin.taylor@example.com', SHA2(CONCAT(now(), 'taylor456'), 224), now(), 'USER'),
    ('Anna Miller', 'anna.miller@example.com', SHA2(CONCAT(now(), 'miller789'), 224), now(), 'USER')
;