-- procedure to be used by triggers
DROP PROCEDURE IF EXISTS UpdateRecipeNutritionalValues;

CREATE PROCEDURE UpdateRecipeNutritionalValues(IN recipe_id INT UNSIGNED)
BEGIN
    -- Update the total nutritional values for the given recipe
    UPDATE recipes r
    JOIN (
        SELECT
            rhi.recipes_recipe_id,
            SUM(rhi.quantity * i.carbs) AS total_carbs,
            SUM(rhi.quantity * i.fat) AS total_fat,
            SUM(rhi.quantity * i.protein) AS total_protein,
            SUM(rhi.quantity * i.calories) AS total_calories
        FROM
            recipes_has_ingredients rhi
            JOIN ingredients i ON rhi.ingredients_ingredient_id = i.ingredient_id
        WHERE
            rhi.recipes_recipe_id = recipe_id
        GROUP BY
            rhi.recipes_recipe_id
    ) AS nutritional_sums ON r.recipe_id = nutritional_sums.recipes_recipe_id
    SET
        r.total_carbs = nutritional_sums.total_carbs,
        r.total_fat = nutritional_sums.total_fat,
        r.total_protein = nutritional_sums.total_protein,
        r.total_calories = nutritional_sums.total_calories;
END;

-- setting up triggers

DROP TRIGGER IF EXISTS after_insert_recipes_has_ingredients;

CREATE TRIGGER after_insert_recipes_has_ingredients
    AFTER INSERT ON recipes_has_ingredients
    FOR EACH ROW
    BEGIN
        CALL UpdateRecipeNutritionalValues(NEW.recipes_recipe_id);
    END;


DROP TRIGGER IF EXISTS after_update_recipes_has_ingredients;

CREATE TRIGGER after_update_recipes_has_ingredients
    AFTER UPDATE ON recipes_has_ingredients
    FOR EACH ROW
    BEGIN
        CALL UpdateRecipeNutritionalValues(NEW.recipes_recipe_id);
    END;

DROP TRIGGER IF EXISTS after_delete_recipes_has_ingredients;

CREATE TRIGGER after_delete_recipes_has_ingredients
    AFTER DELETE ON recipes_has_ingredients
    FOR EACH ROW
    BEGIN
        CALL OverallUpdateRecipeNutritionalValues(OLD.recipes_recipe_id);
    END;



-- procedure in case of need of overall computation
DROP PROCEDURE IF EXISTS OverallUpdateRecipeNutritionalValues;

CREATE PROCEDURE OverallUpdateRecipeNutritionalValues()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE recipe_id_var INT UNSIGNED;
    
    -- Declare a cursor to iterate over all recipes
    DECLARE recipe_cursor CURSOR FOR
        SELECT recipe_id FROM recipes;

    -- Declare a NOT FOUND handler for the cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open the cursor
    OPEN recipe_cursor;

    -- Loop through all recipes
    read_loop: LOOP
        FETCH recipe_cursor INTO recipe_id_var;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update the total nutritional values for each recipe
        UPDATE recipes r
        JOIN (
            SELECT
                rhi.recipes_recipe_id,
                SUM(rhi.quantity * i.carbs) AS total_carbs,
                SUM(rhi.quantity * i.fat) AS total_fat,
                SUM(rhi.quantity * i.protein) AS total_protein,
                SUM(rhi.quantity * i.calories) AS total_calories
            FROM
                recipes_has_ingredients rhi
                JOIN ingredients i ON rhi.ingredients_ingredient_id = i.ingredient_id
            WHERE
                rhi.recipes_recipe_id = recipe_id_var
            GROUP BY
                rhi.recipes_recipe_id
        ) AS nutritional_sums ON r.recipe_id = nutritional_sums.recipes_recipe_id
        SET
            r.total_carbs = nutritional_sums.total_carbs,
            r.total_fat = nutritional_sums.total_fat,
            r.total_protein = nutritional_sums.total_protein,
            r.total_calories = nutritional_sums.total_calories;
    END LOOP;

    -- Close the cursor
    CLOSE recipe_cursor;
END;
