use my_baseball_project;

-- perform a check with 4 tables
SELECT * FROM players;
SELECT * FROM salaries; 
SELECT * FROM school_details; 
SELECT * FROM schools; 

-- School Analysis
-- Q1: In each decade, how many schools were there that produced MLB players? 
SELECT ROUND(yearID, -1) as decade, COUNT(DISTINCT schoolID) as num_schools 
FROM schools 
GROUP BY decade
ORDER BY decade;

-- Q2: What are the names of the top 5 schools that produced the most players?
SELECT sd.name_full, COUNT(DISTINCT s.playerID) as num_players
FROM schools s LEFT JOIN school_details sd
	ON s.schoolID = sd.schoolID 
GROUP BY s.schoolID
ORDER BY num_players DESC 
LIMIT 5;

-- Q3: For each decade, what were the names of the top 3 schools that produced the most players? 
WITH ds as(
			SELECT ROUND(s.yearID, -1) as decade, sd.name_full, COUNT(DISTINCT s.playerID) as distinct_players
			FROM schools s LEFT JOIN school_details sd
			ON sd.schoolID = s.schoolID
			GROUP BY decade, sd.name_full),
	 rn as(
			SELECT *, 
					ROW_NUMBER() OVER(PARTITION BY decade ORDER BY distinct_players DESC) as row_num
			FROM ds)
SELECT * FROM rn 
WHERE row_num <= 3;

-- Salary Analysis 
-- Q4: Return the top 20% of teams in terms of average annual spending 
-- calculate total sum, then average them and apply ntile then ctes
WITH ts as (
		SELECT teamID, yearID, SUM(salary) as total_sal
		FROM salaries
		GROUP BY teamID, yearID
		ORDER BY teamID, yearID),
        
	 ps as(
		    SELECT teamID, AVG(total_sal) as avg_salary, 
					NTILE(5) OVER (ORDER BY AVG(total_sal) DESC) as percentile_sal
		    FROM ts
		    GROUP BY teamID)
            
SELECT teamID, ROUND(avg_salary / 1000000,1) as avg_million_spending
FROM ps
WHERE percentile_sal = 1;
        
-- Q5: For each team, show the cumulative sum of spending over the years 
WITH ts as (
			SELECT teamID, yearID, SUM(salary) as total_sal
			FROM salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID) 
SELECT *, 
	ROUND(SUM(total_sal) OVER (PARTITION BY teamID ORDER BY yearID) / 1000000, 1) as mil_cumulative_sum 
FROM ts;

-- Q6: Return the first year that each team's cumulative spending surpassed 1 billion 
WITH ts as (
			SELECT teamID, yearID, SUM(salary) as total_sal 
			FROM salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID),
	mcs as (
			SELECT *, 
			ROUND(SUM(total_sal) OVER (PARTITION BY teamID ORDER BY yearID) / 1000000, 1) as mil_cumulative_sum 
			FROM ts),
            
	cum_rank as (
			SELECT *, 
			DENSE_RANK() OVER (PARTITION BY teamID ORDER BY mil_cumulative_sum ASC) as mil_rank 
			FROM mcs
            WHERE mil_cumulative_sum > 1000)
            
SELECT * FROM cum_rank
WHERE mil_rank  = 1
ORDER BY yearID; 

-- Player Career
-- perform a check on players table
SELECT * FROM players; 

/* Q7: For each player, calculate their age at their first (debut) game, their last game, 
and their career length (all in years). Sort from longest career to shortest career. */
-- B1: Convert to Float
WITH career as (
				SELECT nameGiven, ROUND(birthYear/1) as birth, debut, finalGame,
					   YEAR(debut)/1.0 as year_debut,
					   YEAR(finalGame)/1.0 as year_final,
					   ROUND(DATEDIFF(finalGame, debut) / 365) as career_length
				FROM players)
SELECT nameGiven, birth,career_length,
	   ROUND(year_debut - birth) as age_first_game,
       ROUND(year_final - birth) as age_last_game
FROM career
ORDER BY career_length DESC;

-- B2: Using Cast & TIMESTAMPDIFF
SELECT nameGiven, debut, finalGame, 
	CAST(CONCAT(birthYEAR,'-', birthMonth, '-', birthDay) as DATE) as birthdate,
    TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYEAR,'-', birthMonth, '-', birthDay) as DATE), debut) 
		as debut_year,
    TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYEAR,'-', birthMonth, '-', birthDay) as DATE), finalGame)
		as end_year,
	TIMESTAMPDIFF(YEAR, debut, finalGame) as career_length
FROM players;

-- Q8: What team did each player play on for their starting and ending years? 
SELECT p.nameGiven, 
	   s.yearID as starting_year, s.teamID as starting_team,
       e.yearID as ending_year, e.teamID as ending_team
FROM players p INNER JOIN salaries s 
						  ON p.playerID = s.playerID
						  AND YEAR(p.debut) = s.yearID
				INNER JOIN salaries e 
						  ON p.playerID = e.playerID
						  AND YEAR(p.finalGame) = e.yearID;
-- Q9: How many players started and ended on the same team and also played for over a decade?
WITH same_team_decade as (
					SELECT p.nameGiven, 
						   s.yearID as starting_year, s.teamID as starting_team,
						   e.yearID as ending_year, e.teamID as ending_team
					FROM players p INNER JOIN salaries s 
											  ON p.playerID = s.playerID
											  AND YEAR(p.debut) = s.yearID
									INNER JOIN salaries e 
											  ON p.playerID = e.playerID
											  AND YEAR(p.finalGame) = e.yearID
					WHERE s.teamID = e.teamID
					AND e.yearID - s.yearID >10) 
SELECT DISTINCT COUNT(nameGiven) as players_same_team
FROM same_team_decade ;

-- Player Comparison
-- perform a check for players table
SELECT * FROM players; 

-- Q10: Which players have the same birthday?  
WITH bd as (
		SELECT nameGiven,
			CAST(CONCAT(birthYear, '-', birthMonth, '-',  birthDay) as DATE) as birth_date
		FROM players)
        
SELECT birth_date, GROUP_CONCAT(nameGiven SEPARATOR ',') as players
FROM bd 
WHERE YEAR(birth_date) BETWEEN 1980 AND 1990
GROUP BY birth_date
HAVING COUNT(nameGiven) > 2
ORDER BY birth_date;

/* Q11: Create a summary table that shows for each team, 
what percent of players bat right, left and both. */
SELECT s.teamID, COUNT(s.playerID) as num_players,
	ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID)*100,1) AS bats_right, 
	ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID)*100,1) AS bats_left,
	ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID)*100,1) AS bats_both
FROM salaries s LEFT JOIN players p 
	ON s.playerID = p.playerID
GROUP BY s.teamID;

/* Q12: How have average height and weight at debut game changed over the years, 
and what's the decade-over-decade difference? */
WITH hw as(
	SELECT ROUND(YEAR(debut),-1) as decade, 
			AVG(height) as avg_height, AVG(weight) as avg_weight
	FROM players 
	GROUP BY decade
	ORDER BY decade) -- not really needed
SELECT decade,
	avg_height - LAG(avg_height) OVER(ORDER BY decade) as height_difference, 
    avg_weight - LAG(avg_weight) OVER(ORDER BY decade) as weight_prior
FROM hw
WHERE decade IS NOT NULL; 


