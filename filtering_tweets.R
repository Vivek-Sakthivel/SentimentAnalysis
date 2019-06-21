#Fetch tweets for the required product
temporary.tweets = searchTwitter("Xiaomi", n=200)  

#To convert stored tweets into dataframe
df <- do.call("rbind", lapply(temporary.tweets, as.data.frame))

#To remove emoji, hyperlinks and irrelevant characters
df$text <- sapply(df$text,function(row) iconv(row, "latin1", "ASCII", sub="")) 
df$text = gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", df$text) 
sample <- df$text



