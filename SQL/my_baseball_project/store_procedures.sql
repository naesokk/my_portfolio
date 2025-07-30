use my_baseball_project;
-- create another table 
    CREATE TABLE IF NOT EXISTS team_salary_summary (
        teamID VARCHAR(10),
        yearID INT,
        total_salary BIGINT,
        PRIMARY KEY(teamID, yearID)
    );


-- first_billon_team  
DELIMITER $$
CREATE PROCEDURE first_billion_team(IN in_teamID VARCHAR(3))
BEGIN 
    WITH ts AS (
        SELECT teamID, yearID, SUM(salary) AS total_sal 
        FROM salaries
        WHERE teamID = in_teamID  
        GROUP BY teamID, yearID
    ),
    mcs AS (
        SELECT *, 
            ROUND(SUM(total_sal) OVER (ORDER BY yearID) / 1000000, 1) AS mil_cumulative_sum 
        FROM ts
    ),
    cum_rank AS (
        SELECT *, 
            DENSE_RANK() OVER (ORDER BY mil_cumulative_sum ASC) AS mil_rank 
        FROM mcs
        WHERE mil_cumulative_sum > 1000
    )
    SELECT * 
    FROM cum_rank
    WHERE mil_rank = 1
    ORDER BY yearID;
END $$
DELIMITER ;


-- top_20%_team 
DELIMITER $$ 
CREATE PROCEDURE top_20_percent()
BEGIN
	WITH ts AS (
		SELECT teamID, yearID, SUM(salary) AS total_sal
		FROM salaries
		GROUP BY teamID, yearID
	),
	ps AS (
		SELECT teamID, AVG(total_sal) AS avg_salary, 
			NTILE(5) OVER (ORDER BY AVG(total_sal) DESC) AS percentile_sal
		FROM ts
		GROUP BY teamID
	)
	SELECT teamID, ROUND(avg_salary / 1000000,1) AS avg_million_spending
	FROM ps
	WHERE percentile_sal = 1;
END $$ 
DELIMITER ;


-- players same team 
DELIMITER $$
CREATE PROCEDURE players_same_team()
BEGIN 
    -- Common Table Expression
    WITH same_team_decade AS (
        SELECT p.nameGiven, 
               s.yearID AS starting_year, s.teamID AS starting_team,
               e.yearID AS ending_year, e.teamID AS ending_team
        FROM players p 
        INNER JOIN salaries s 
            ON p.playerID = s.playerID AND YEAR(p.debut) = s.yearID
        INNER JOIN salaries e 
            ON p.playerID = e.playerID AND YEAR(p.finalGame) = e.yearID
        WHERE s.teamID = e.teamID
          AND e.yearID - s.yearID > 10
    ) 
    -- First SELECT: count players
    SELECT DISTINCT COUNT(nameGiven) AS players_same_team
    FROM same_team_decade;

    -- Second SELECT: debug info (for delimiter)
    SELECT * FROM players;
END$$
DELIMITER ;

USE my_baseball_project;

-- Delete Trigger if already had
DROP TRIGGER IF EXISTS trg_update_final_game;
DROP TRIGGER IF EXISTS trg_update_team_salary_summary;

DELIMITER $$

-- 1) Update "Final Game" for Players
CREATE TRIGGER trg_update_final_game
AFTER INSERT ON salaries
FOR EACH ROW
BEGIN
    DECLARE maxYear INT;
    -- Take the biggest (most recent year) to insert salary
    SELECT MAX(yearID)
      INTO maxYear
      FROM salaries
     WHERE playerID = NEW.playerID;

    -- Update the Final Game to 31/12 of that year
    UPDATE players
       SET finalGame = STR_TO_DATE(CONCAT(maxYear, '-12-31'), '%Y-%m-%d')
     WHERE playerID = NEW.playerID;
END$$

-- 2) Trigger Update by Team Salary
CREATE TRIGGER trg_update_team_salary_summary
AFTER INSERT ON salaries
FOR EACH ROW
BEGIN
    -- Insert or Update Salaries 
    INSERT INTO team_salary_summary(teamID, yearID, total_salary)
    VALUES (NEW.teamID, NEW.yearID, NEW.salary)
    ON DUPLICATE KEY UPDATE
        total_salary = total_salary + NEW.salary;
END$$

DELIMITER ;



