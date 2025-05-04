############################################################################
########################### INDEXES ########################################
############################################################################

-- Index to retrieve games by year published
CREATE INDEX idx_game_year ON games(yearpublished);

-- Index to retrieve games by descending average rating (from highest to lowest)
CREATE INDEX idx_game_rating ON games(average_rating DESC);

-- Index to retrieve games by bgg rank 
CREATE INDEX idx_game_rank ON games(bgg_rank);

-- Index to retrieve games by minplayers and maxplayers
CREATE INDEX idx_game_players ON games(minplayers, maxplayers);

-- Index to retrieve games by playing time
CREATE INDEX idx_game_playtime ON games(playingtime);

-- Index to retrieve games by the number of users who rated
CREATE INDEX idx_game_users_rated ON games(users_rated DESC);