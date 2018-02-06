liblibrary(DBI)
library(RMariaDB)
library(dplyr)
library(ggplot2)


mydb <- dbConnect(RMariaDB::MariaDB(), username='user', password='password', dbname='environmentdata', host='dbhost')

#dbListTables(mydb)

res <- dbGetQuery(mydb, "select * from sensordata where sensorname like 'Sensor2'")
#res <- dbSendQuery(mydb, "select * from sensordata where sensorname like 'Sensor2'")

#data = fetch(res, n=-1)

#while(!dbHasCompleted(res)){
#  chunk <- dbFetch(res, n = 50)
#  #print(nrow(chunk))
#  print(chunk)
#  }

ggplot(data=res,aes(x=recorded_at,y=temperature,group=1)) +
  geom_line() +
  geom_point() +
  expand_limits(y=0) +
  xlab("Time of day") + ylab("% Humidity") +
  ggtitle("Average humiditlibrary(DBI)

summary(res)
qplot(data$humidity)


envdb <- tbl(mydb,"sensordata")

envdb %>% select(sensorname,mean(temperature) )


