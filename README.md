Examining how fatigue effects player performance in tennis 

We built a logistic regression model that tests if tennis players’ performance diminishes from after playing in a match lasting longer   than the 101 minutes (the median length of a tennis match). We weren’t interested in comparing a player’s consecutive match performances if he had more than three to four days to recover, which 
would diminish the effect of the fatigue factor. 

To test our hypothesis, we randomly sampled 481 tennis matchups from the 2016 tennis season 
using Jeff Sackmann’s data from Tennis Abstract. We created a binary variable measuring if a particular matchup lasted longer 
than 101 minutes and then used a for loop to find the outcome from the player’s next match accounting for 
the match id, the winner name, the length of match (minutes), the winner rank, and the loser rank. 
