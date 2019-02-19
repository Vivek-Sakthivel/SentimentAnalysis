library(twitteR)
library(ROAuth)

consumer_key <- "qrwb4S7Emnl7Ic9aTBh3wHbQN"
consumer_secret_key <- "vGYBtFi3kG8jX4e9DFT7vNBN0QXt7gNZy5rFtUT9maqCf7ELo7"
access_token <- "1248849116-pcnlJzKpJbCyTn28wshlXpAmdiQl4WnsJcqCCXK"
access_token_secret <- "IHJwpSewJO7tJLwte10DQhReeo6DFdC4CfvW0aRXk8Xza"

download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem") #downloads the certificate

setup_twitter_oauth(consumer_key, consumer_secret_key, access_token, access_token_secret)

cred <- OAuthFactory$new(consumerKey=consumer_key, 
                         consumerSecret=consumer_secret_key,
                         requestURL='https://api.twitter.com/oauth/request_token',
                         accessURL='https://api.twitter.com/oauth/access_token',
                         authURL='https://api.twitter.com/oauth/authorize')

cred$handshake(cainfo="cacert.pem")
#After this you are redirected to a URL automatically, click on Authorize App and enter the PIN generated there