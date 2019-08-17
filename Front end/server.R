EnsurePackage<-function(x)
{
x <- as.character(x)
if (!require(x,character.only=TRUE))
{
  install.packages(pkgs=x,repos="http://cran.r-project.org")
  require(x,character.only=TRUE)
}
}
# To install all the necessary packages 
PrepareSystem<-function()
{
  EnsurePackage("RJSONIO")
  EnsurePackage("wordcloud")
  EnsurePackage("stringr")
  EnsurePackage("ROAuth")
  EnsurePackage("syuzhet")
  EnsurePackage("plyr")
  EnsurePackage("gridExtra")
  EnsurePackage("xlsx")
  EnsurePackage("twitteR")  
  EnsurePackage("RCurl")
  EnsurePackage("e1071")
  EnsurePackage("RTextTools")
  EnsurePackage("ggplot2")
  EnsurePackage("reshape")
  EnsurePackage("tm")
}



PrepareSystem()

shinyServer(function(input, output) {
  
 # Preprocessing of the extracted Tweets
 TweetFrame<-function(extracted_TweetsList)
  {
    df<- do.call("rbind",lapply(extracted_TweetsList,as.data.frame))
   # Lower-case conversion
    df$tweetTexts <- sapply(df$tweetTexts,function(row) iconv(row, "latin1", "ASCII", sub=""))
   # Identify and remove URL
    df$tweetTexts = gsub("http[^[:blank:]]+", "", df$tweetTexts)
    return (df$tweetTexts)
  }
   
  # To scan the positive and negative lexicons.
  
  positive.words = scan('B:/Sentiment_Analysis/positive-words.txt', what='character',   comment.char=';')
  negative.words = scan('B:/Sentiment_Analysis/negative-words.txt', what='character', comment.char=';')
   wordDatabase<-function()
  {
    positive.words<<-c(positive.words, 'thnx', 'cool', 'gud',’,'swt', 'chweet', 'enuf', 'gr8', 'hot', 'cute', 'plz', 'trending',)
    negative.words<<-c(negative.words, 's*ck', 'f*ck', 'wtf', 'dead', 'no', 'unstable', 'thumbsdown')
  }
  
  score.sentiment <- function(tweet_sentences, positive.words, negative.words, .progress='none')
  {
    require(plyr)
    require(stringr)
    list=lapply(tweet_sentences, function(tweet_sentence, positive.words, negative.words)
    {
      tweet_sentence = gsub('[[:punct:]]',' ',tweet_sentence)
      tweet_sentence = gsub('[[:cntrl:]]','',tweet_sentence)
      tweet_sentence = gsub('\\d+','',tweet_sentence)
      tweet_sentence = gsub('\n','',tweet_sentence)
      tweet_sentence = tolower(tweet_sentence)
      word.list = str_split(tweet_sentence, '\\s+')
      words = unlist(word.list)
      positive.matches = match(words, positive.words)
      negative.matches = match(words, negative.words)
      positive.matches = !is.na(positive.matches)
      negative.matches = !is.na(negative.matches)
      Temp_Positive=sum(positive.matches)
      Temp_Negative = sum(negative.matches)
      score = sum(positive.matches) - sum(negative.matches)
      list1=c(score, Temp_Positive, Temp_Negative)
      return (list1)
    }, positive.words, negative.words)
    score_new=lapply(list, `[[`, 1)
    Temp_Pos=score=lapply(list, `[[`, 2)
    Temp_Neg=score=lapply(list, `[[`, 3)
    
    scores.df = data.frame(score=score_new, tweetTexts=tweet_sentences)
    positive.df = data.frame(Positive=Temp_Pos, tweetTexts=tweet_sentences)
    negative.df = data.frame(Negative=Temp_Neg, tweetTexts=tweet_sentences)
    
    list_df=list(scores.df, positive.df, negative.df)
    mysentiment <- get_nrc_sentiment(tweet_sentences)
    SentimentScores <- data.frame(colSums(mysentiment[,]))
    names(SentimentScores) <- "Score"
    SentimentScores <- cbind("Sentiment" = rownames(SentimentScores),SentimentScores)
    Sent<- reactive({SentimentScores})
    rownames(SentimentScores)<- NULL
    
    #nrcSentiment<- reactive ({ nrcSentiment =ggplot(Sent(),aes(x = Sentiment, y = Score))+ geom_bar(aes(fill = Sentiment),stat="identity")+ theme(legend.position = "none") + xlab("Sentiment")+ylab("Score") +
    # ggtitle ("Sentiment score of the Corpus")})
    
    nrcSentiment<- reactive ({ nrcSentiment = ggplot(Sent(), aes(x = Sentiment, y = Score)) + geom_bar(aes(fill = Sentiment),stat="identity")
    nrcSentiment + theme(legend.position = "none")+labs(title = "Sentiment score of the Overall Corpus") })
    
    output$sentichart<- renderPlot({nrcSentiment()})
    
    return(list_df)
  }
  
  #Tabular representation of the extracted data
  
  library(reshape)
  sentimentAnalyser<-function(result)
  {
    # The temporary copies of result dataframes 
    temp1=result[[1]]
    temp2=result[[2]]
    temp3=result[[3]]
    
#To create three individual data frames for displaying positive, negative and overall score  
    temp1$tweetTexts=NULL
# To remove tweet reference from the created data frame
    temp2$tweetTexts=NULL
    temp3$tweetTexts=NULL
    #The value of sentiment score which is available in the first row is stored in variable s

    s1=temp1[1,]
    s2=temp2[1,]
    s3=temp3[1,]
    ss1=melt(s1, ,var='Score')
    ss2=melt(s2, ,var='Positive')
    ss3=melt(s3, ,var='Negative') 
    ss1['Score'] = NULL
    ss2['Positive'] = NULL
    ss3['Negative'] = NULL
    dataframe1 = data.frame(Text=result[[1]]$tweetTexts, Score=ss1)
    dataframe2 = data.frame(Text=result[[2]]$tweetTexts, Score=ss2)
    dataframe3 = data.frame(Text=result[[3]]$tweetTexts, Score=ss3)
    
    #Integrating individual data frames into dataframe_final
    dataframe_final=data.frame(Tweets=dataframe1$Text, Positive=dataframe2$value, Negative=dataframe3$value, Score=dataframe1$value)
    return(dataframe_final)
  }
  
  percentage<-function(dataframe_final)
  {
    #To calculate Positive Percentage 
    PositiveScore=dataframe_final$Positive
    NegativeScore=dataframe_final$Negative
   
    dataframe_final$PositivePercent = PositiveScore/ (PositiveScore+NegativeScore)
    
    Temp_Positive = dataframe_final$PositivePercent
    Temp_Positive[is.nan(Temp_Positive)] <- 0
    dataframe_final$PositivePercent = Temp_Positive*100
    
    # To calculate negative percentage
    
    dataframe_final$NegativePercent = NegativeScore/ (PositiveScore+NegativeScore)
    
    Temp_Negative = dataframe_final$NegativePercent
    Temp_Negative[is.nan(Temp_Negative)] <- 0
    dataframe_final$NegativePercent = Temp_Negative*100
    
    write.xlsx(dataframe_final, "B:/Sentiment_Analysis/mydata.xlsx")
    return(dataframe_final)
    
  }
  
  wordDatabase()
  
  extracted_TweetsList<-reactive({extracted_TweetsList<-searchTwitter(input$relevantHashtag, n=input$numberofTweets, lang="en") })
  sampleTweets<-reactive({sampleTweets<-TweetFrame(extracted_TweetsList() )})
  
  result<-reactive({result<-score.sentiment(sampleTweets(), positive.words, negative.words, .progress='none')})
  
  dataframe_final<-reactive({dataframe_final<-sentimentAnalyser(  result() )})
  dataframe_final_percentage<-reactive({dataframe_final_percentage<-percentage(  dataframe_final() )})
  
  output$tabularOutput<-renderTable(dataframe_final_percentage())	
  
  #To create wordcloud
  wordclouds<-function(tweetTexts)
  {
    library(tm)
    library(wordcloud)
    corpus <- Corpus(VectorSource(tweetTexts))
    #pre-processing of Tweets
    pp_tweets <- tm_map(corpus, removePunctuation)
    #pp_tweets <- tm_map(pp_tweets, content_transformation)
    pp_tweets <- tm_map(pp_tweets, content_transformer(tolower))
    pp_tweets <- tm_map(pp_tweets, removeWords, stopwords("english"))
    pp_tweets <- tm_map(pp_tweets, removeNumbers)
    pp_tweets <- tm_map(pp_tweets, stripWhitespace)
    return (pp_tweets)
  }
  tweetTexts_word<-reactive({tweetTexts_word<-wordclouds( sampleTweets() )})
  
  output$outputWordCloud <- renderPlot({ wordcloud(tweetTexts_word(),random.order=F,max.words=80, col=rainbow(100), scale=c(4.5, 1)) })
  
  #To create histograms for representing positive, negative and overall score.
  output$histogramPositive<- renderPlot({ hist(dataframe_final()$Positive, col=rainbow(10), main="Histogram of Positive Sentiment", xlab = "Positive Score") })
  output$histogramNegative<- renderPlot({ hist(dataframe_final()$Negative, col=rainbow(10), main="Histogram of Negative Sentiment", xlab = "Negative Score") })
  output$histogramScore<- renderPlot({ hist(dataframe_final()$Score, col=rainbow(10), main="Histogram of Score Sentiment", xlab = "Overall Score") })	
   # To create NRC base sentiment analysis chart  - An addon functionality
  
  mysentiment <- get_nrc_sentiment(tweet_sentences)
  SentimentScores <- data.frame(colSums(mysentiment[,]))
  names(SentimentScores) <- "Score"
  SentimentScores <- cbind("Sentiment" = rownames(SentimentScores),SentimentScores)
  Sent<- reactive({SentimentScores})
  rownames(SentimentScores)<- NULL
  
  #nrcSentiment<- reactive ({ nrcSentiment =ggplot(Sent(),aes(x = Sentiment, y = Score))+ geom_bar(aes(fill = Sentiment),stat="identity")+ theme(legend.position = "none") + xlab("Sentiment")+ylab("Score") +
   # ggtitle ("Sentiment score of the Corpus")})
  
  nrcSentiment<- reactive ({ nrcSentiment = ggplot(Sent(), aes(x = Sentiment, y = Score)) + geom_bar(aes(fill = Sentiment),stat="identity")
  nrcSentiment + theme(legend.position = "none")+labs(title = "Sentiment score of the Overall Corpus") })
   
  output$sentichart<- renderPlot({nrcSentiment()})
  
  #To extract the locations-based top trending tweets 
  toptrends <- function(place)
  {
    trend_Loc = availableTrendLocations()
    woeid = trend_Loc[which(trend_Loc$name==place),3]
    trend = getTrends(woeid)
    trends = trend[1:2]
    
    Temp_location1 <- cbind(trends$name)
    Temp_location2 <- unlist(strsplit(Temp_location1, split=", "))
    Temp_location2 <- grep("Temp_location2", iconv(Temp_location2, "latin1", "ASCII", sub="Temp_location2"))
    Temp_location4 <- Temp_location2[-Temp_location2]
    return (Temp_location4)
  }
  
  trendLocation_table<-reactive({ trendLocation_table<-toptrends(input$hashtagTrendsTable) })
  output$trendingHashtagTable <- renderTable(trendLocation_table())
  
  #To extract the top 20 tweeters of the extracted hashtag in the collected corpus
  
    toptweeters<-function(tweetDataset)
  {
    sampleTweets <- twListToDF(tweetDataset)
    sampleTweets <- unique(sampleTweets)
    # Make a table of the number of Tweets per user
    tweeterData <- as.data.frame(table(sampleTweets$screenName)) 
    tweeterData <- tweeterData[order(tweeterData$Freq, decreasing=T), ] #descending order of tweeters according to frequency of sampleTweets
    names(tweeterData) <- c("User","Tweets")
    return (tweeterData)
  }
  
  # Tabular representation of the Top 20 tweeters details
  
  tweeterData<-reactive({tweeterData<-toptweeters(  extracted_TweetsList() ) })
  output$top20TweetersGraph<-renderPlot ( barplot(head(tweeterData()$Tweets, 20), names=head(tweeterData()$User, 20), horiz=F, las=2, main="Top Tweeters", col=1) )
  output$top20TweetersTable<-renderTable(head(tweeterData(),20))
  
  #To perform influencer analysis on the extracted Top 20 users.
  
  Temptweeters1 <- reactive({ Temptweeters1 = userTimeline(input$user, n = 3200) })
  Temptweeters <- reactive({ Temptweeters = twListToDF(Temptweeters1()) })
  vector<-reactive ({ vector = Temptweeters()$tweetTexts })
  
  extract.hashtags = function(TempVector){
    
   hashtag.pattern = "#[[:alpha:]]+"
   have.hashtag = grep(x = TempVector, pattern = hashtag.pattern)
    
   hashtag.matches = gregexpr(pattern = hashtag.pattern,
                            tweetTexts = TempVector[have.hashtag])
   extracted.hashtag = regmatches(x = TempVector[have.hashtag], m = hashtag.matches)
    
   df = data.frame(table(tolower(unlist(extracted.hashtag))))
   colnames(df) = c("tag","freq")
   df = df[order(df$freq,decreasing = TRUE),]
   return(df)
  }
  
  Temp_location1<-reactive({ Temp_location1 = head(extract.hashtags(vector()),50) })
  Temp_location2<- reactive ({ Temp_location2 = transform(Temp_location1(),tag = reorder(tag,freq)) })
  
  plotHashtag<- reactive ({ plotHashtag = ggplot(Temp_location2(), aes(x = tag, y = freq)) + geom_bar(stat="identity", fill = "blue")
  plotHashtag + coord_flip() + labs(title = "Hashtag frequencies in the Tweets of the tweeter") })
  output$tweetersHashtagFrequency <- renderPlot ({ plotHashtag() })	
}) #shiny server
