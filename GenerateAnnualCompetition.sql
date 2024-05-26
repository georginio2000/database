DROP PROCEDURE IF EXISTS GenerateAnnualCompetition;

CREATE PROCEDURE GenerateAnnualCompetition()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE rand_cuisine INT;
    DECLARE rand_cook INT;
    DECLARE rand_recipe INT;
    DECLARE rand_judge1 INT;
    DECLARE rand_judge2 INT;
    DECLARE rand_judge3 INT;
    DECLARE rejected BOOLEAN;

    DECLARE curr_season INT DEFAULT 0;

    -- Get the current season and increment it
    SELECT current_season INTO curr_season FROM current_season ORDER BY season_id DESC LIMIT 1;
    SET curr_season = curr_season + 1;
    INSERT INTO current_season (current_season) VALUES (curr_season);

    CREATE TEMPORARY TABLE IF NOT EXISTS selected_cuisines (cuisine_id INT);

    -- Loop through 10 episodes
    WHILE i <= 10 DO
        -- Select 3 unique judges for the episode
        REPEAT
            SET rand_judge1 = (SELECT cook_id FROM cooks ORDER BY RAND() LIMIT 1);
            SET rand_judge2 = (SELECT cook_id FROM cooks WHERE cook_id NOT IN (rand_judge1) ORDER BY RAND() LIMIT 1);
            SET rand_judge3 = (SELECT cook_id FROM cooks WHERE cook_id NOT IN (rand_judge1, rand_judge2) ORDER BY RAND() LIMIT 1);
        UNTIL NOT EXISTS (
            SELECT 1 FROM episodes e
            WHERE e.episode = i - 1
            AND (e.judge1_id IN (rand_judge1, rand_judge2, rand_judge3)
                OR e.judge2_id IN (rand_judge1, rand_judge2, rand_judge3)
                OR e.judge3_id IN (rand_judge1, rand_judge2, rand_judge3))
        )
        END REPEAT;

        -- Insert episode details
        INSERT INTO episodes (episode_season, episode, judge1_id, judge2_id, judge3_id) VALUES (curr_season, i, rand_judge1, rand_judge2, rand_judge3);
        SET @episode_id = LAST_INSERT_ID();
        TRUNCATE TABLE selected_cuisines;

        SET j = 1;
        WHILE j <= 10 DO
            REPEAT
                SET rejected = FALSE;

                -- Select random recipe
                SET rand_recipe = (SELECT recipe_id FROM recipes ORDER BY RAND() LIMIT 1);
                SET rand_cuisine = (SELECT national_cuisine_national_cuisine_id FROM recipes WHERE recipe_id = rand_recipe);
                
                -- Ensure cuisine is not in current episode
                IF EXISTS (SELECT 1 FROM selected_cuisines WHERE cuisine_id = rand_cuisine) THEN
                    SET rejected = TRUE;
                END IF;

            UNTIL rejected = FALSE
            END REPEAT;

            -- Insert the selected cuisine into the temporary table
            INSERT INTO selected_cuisines (cuisine_id) VALUES (rand_cuisine);

            -- Select 1 random recipe from the selected national cuisine and associated cook
            REPEAT
                SET rejected = FALSE;

                -- Select random recipe
                SET rand_recipe = (SELECT recipe_id FROM recipes WHERE national_cuisine_national_cuisine_id = rand_cuisine ORDER BY RAND() LIMIT 1);

                -- Select random cook associated with the selected recipe
                SET rand_cook = (SELECT cook_id FROM cooks WHERE cook_id IN (SELECT cooks_cook_id FROM recipes_has_cooks WHERE recipes_recipe_id = rand_recipe) ORDER BY RAND() LIMIT 1);

            UNTIL rejected = FALSE
            END REPEAT;

            -- Insert cook, recipe, and episode relationship
            INSERT INTO cook_has_recipe_in_episodes (episodes_episode_id, recipes_has_cooks_recipes_recipe_id, recipes_has_cooks_cooks_cook_id)
            VALUES (@episode_id, rand_recipe, rand_cook);

            SET j = j + 1;
        END WHILE;

        SET i = i + 1;
    END WHILE;
END;
