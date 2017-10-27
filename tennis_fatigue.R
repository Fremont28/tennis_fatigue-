# We built a logistic regression model that tests if tennis players’ performance 
# diminishes from after playing in a match lasting longer than the 101 minutes (the median length of a tennis match). 
# We weren’t interested in comparing a player’s consecutive match performances if he had more than three to four days to recover, which 
# would diminish the effect of the fatigue factor. 

# To test our hypothesis, we randomly sampled 481 tennis matchups from the 2016 tennis season 
# using Jeff Sackmann’s data from Tennis Abstract. We created a binary variable measuring if a particular matchup lasted longer 
# than 101 minutes and then used a for loop to find the outcome from the player’s next match accounting for 
# the match id, the winner name, the length of match (minutes), the winner rank, and the loser rank. 

#libraries 
library(plyr)
library(dplyr)
library(ggplot2)

#read-in the dataset (2016 tennis season indiviudal matchups)
tennis_16<- read.csv(file.choose(),header=TRUE)
#assign a game (match) id
tennis_16$game_id<-seq.int(nrow(tennis_16))
#Label matches as 0 or 1 depending whether the match lasted kibger than 101 minutes 
tennis_16$minutes_over_under<-ifelse(tennis_16$minutes > 101,1,0)

#Find the match outcomes of indivdiual players 
#We will use Rafael Nadal as an example. 
player<-subset(tennis_16,winner_name=="Rafael Nadal" | loser_name=="Rafael Nadal")

# A for loop that finds the outcome of the player's next match 
ind<-which(player$winner_name=="Rafael Nadal")
follow_up<-data.frame(winner_name=c(),loser_name=c(),game_id=c())
for(i in 1:length(ind)) {
  follow_up[i,1]=player[ind[i]+1,]$winner_name
  follow_up[i,2]=player[ind[i]+1,]$minutes
  follow_up[i,3]=player[ind[i]+1,]$surface
  follow_up[i,4]=player[ind[i]+1,]$game_id
  follow_up[i,5]=player[ind[i]+1,]$winner_rank
  follow_up[i,6]=player[ind[i]+1,]$loser_rank
  follow_up[i,7]=player[ind[i]+1,]$minutes_over_under
}

#Rename columns for new dataset 
follow_up1<-plyr::rename(follow_up, c("V1"="winning_player", "V2"="minutes",
                                      "V3"="surface",V4="game_id",V5="winner_rank",V6="loser_rank",V7="minutes_over_under"))
#asign win or loss to the match 
follow_up1$Win<-ifelse(follow_up1$winning_player=="Rafael Nadal",1,0)
#length of the previous match (minutes)
follow_up2<- mutate(follow_up1, prev_min = lag(follow_up1$minutes))
#difference in minutes between consecutive matches 
follow_up2$diff_min<-follow_up2$minutes-follow_up2$prev
#previous game id
follow_up3<-mutate(follow_up2,game_id_prev=lag(follow_up2$game_id))
#difference in game ids 
follow_up3$diff_game_id<-(follow_up3$game_id-follow_up3$game_id_prev)
#the length of the previous match 
follow_up4<-mutate(follow_up3,minutes_over_under_prev=lag(follow_up3$minutes_over_under))
follow_up4$minutes_over_under<-as.factor(follow_up4$minutes_over_under)

#Subset the dataset for wins and losses and matches seperated by less than 60
#rows in the dataset 
losses<-subset(follow_up4,Win==0 & diff_game_id<60)
wins<-subset(follow_up4,Win==1 & diff_game_id<60)
final_match<-rbind(losses,wins)
final_match$Win<-as.factor(final_match$Win)

#Logistic regression model 
tennis_lr<-glm(Win~diff_min+winner_rank+loser_rank,family=binomial,data=tennis_bayes)
#probability of a win 
tennis_bayes$win_prob<-predict(tennis_lr,tennis_bayes,type="response")

# The relationship between the match length difference 
#between consecutive matches in minutes and win probability
ggplot(tennis_bayes,aes(x=diff_min,y=win_prob))+geom_point()+xlab("Match Length Difference (minutes)")+
  ylab("Win Probability")+ggtitle("Fatigue is not a factor in tennis")+
  theme(plot.title = element_text(hjust = 0.5))

# Naive Bayes Classifier 
#import library
library(e1071)
#train and test data
sample_data = sort(sample(nrow(tennis_bayes), nrow(tennis_bayes)*.7))
train<-tennis_bayes[sample_data,]
test<-tennis_bayes[-sample_data,]
#Fitting the naive bayes model
fit_nb<-naiveBayes(Win~minutes_over_under,data=train)




