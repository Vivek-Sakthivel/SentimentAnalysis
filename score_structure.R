# To create a merged data frame
sentiment = score.sentiment(sample, positive.words, negative.words)

library(reshape)
temp1=sentiment[[1]]
temp2=sentiment[[2]]
temp3=sentiment[[3]]

#To create three different data frames for Score, Positive and Negative
#Removing text column from data frame
temp1$text=NULL
temp2$text=NULL
temp3$text=NULL
#To store the first row which contains the sentiment scores in variable s
s1=temp1[1,]
s2=temp2[1,]
s3=temp3[1,]
ss1=melt(s1, ,var='Score')
ss2=melt(s2, ,var='Positive')
ss3=melt(s3, ,var='Negative') 
ss1['Score'] = NULL
ss2['Positive'] = NULL
ss3['Negative'] = NULL
# To create data frame
dataframe1 = data.frame(Text=sentiment[[1]]$text, Score=ss1)
dataframe2 = data.frame(Text=sentiment[[2]]$text, Score=ss2)
dataframe3 = data.frame(Text=sentiment[[3]]$text, Score=ss3)

#Merging three data frames into one
dataframe_final=data.frame(Text=dataframe1$Text, Score=dataframe1$value, Positive=dataframe2$value, Negative=dataframe3$value)
