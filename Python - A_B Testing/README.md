### 1) About this Game Project  <img src="https://img.icons8.com/?size=100&id=14748&format=png&color=000000" alt="Problem Statement Icon" width="20">
+ The goal of this game is to align **three** identical cookies to feed a cat and complete each level. 
+ In addition to collected credit, you may earn Keys to activate gates at specific levels.


### 2) Data Description 
The data is from 90,189 players that installed the game while the df-test was running. The variables are:
+ `userid` - a unique number that identifies each player.
+ `version` - whether the player was put in the control group (gate_30 - a gate at level 30) or the test group (gate_40 - a gate at level 40).
+ `sum_gamerounds` - the number of game rounds played by the player during the first week after installation
+ `retention_1` - did the player come back and play 1 day after installing?(bool)
+ `retention_7` - did the player come back and play 7 days after installing?(bool) <br>
When a player installed the game, he or she was randomly assigned to either *gate_30* or *gate_40*. <br><br>

### 3) Hypothesis 

Our company are planning to move Cookie Cats' time gates from level 30 to 40, but they don’t know by how much the user retention can be impacted by this decision. <br><br>
So seeing this viewpoint, a decision like this can impact not only user retention, the expected revenue as well that’s why i am going to set the initial hypothesis as:

+ H0: Moving the Time Gate from Level 30 to Level 40 will *increase* our user retention.
+ H1: Moving the Time Gate from Level 30 to Level 40 will *decrease* our user retention.


### 4) What I Did <img src="https://img.icons8.com/fluency/48/question-mark--v1.png" alt="Question Mark Icon" width="20">
+ Perform an A/B testing analysis for the game Cookie Cats on 90,000+ players, using bootstrapping to determine different retention levels. 
+ Results show that moving the job portal from level 30 to 40 reduces 1-day (0.6%) and 7-day (0.8%) retention. 
+ Recommend exporting the retention portal at level 30 to optimize player retention.
