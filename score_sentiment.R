score.sentiment = function(tweet_sentences, positive.words, negative.words, .progress='none')
{
  require(plyr)
  require(stringr)
  list=lapply(tweet_sentences, function(tweet_sentence, positive.words, negative.words)
  {
    tweet_sentence = gsub('\\d+','',tweet_sentence)  #To remove decimal number
    tweet_sentence = gsub('\n','',tweet_sentence)    #To remove new lines
    tweet_sentence = gsub('[[:punct:]]',' ',tweet_sentence) # To remove punctuations
    tweet_sentence = gsub('[[:cntrl:]]','',tweet_sentence)

    tweet_sentence = tolower(tweet_sentence) #converts the characters in tweets to lowercase
    word.list = str_split(tweet_sentence, '\\s+')
    words = unlist(word.list)  #changes a list to character vector
    positive.matches = match(words, positive.words)
    negative.matches = match(words, negative.words)
    positive.matches = !is.na(positive.matches)
    negative.matches = !is.na(negative.matches)
    pp = sum(positive.matches)
    nn = sum(negative.matches)
    score = sum(positive.matches) - sum(negative.matches)
    list1 = c(score, pp, nn)
    return (list1)
  }, positive.words, negative.words)
  score_new = lapply(list, `[[`, 1)
  pp1 = lapply(list, `[[`, 2)
  nn1 = lapply(list, `[[`, 3)
  
  scores.df = data.frame(score = score_new, text=tweet_sentences)
  positive.df = data.frame(Positive = pp1, text=tweet_sentences)
  negative.df = data.frame(Negative = nn1, text=tweet_sentences)
  
  list_df = list(scores.df, positive.df, negative.df)
  return(list_df)
}
