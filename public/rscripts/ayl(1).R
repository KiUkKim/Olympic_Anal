library(tidyr)
library(dplyr)
library(data.table)
library(stringr)
library(reshape)

#path="C:\\Users\\Administrator\\Google Drive(baekpower98@gmail.com)\\Compitition\\2021체육종합데이터활용경진대회\\data\\"
path ="C:\\Users\\KIUK\\Desktop\\map_workspace\\공모전 데이터\\"
June<-fread(paste0(path,"올림픽공원 주차장 이용현황(6월).csv"),encoding="UTF-8")
July<-fread(paste0(path,"올림픽공원 주차장 이용현황(7월).csv"),encoding="UTF-8")
Aug<-fread(paste0(path,"올림픽공원 주차장 이용현황(8월).csv"),encoding="UTF-8")
Oct<-fread(paste0(path,"올림픽공원 주차장 이용현황(10월).csv"),encoding="UTF-8")


myReshape <- function(data){
  data <- data %>% 
    mutate_all(as.character)
  
  data$TRANSDATE <-str_remove_all(data$TRANSDATE,"-")
  data <- data[!is.na(data$OUTDATE),]
  
  data <- data%>% 
    separate(col = INDATE,sep=" |-|:",into = c("In_year","In_month","In_day","In_time","In_minute","In_second")) %>%
    separate(col = OUTDATE, sep=" |-|:",into = c("Out_year","Out_month","Out_day","Out_time","Out_minute","Out_second"))
  
  data <- data %>% 
    mutate(
      INGATE = paste0("In",INGATE),
      OUTGATE =paste0("Out",OUTGATE),
      In_time = as.integer(In_time),
      Out_time = as.integer(Out_time),
      INGATE = as.factor(INGATE),
      OUTGATE = as.factor(OUTGATE)
    )
  
  in_data <- data%>%
    select(c(TRANSDATE,In_time,INGATE))
  
  out_data <- data %>%
    select(c(TRANSDATE,Out_time,OUTGATE))
  
  in_data<-in_data%>%
    group_by(TRANSDATE,In_time,INGATE)%>%
    summarise(count=n())
  
  out_data<-out_data%>%
    group_by(TRANSDATE,Out_time,OUTGATE)%>%
    summarise(count=n())
  
  in_data<-cast(data=in_data,TRANSDATE+In_time~INGATE,fun=sum)
  out_data<-cast(data=out_data,TRANSDATE+Out_time~OUTGATE,fun=sum)
  
  colnames(in_data)[2] <- "time"
  colnames(out_data)[2] <- "time"
  
  data<-merge(in_data,out_data,by=c("TRANSDATE","time"),all = TRUE)
  data[is.na(data)] <- 0
  
  return(data)
}

June <- myReshape(June)
July <- myReshape(July)
Aug <- myReshape(Aug)
Oct <- myReshape(Oct)

datalist <- list(June,July,Aug,Oct)
total <- Reduce(function(x,y) merge(x,y,all=TRUE),datalist)
