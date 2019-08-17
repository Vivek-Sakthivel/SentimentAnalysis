#To extract the top 20 tweeters of the extracted hashtag in the collected corpus
  
    toptweeters-function(tweetDataset)
  {
    sampleTweets - twListToDF(tweetDataset)
    sampleTweets - unique(sampleTweets)
    # Make a table of the number of Tweets per user
    tweeterData - as.data.frame(table(sampleTweets$screenName)) 
    tweeterData - tweeterData[order(tweeterData$Freq, decreasing=T), ] #descending order of tweeters according to frequency of sampleTweets
    names(tweeterData) - c(User,Tweets)
    return (tweeterData)
  }
  
  # Tabular representation of the Top 20 tweeters details
  
  tweeterData-reactive({tweeterData-toptweeters(  extracted_TweetsList() ) })
  output$top20TweetersGraph-renderPlot ( barplot(head(tweeterData()$Tweets, 20), names=head(tweeterData()$User, 20), horiz=F, las=2, main=Top Tweeters, col=1) )
  output$top20TweetersTable-renderTable(head(tweeterData(),20))
