library(RTextTools)
library(syuzhet)
library(e1071)
library(readxl)
library(tm)
library(wordcloud)
library(gmodels)
###########################################
# "To load the training and testing data" #
###########################################
setwd("B:/Sentiment_Analysis/")
positive = readLines("./positive.txt")
negative = readLines("./negative.txt")
positive_test = readLines("./positive_test.txt")
negative_test = readLines("./negative_test.txt")

tweet = c(positive, negative)
tweet_test= c(positive_test, negative_test)
tweet_all = c(tweet, tweet_test)
sentiment = c(rep("positive", length(positive) ), 
              rep("negative", length(negative)))
sentiment_test = c(rep("positive", length(positive_test) ), 
                   rep("negative", length(negative_test)))
sentiment_all = as.factor(c(sentiment, sentiment_test))


# creation of matrix
mat= create_matrix(tweet_all, language="english", 
                   removeStopwords=TRUE, removeNumbers=TRUE, 
                   stemWords=FALSE, tm::weightTfIdf)

mat = as.matrix(mat)

#Training of naive bayes algorithm using K-Fold validation

classifier = naiveBayes(mat[1:300, ], as.factor(sentiment_all[1:300]))
predicted = predict(classifier, mat[300:400, ])

#tab -> table(predicted, sentiment_all)

#confusionMatrix(tab)
# Calculating the accuracy of naive Bayes
recall_accuracy(sentiment_test, predicted)