import csv
import re
from collections import defaultdict

import mysql.connector

#path_before_file = ''
path_before_file = 'C:/Users/.../Board-Game/backend/'   # if the relative path doesn't work, use the absolute path

# Database connection configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  # Replace with your MySQL username
    'password': 'INSERT_PASS_HERE',  # Replace with your MySQL password
    'database': 'boardgames'
}

def clean_text(text):
    """Clean and normalize text data"""
    if not text:
        return None
    
    # Remove specific CSV formatting artifacts
    if text.startswith('//'):
        return None
        
    # Replace HTML entities
    text = text.replace('&quot;', '"').replace('&#10;', ' ').replace('&mdash;', '-')
    
    # Remove excessive whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text

def parse_list(list_str):
    """Parse list strings from CSV into Python lists"""
    if not list_str or list_str == '[]':
        return []
    
    # Handle the format ['item1', 'item2', ...]
    try:
        # Use regex to extract items between quotes
        items = re.findall(r"'([^']*)'", list_str)
        return items
    except:
        return []

def connect_to_database():
    """Connect to MySQL database"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        print("Connected to database successfully")
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting to database: {err}")
        exit(1)

def load_csv_data(filename):
    """Load data from CSV file"""
    data = []
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                # Skip comment lines
                if next(iter(row.values())).startswith('//'):
                    continue
                data.append(row)
    except Exception as e:
        print(f"Error loading {filename}: {e}")
    
    return data

def insert_games(cursor, games_data):
    """Insert games into the database"""
    print("Inserting games data...")
    
    # Prepare SQL statements
    insert_game_sql = """
    INSERT INTO games (id, primary_name, description, yearpublished, minplayers, maxplayers, 
                      playingtime, minplaytime, maxplaytime, minage, bgg_rank, average_rating, 
                      bayes_average, users_rated, url, thumbnail, owned, trading, wanting, wishing)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    # Process and insert each game
    for game in games_data:
        try:
            # Clean and convert data
            game_id = int(game['id'])
            primary_name = clean_text(game['primary'])
            description = clean_text(game.get('description', ''))
            
            # Convert numeric fields
            year = int(game['yearpublished']) if game.get('yearpublished') and game['yearpublished'].isdigit() else None
            minplayers = int(game['minplayers']) if game.get('minplayers') and game['minplayers'].isdigit() else None
            maxplayers = int(game['maxplayers']) if game.get('maxplayers') and game['maxplayers'].isdigit() else None
            playingtime = int(game['playingtime']) if game.get('playingtime') and game['playingtime'].isdigit() else None
            minplaytime = int(game['minplaytime']) if game.get('minplaytime') and game['minplaytime'].isdigit() else None
            maxplaytime = int(game['maxplaytime']) if game.get('maxplaytime') and game['maxplaytime'].isdigit() else None
            minage = int(game['minage']) if game.get('minage') and game['minage'].isdigit() else None
            
            # Rankings and ratings
            bgg_rank = int(game.get('rank', 0)) if game.get('rank') and game['rank'].isdigit() else None
            avg_rating = float(game.get('average', 0)) if game.get('average') else None
            bayes_avg = float(game.get('bayes_average', 0)) if game.get('bayes_average') else None
            users_rated = int(game.get('users_rated', 0)) if game.get('users_rated') and game['users_rated'].isdigit() else None
            
            # URLs and media
            url = clean_text(game.get('url', ''))
            thumbnail = clean_text(game.get('thumbnail', ''))
            
            # Collection stats
            owned = int(game.get('owned', 0)) if game.get('owned') and game['owned'].isdigit() else None
            trading = int(game.get('trading', 0)) if game.get('trading') and game['trading'].isdigit() else None
            wanting = int(game.get('wanting', 0)) if game.get('wanting') and game['wanting'].isdigit() else None
            wishing = int(game.get('wishing', 0)) if game.get('wishing') and game['wishing'].isdigit() else None
            
            # Execute insert statement
            cursor.execute(insert_game_sql, (
                game_id, primary_name, description, year, minplayers, maxplayers, 
                playingtime, minplaytime, maxplaytime, minage, bgg_rank, avg_rating, 
                bayes_avg, users_rated, url, thumbnail, owned, trading, wanting, wishing
            ))
            
        except Exception as e:
            print(f"Error inserting game {game.get('id')}: {e}")
    
    print(f"Inserted {cursor.rowcount} games")

def insert_categories(cursor, games_data):
    """Insert categories and game-category relationships"""
    print("Processing categories...")
    
    categories = set()
    game_categories = []
    
    # Extract all categories
    for game in games_data:
        if 'boardgamecategory' in game and game['boardgamecategory']:
            game_id = int(game['id'])
            for category in parse_list(game['boardgamecategory']):
                categories.add(category)
                game_categories.append((game_id, category))
    
    # Insert categories
    for category in categories:
        try:
            cursor.execute("INSERT INTO categories (category_name) VALUES (%s)", (category,))
        except mysql.connector.Error as err:
            if err.errno == 1062:  # Duplicate entry error
                pass  # Ignore duplicates
            else:
                print(f"Error inserting category {category}: {err}")
    
    # Get category IDs
    cursor.execute("SELECT category_id, category_name FROM categories")
    category_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-category relationships
    for game_id, category_name in game_categories:
        if category_name in category_map:
            try:
                cursor.execute(
                    "INSERT INTO game_categories (game_id, category_id) VALUES (%s, %s)",
                    (game_id, category_map[category_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to category {category_name}: {err}")
    
    print(f"Processed {len(categories)} categories with {len(game_categories)} game-category relationships")

def insert_mechanics(cursor, games_data):
    """Insert mechanics and game-mechanic relationships"""
    print("Processing mechanics...")
    
    mechanics = set()
    game_mechanics = []
    
    # Extract all mechanics
    for game in games_data:
        if 'boardgamemechanic' in game and game['boardgamemechanic']:
            game_id = int(game['id'])
            for mechanic in parse_list(game['boardgamemechanic']):
                mechanics.add(mechanic)
                game_mechanics.append((game_id, mechanic))
    
    # Insert mechanics
    for mechanic in mechanics:
        try:
            cursor.execute("INSERT INTO mechanics (mechanic_name) VALUES (%s)", (mechanic,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting mechanic {mechanic}: {err}")
    
    # Get mechanic IDs
    cursor.execute("SELECT mechanic_id, mechanic_name FROM mechanics")
    mechanic_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-mechanic relationships
    for game_id, mechanic_name in game_mechanics:
        if mechanic_name in mechanic_map:
            try:
                cursor.execute(
                    "INSERT INTO game_mechanics (game_id, mechanic_id) VALUES (%s, %s)",
                    (game_id, mechanic_map[mechanic_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to mechanic {mechanic_name}: {err}")
    
    print(f"Processed {len(mechanics)} mechanics with {len(game_mechanics)} game-mechanic relationships")

def insert_designers(cursor, games_data):
    """Insert designers and game-designer relationships"""
    print("Processing designers...")
    
    designers = set()
    game_designers = []
    
    # Extract all designers
    for game in games_data:
        if 'boardgamedesigner' in game and game['boardgamedesigner']:
            game_id = int(game['id'])
            for designer in parse_list(game['boardgamedesigner']):
                designers.add(designer)
                game_designers.append((game_id, designer))
    
    # Insert designers
    for designer in designers:
        try:
            cursor.execute("INSERT INTO designers (designer_name) VALUES (%s)", (designer,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting designer {designer}: {err}")
    
    # Get designer IDs
    cursor.execute("SELECT designer_id, designer_name FROM designers")
    designer_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-designer relationships
    for game_id, designer_name in game_designers:
        if designer_name in designer_map:
            try:
                cursor.execute(
                    "INSERT INTO game_designers (game_id, designer_id) VALUES (%s, %s)",
                    (game_id, designer_map[designer_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to designer {designer_name}: {err}")
    
    print(f"Processed {len(designers)} designers with {len(game_designers)} game-designer relationships")

def insert_artists(cursor, games_data):
    """Insert artists and game-artist relationships"""
    print("Processing artists...")
    
    artists = set()
    game_artists = []
    
    # Extract all artists
    for game in games_data:
        if 'boardgameartist' in game and game['boardgameartist']:
            game_id = int(game['id'])
            for artist in parse_list(game['boardgameartist']):
                artists.add(artist)
                game_artists.append((game_id, artist))
    
    # Insert artists
    for artist in artists:
        try:
            cursor.execute("INSERT INTO artists (artist_name) VALUES (%s)", (artist,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting artist {artist}: {err}")
    
    # Get artist IDs
    cursor.execute("SELECT artist_id, artist_name FROM artists")
    artist_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-artist relationships
    for game_id, artist_name in game_artists:
        if artist_name in artist_map:
            try:
                cursor.execute(
                    "INSERT INTO game_artists (game_id, artist_id) VALUES (%s, %s)",
                    (game_id, artist_map[artist_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to artist {artist_name}: {err}")
    
    print(f"Processed {len(artists)} artists with {len(game_artists)} game-artist relationships")

def insert_publishers(cursor, games_data):
    """Insert publishers and game-publisher relationships"""
    print("Processing publishers...")
    
    publishers = set()
    game_publishers = []
    
    # Extract all publishers
    for game in games_data:
        if 'boardgamepublisher' in game and game['boardgamepublisher']:
            game_id = int(game['id'])
            for publisher in parse_list(game['boardgamepublisher']):
                publishers.add(publisher)
                game_publishers.append((game_id, publisher))
    
    # Insert publishers
    for publisher in publishers:
        try:
            cursor.execute("INSERT INTO publishers (publisher_name) VALUES (%s)", (publisher,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting publisher {publisher}: {err}")
    
    # Get publisher IDs
    cursor.execute("SELECT publisher_id, publisher_name FROM publishers")
    publisher_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-publisher relationships
    for game_id, publisher_name in game_publishers:
        if publisher_name in publisher_map:
            try:
                cursor.execute(
                    "INSERT INTO game_publishers (game_id, publisher_id) VALUES (%s, %s)",
                    (game_id, publisher_map[publisher_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to publisher {publisher_name}: {err}")
    
    print(f"Processed {len(publishers)} publishers with {len(game_publishers)} game-publisher relationships")

def insert_families(cursor, games_data):
    """Insert families and game-family relationships"""
    print("Processing families...")
    
    families = set()
    game_families = []
    
    # Extract all families
    for game in games_data:
        if 'boardgamefamily' in game and game['boardgamefamily']:
            game_id = int(game['id'])
            for family in parse_list(game['boardgamefamily']):
                families.add(family)
                game_families.append((game_id, family))
    
    # Insert families
    for family in families:
        try:
            cursor.execute("INSERT INTO families (family_name) VALUES (%s)", (family,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting family {family}: {err}")
    
    # Get family IDs
    cursor.execute("SELECT family_id, family_name FROM families")
    family_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-family relationships
    for game_id, family_name in game_families:
        if family_name in family_map:
            try:
                cursor.execute(
                    "INSERT INTO game_families (game_id, family_id) VALUES (%s, %s)",
                    (game_id, family_map[family_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to family {family_name}: {err}")
    
    print(f"Processed {len(families)} families with {len(game_families)} game-family relationships")

def insert_expansions(cursor, games_data):
    """Insert expansions and game-expansion relationships"""
    print("Processing expansions...")
    
    expansions = set()
    game_expansions = []
    
    # Extract all expansions
    for game in games_data:
        if 'boardgameexpansion' in game and game['boardgameexpansion']:
            game_id = int(game['id'])
            for expansion in parse_list(game['boardgameexpansion']):
                expansions.add(expansion)
                game_expansions.append((game_id, expansion))
    
    # Insert expansions
    for expansion in expansions:
        try:
            cursor.execute("INSERT INTO expansions (expansion_name) VALUES (%s)", (expansion,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting expansion {expansion}: {err}")
    
    # Get expansion IDs
    cursor.execute("SELECT expansion_id, expansion_name FROM expansions")
    expansion_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-expansion relationships
    for game_id, expansion_name in game_expansions:
        if expansion_name in expansion_map:
            try:
                cursor.execute(
                    "INSERT INTO game_expansions (game_id, expansion_id) VALUES (%s, %s)",
                    (game_id, expansion_map[expansion_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to expansion {expansion_name}: {err}")
    
    print(f"Processed {len(expansions)} expansions with {len(game_expansions)} game-expansion relationships")

def insert_implementations(cursor, games_data):
    """Insert implementations and game-implementation relationships"""
    print("Processing implementations...")
    
    implementations = set()
    game_implementations = []
    
    # Extract all implementations
    for game in games_data:
        if 'boardgameimplementation' in game and game['boardgameimplementation']:
            game_id = int(game['id'])
            for implementation in parse_list(game['boardgameimplementation']):
                implementations.add(implementation)
                game_implementations.append((game_id, implementation))
    
    # Insert implementations
    for implementation in implementations:
        try:
            cursor.execute("INSERT INTO implementations (implementation_name) VALUES (%s)", (implementation,))
        except mysql.connector.Error as err:
            if err.errno != 1062:  # Ignore duplicate entries
                print(f"Error inserting implementation {implementation}: {err}")
    
    # Get implementation IDs
    cursor.execute("SELECT implementation_id, implementation_name FROM implementations")
    implementation_map = {name: id for id, name in cursor.fetchall()}
    
    # Insert game-implementation relationships
    for game_id, implementation_name in game_implementations:
        if implementation_name in implementation_map:
            try:
                cursor.execute(
                    "INSERT INTO game_implementations (game_id, implementation_id) VALUES (%s, %s)",
                    (game_id, implementation_map[implementation_name])
                )
            except mysql.connector.Error as err:
                if err.errno != 1062:  # Ignore duplicate entries
                    print(f"Error linking game {game_id} to implementation {implementation_name}: {err}")
    
    print(f"Processed {len(implementations)} implementations with {len(game_implementations)} game-implementation relationships")

def main():
    """Main function to orchestrate data import"""
    print("Starting database import process...")
    
    # Load CSV data
    details_data = load_csv_data(path_before_file+'details.csv')
    ratings_data = load_csv_data(path_before_file+'ratings.csv')
    
    # Merge the data
    games_data = {}
    
    # First, process ratings data
    for row in ratings_data:
        game_id = row.get('id')
        if game_id:
            games_data[game_id] = row
    
    # Then, enhance with details data
    for row in details_data:
        game_id = row.get('id')
        if game_id:
            if game_id in games_data:
                games_data[game_id].update(row)
            else:
                games_data[game_id] = row
    
    # Convert dict to list
    games_list = list(games_data.values())
    
    # Connect to the database
    conn = connect_to_database()
    cursor = conn.cursor()
    
    try:
        # Insert data
        insert_games(cursor, games_list)
        insert_categories(cursor, games_list)
        insert_mechanics(cursor, games_list)
        insert_designers(cursor, games_list)
        insert_artists(cursor, games_list)
        insert_publishers(cursor, games_list)
        insert_families(cursor, games_list)
        insert_expansions(cursor, games_list)
        insert_implementations(cursor, games_list)
        
        # Commit changes
        conn.commit()
        print("Database import completed successfully!")
        
    except Exception as e:
        conn.rollback()
        print(f"Error during import process: {e}")
    
    finally:
        cursor.close()
        conn.close()
        print("Database connection closed")

if __name__ == "__main__":
    main()