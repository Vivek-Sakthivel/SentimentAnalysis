library(twitteR)
library(ROAuth)

#The twitter_authentication_and_handshake. R is used to establish connection with twitter application.
#Initially an application was created using the dev.twitter.com for performing the sentiment analysis and the credentials to access the twitter are extracted from the app. 
#Thus the extracted keys and token are used in the handshake and authentication process. 

consumer_key <- "qrwb4S7Emnl7Ic9aTBh3wHbQN"
consumer_secret_key <- "vGYBtFi3kG8jX4e9DFT7vNBN0QXt7gNZy5rFtUT9maqCf7ELo7"
access_token <- "1248849116-pcnlJzKpJbCyTn28wshlXpAmdiQl4WnsJcqCCXK"
access_token_secret <- "IHJwpSewJO7tJLwte10DQhReeo6DFdC4CfvW0aRXk8Xza"

#downloads the certificate cacert.pem file used during SSL handshake 
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem") #downloads the certificate

#Authentication of twitter application is done 
setup_twitter_oauth(consumer_key, consumer_secret_key, access_token, access_token_secret)

cred <- OAuthFactory$new(consumerKey=consumer_key, 
                         consumerSecret=consumer_secret_key,
                         requestURL='https://api.twitter.com/oauth/request_token',
                         accessURL='https://api.twitter.com/oauth/access_token',
                         authURL='https://api.twitter.com/oauth/authorize')

# The credentials extracted and the cart.pem certificate is used for twitter handshake
cred$handshake(cainfo="cacert.pem")
#After this you are redirected to a URL automatically, click on Authorize App and enter the PIN generated there
