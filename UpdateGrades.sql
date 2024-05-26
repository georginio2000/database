DROP PROCEDURE IF EXISTS UpdateGrades;
CREATE PROCEDURE UpdateGrades()
BEGIN
    -- Update grades for all entries in cook_has_recipe_in_episodes
    UPDATE test.cook_has_recipe_in_episodes
    SET 
        grade1 = FLOOR(1 + RAND() * 5),
        grade2 = FLOOR(1 + RAND() * 5),
        grade3 = FLOOR(1 + RAND() * 5);
END