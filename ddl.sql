USE test;

DROP TABLE IF EXISTS recipes_has_steps;
DROP TABLE IF EXISTS recipes_has_meal_type;
DROP TABLE IF EXISTS recipes_has_tags;
DROP TABLE IF EXISTS recipes_has_tips;
DROP TABLE IF EXISTS recipes_has_equipment;
DROP TABLE IF EXISTS recipes_has_ingredients;
DROP TABLE IF EXISTS recipes_has_themes;
DROP TABLE IF EXISTS cook_has_recipe_in_episodes;
DROP TABLE IF EXISTS recipes_has_cooks;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS ingredient_groups;
DROP TABLE IF EXISTS national_cuisine;
DROP TABLE IF EXISTS tips;
DROP TABLE IF EXISTS meal_type;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS episodes;
DROP TABLE IF EXISTS cooks ;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS steps;
DROP TABLE IF EXISTS themes;



-- Table ingredient_groups

CREATE TABLE IF NOT EXISTS ingredient_groups (
  ingredient_group_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  description VARCHAR(45) NOT NULL,
  PRIMARY KEY (ingredient_group_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX ingredient_group_id_UNIQUE ON ingredient_groups (ingredient_group_id);



-- Table ingredients


CREATE TABLE IF NOT EXISTS ingredients (
  ingredient_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fat INT UNSIGNED NOT NULL,
  carbs INT UNSIGNED NOT NULL,
  protein INT UNSIGNED NOT NULL,
  calories INT UNSIGNED NOT NULL,
  name VARCHAR(45) NOT NULL,
  ingredient_groups_ingredient_group_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (ingredient_id),
  CONSTRAINT fk_ingredients_ingredient_groups1
    FOREIGN KEY (ingredient_groups_ingredient_group_id)
    REFERENCES ingredient_groups (ingredient_group_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX name_UNIQUE ON ingredients (name);

CREATE UNIQUE INDEX ingredient_id_UNIQUE ON ingredients (ingredient_id);

CREATE INDEX fk_ingredients_ingredient_groups1_idx ON ingredients (ingredient_groups_ingredient_group_id);



-- Table national_cuisine



CREATE TABLE IF NOT EXISTS national_cuisine (
  national_cuisine_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  PRIMARY KEY (national_cuisine_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX name_UNIQUE ON national_cuisine (name);



-- Table recipes


CREATE TABLE IF NOT EXISTS recipes (
  recipe_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type ENUM("COOKING", "BAKING") NOT NULL,
  difficulty ENUM("VERY_EASY", "EASY", "NORMAL", "DIFFICULT", "VERY_DIFFICULT") NOT NULL,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(45) NOT NULL,
  prep_time INT UNSIGNED NOT NULL,
  cooking_time INT UNSIGNED NOT NULL,
  portions INT NOT NULL,
  ingredients_ingredient_id INT UNSIGNED NOT NULL,
  national_cuisine_national_cuisine_id INT UNSIGNED NOT NULL,
  total_fat INT NULL,
  total_carbs INT NULL,
  total_protein INT NULL,
  total_calories INT NULL,
  PRIMARY KEY (recipe_id),
  CONSTRAINT fk_recipes_ingredients1
    FOREIGN KEY (ingredients_ingredient_id)
    REFERENCES ingredients (ingredient_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_national_cuisine1
    FOREIGN KEY (national_cuisine_national_cuisine_id)
    REFERENCES national_cuisine (national_cuisine_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX recipe_id_UNIQUE ON recipes (recipe_id);

CREATE UNIQUE INDEX name_UNIQUE ON recipes (name);

CREATE UNIQUE INDEX description_UNIQUE ON recipes (description);

CREATE INDEX fk_recipes_ingredients1_idx ON recipes (ingredients_ingredient_id);

CREATE INDEX fk_recipes_national_cuisine1_idx ON recipes (national_cuisine_national_cuisine_id);



-- Table tips


CREATE TABLE IF NOT EXISTS tips (
  tip_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  description VARCHAR(45) NOT NULL,
  PRIMARY KEY (tip_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX tip_id_UNIQUE ON tips (tip_id);

CREATE UNIQUE INDEX description_UNIQUE ON tips (description);



-- Table meal_type


CREATE TABLE IF NOT EXISTS meal_type (
  meal_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  PRIMARY KEY (meal_type_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX name_UNIQUE ON meal_type (name);

CREATE UNIQUE INDEX meal_type_id_UNIQUE ON meal_type (meal_type_id);



-- Table equipment


CREATE TABLE IF NOT EXISTS equipment (
  equipment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  instructions VARCHAR(45) NOT NULL,
  PRIMARY KEY (equipment_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX name_UNIQUE ON equipment (name);

CREATE UNIQUE INDEX equipment_id_UNIQUE ON equipment (equipment_id);



-- Table steps


CREATE TABLE IF NOT EXISTS steps (
  step_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  step_description VARCHAR(45) NOT NULL,
  PRIMARY KEY (step_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX step_description_UNIQUE ON steps (step_description);

CREATE UNIQUE INDEX step_id_UNIQUE ON steps (step_id);



-- Table themes


CREATE TABLE IF NOT EXISTS themes (
  theme_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  description VARCHAR(45) NOT NULL,
  PRIMARY KEY (theme_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX name_UNIQUE ON themes (name);

CREATE UNIQUE INDEX description_UNIQUE ON themes (description);

CREATE UNIQUE INDEX theme_UNIQUE ON themes (theme_id);



-- Table cooks


CREATE TABLE IF NOT EXISTS cooks (
  cook_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  phone_number VARCHAR(45) NOT NULL,
  date_of_birth DATE NOT NULL,
  age INT UNSIGNED NOT NULL,
  role ENUM("A", "B", "C", "SOUS_CHEF", "CHEF") NOT NULL,
  years_of_experience INT UNSIGNED NULL,
  PRIMARY KEY (cook_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX cook_id_UNIQUE ON cooks (cook_id);

CREATE UNIQUE INDEX phone_number_UNIQUE ON cooks (phone_number);



-- Table episodes


CREATE TABLE IF NOT EXISTS episodes (
  episode_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  judge1_id INT UNSIGNED NULL,
  judge2_id INT UNSIGNED NULL,
  judge3_id INT UNSIGNED NULL,
  episode_season TINYINT NULL,
  episode TINYINT NULL,
  PRIMARY KEY (episode_id),
  CONSTRAINT fk_episodes_cooks1
    FOREIGN KEY (judge1_id)
    REFERENCES cooks (cook_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_episodes_cooks2
    FOREIGN KEY (judge2_id)
    REFERENCES cooks (cook_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_episodes_cooks3
    FOREIGN KEY (judge3_id)
    REFERENCES cooks (cook_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX episode_id ON episodes (episode_id);


CREATE INDEX fk_episodes_cooks1_idx ON episodes (judge1_id);

CREATE INDEX fk_episodes_cooks2_idx ON episodes (judge2_id);

CREATE INDEX fk_episodes_cooks3_idx ON episodes (judge3_id);



-- Table tags


CREATE TABLE IF NOT EXISTS tags (
  tag_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  PRIMARY KEY (tag_id))
ENGINE = InnoDB;

CREATE UNIQUE INDEX tag_id_UNIQUE ON tags (tag_id);

CREATE UNIQUE INDEX name_UNIQUE ON tags (name);



-- Table recipes_has_steps


CREATE TABLE IF NOT EXISTS recipes_has_steps(
  recipes_recipe_id INT UNSIGNED NOT NULL,
  steps_step_id INT UNSIGNED NOT NULL,
  `order` INT UNSIGNED NOT NULL,
  PRIMARY KEY (recipes_recipe_id, steps_step_id),
  CONSTRAINT fk_recipes_has_steps_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_steps_steps1
    FOREIGN KEY (steps_step_id)
    REFERENCES steps (step_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_steps_steps1_idx ON recipes_has_steps (steps_step_id);

CREATE INDEX fk_recipes_has_steps_recipes1_idx ON recipes_has_steps (recipes_recipe_id);



-- Table recipes_has_meal_type


CREATE TABLE IF NOT EXISTS recipes_has_meal_type (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  meal_type_meal_type_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (meal_type_meal_type_id, recipes_recipe_id),
  CONSTRAINT fk_recipes_has_meal_type_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_meal_type_meal_type1
    FOREIGN KEY (meal_type_meal_type_id)
    REFERENCES meal_type (meal_type_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_meal_type_meal_type1_idx ON recipes_has_meal_type (meal_type_meal_type_id);

CREATE INDEX fk_recipes_has_meal_type_recipes1_idx ON recipes_has_meal_type (recipes_recipe_id);



-- Table recipes_has_tags


CREATE TABLE IF NOT EXISTS recipes_has_tags (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  tags_tag_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (tags_tag_id, recipes_recipe_id),
  CONSTRAINT fk_recipes_has_tags_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_tags_tags1
    FOREIGN KEY (tags_tag_id)
    REFERENCES tags (tag_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_tags_tags1_idx ON recipes_has_tags (tags_tag_id);

CREATE INDEX fk_recipes_has_tags_recipes1_idx ON recipes_has_tags (recipes_recipe_id);



-- Table recipes_has_tips


CREATE TABLE IF NOT EXISTS recipes_has_tips (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  tips_tip_id3 INT UNSIGNED NOT NULL,
  tips_tip_id1 INT UNSIGNED NOT NULL,
  tips_tip_id2 INT UNSIGNED NOT NULL,
  PRIMARY KEY (recipes_recipe_id),
  CONSTRAINT fk_recipes_has_tips_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_tips_tips1
    FOREIGN KEY (tips_tip_id3)
    REFERENCES tips (tip_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_tips_tips2
    FOREIGN KEY (tips_tip_id1)
    REFERENCES tips (tip_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_tips_tips3
    FOREIGN KEY (tips_tip_id2)
    REFERENCES tips (tip_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_tips_recipes1_idx ON recipes_has_tips (recipes_recipe_id);

CREATE UNIQUE INDEX recipes_recipe_id_UNIQUE ON recipes_has_tips (recipes_recipe_id);

CREATE INDEX fk_recipes_has_tips_tips1_idx ON recipes_has_tips (tips_tip_id3);

CREATE INDEX fk_recipes_has_tips_tips2_idx ON recipes_has_tips (tips_tip_id1);

CREATE INDEX fk_recipes_has_tips_tips3_idx ON recipes_has_tips (tips_tip_id2);



-- Table recipes_has_equipment


CREATE TABLE IF NOT EXISTS recipes_has_equipment (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  equipment_equipment_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (equipment_equipment_id, recipes_recipe_id),
  CONSTRAINT fk_recipes_has_equipment_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_equipment_equipment1
    FOREIGN KEY (equipment_equipment_id)
    REFERENCES equipment (equipment_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_equipment_equipment1_idx ON recipes_has_equipment (equipment_equipment_id);

CREATE INDEX fk_recipes_has_equipment_recipes1_idx ON recipes_has_equipment (recipes_recipe_id);



-- Table recipes_has_ingredients


CREATE TABLE IF NOT EXISTS recipes_has_ingredients (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  ingredients_ingredient_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (ingredients_ingredient_id, recipes_recipe_id),
  CONSTRAINT fk_recipes_has_ingredients_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_ingredients_ingredients1
    FOREIGN KEY (ingredients_ingredient_id)
    REFERENCES ingredients (ingredient_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_ingredients_ingredients1_idx ON recipes_has_ingredients (ingredients_ingredient_id);

CREATE INDEX fk_recipes_has_ingredients_recipes1_idx ON recipes_has_ingredients (recipes_recipe_id);



-- Table recipes_has_themes


CREATE TABLE IF NOT EXISTS recipes_has_themes (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  themes_theme_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (recipes_recipe_id, themes_theme_id),
  CONSTRAINT fk_recipes_has_themes_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_themes_themes1
    FOREIGN KEY (themes_theme_id)
    REFERENCES themes (theme_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_recipes_has_themes_themes1_idx ON recipes_has_themes (themes_theme_id);

CREATE INDEX fk_recipes_has_themes_recipes1_idx ON recipes_has_themes (recipes_recipe_id);



-- Table recipes_has_cooks


CREATE TABLE IF NOT EXISTS recipes_has_cooks (
  recipes_recipe_id INT UNSIGNED NOT NULL,
  cooks_cook_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (recipes_recipe_id, cooks_cook_id),
  CONSTRAINT fk_recipes_has_cooks_recipes1
    FOREIGN KEY (recipes_recipe_id)
    REFERENCES recipes (recipe_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_recipes_has_cooks_cooks1
    FOREIGN KEY (cooks_cook_id)
    REFERENCES cooks (cook_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
KEY_BLOCK_SIZE = 2;

CREATE INDEX fk_recipes_has_cooks_cooks1_idx ON recipes_has_cooks (cooks_cook_id);

CREATE INDEX fk_recipes_has_cooks_recipes1_idx ON recipes_has_cooks (recipes_recipe_id);




-- Table cook_has_recipe_in_episodes


CREATE TABLE IF NOT EXISTS cook_has_recipe_in_episodes (
  episodes_episode_id INT UNSIGNED NOT NULL,
  recipes_has_cooks_recipes_recipe_id INT UNSIGNED NOT NULL,
  recipes_has_cooks_cooks_cook_id INT UNSIGNED NOT NULL,
  grade1 TINYINT NULL,
  grade2 TINYINT NULL,
  grade3 TINYINT NULL,
  PRIMARY KEY (episodes_episode_id, recipes_has_cooks_cooks_cook_id, recipes_has_cooks_recipes_recipe_id),
  CONSTRAINT fk_episodes_has_recipes_episodes1
    FOREIGN KEY (episodes_episode_id)
    REFERENCES episodes (episode_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_cook_has_recipe_in_episodes_recipes_has_cooks1
    FOREIGN KEY (recipes_has_cooks_recipes_recipe_id , recipes_has_cooks_cooks_cook_id)
    REFERENCES recipes_has_cooks (recipes_recipe_id , cooks_cook_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_episodes_has_recipes_episodes1_idx ON cook_has_recipe_in_episodes (episodes_episode_id);

CREATE INDEX fk_cook_has_recipe_in_episodes_recipes_has_cooks1_idx ON cook_has_recipe_in_episodes (recipes_has_cooks_recipes_recipe_id, recipes_has_cooks_cooks_cook_id);


CREATE TABLE IF NOT EXISTS current_season (
    season_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    current_season INT UNSIGNED NOT NULL,
    PRIMARY KEY (season_id)
);
