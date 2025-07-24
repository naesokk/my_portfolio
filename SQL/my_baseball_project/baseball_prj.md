## My SQL project (just in case I pass Intern Level)
### 0) Dataset Original 
+ The dataset belongs to **Lahman Baseball Database** [https://sabr.org/lahman-database]
+ **4 CSVs** : **players, salaries, school_details, schools**
+ Before querying anything, please run the **creating_database.sql" first, or you can connect with 4 csvs files either.

### 1) Problem Statement <img src="https://img.icons8.com/?size=100&id=14748&format=png&color=000000" alt="Problem Statement Icon" width="20">
Before querying, i analyze this projects into 4 parts with total 12 questions(of course related to baseball ,from easy -> hard): 
#### 1) School Analysis
+ Q1: In each decade, how many schools were there that produced MLB players?
+ Q2: What are the names of the top 5 schools that produced the most players?
+ Q3: For each decade, what were the names of the top 3 schools that produced the most players?
  
#### 2) Salary Analysis
+ Q4: Return the top 20% of teams in terms of average annual spending
+ Q5: For each team, show the cumulative sum of spending over the years
+ Q6: Return the first year that each team's cumulative spending surpassed 1 billion 
#### 3) Player Career
+ Q7: For each player, calculate their age at their first (debut) game, their last game, and their career length (all in years). Sort from longest career to shortest career. 
+ Q8: What team did each player play on for their starting and ending years? 
+ Q9: How many players started and ended on the same team and also played for over a decade?
#### 4) Player Comparison
+ Q10: Which players have the same birthday? 
+ Q11: Create a summary table that shows for each team, what percent of players bat right, left and both.
+ Q12: How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
  
### 2) What I Did <img src="https://img.icons8.com/fluency/48/question-mark--v1.png" alt="Question Mark Icon" width="20">
The answers you can check at **quering_results.sql**, but I want to mention about the special in my querying. <br>
Mostly I use CTE instead of subqueries, some advanced functions like
+ **Window Functions(Q3,5,7,12), 
   Rolling Calculations (Q8), Min/Max Value Filtering (Q9), String Function(Q1)**
+ Especially I used **Pivoting(Q11)**, something relatively rare on MySQL when having to use with *Case + When*, so it is quite hard.

### 3) Key Insights <img src="https://img.icons8.com/?size=100&id=20523&format=png&color=000000" alt="Key Insights Icon" width="20">
