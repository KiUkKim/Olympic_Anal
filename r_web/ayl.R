library(tidyr)
library(dplyr)
library(data.table)
library(stringr)
library(reshape)

setRepositories(ind = 1:7)

#path="C:\\Users\\Administrator\\Google Drive(baekpower98@gmail.com)\\Compitition\\2021체육종합데이터활용경진대회\\data\\"
path ="H:\\내 드라이브\\Compitition\\2021체육종합데이터활용경진대회\\data\\"
path ="C:\\Users\\KIUK\\Desktop\\map_workspace\\공모전 데이터"

## 메인 데이터 "올림픽 공원 유동 차량 정보" 

myReshape <- function(data){
  data <- data %>% 
    mutate_all(as.character)
  
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

Jan <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(1월).csv"),encoding="UTF-8"))
Feb <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(2월).csv"),encoding="UTF-8"))
March <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(3월).csv"),encoding="UTF-8"))
Apr <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(4월).csv"),encoding="UTF-8"))
May <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(5월).csv"),encoding="UTF-8"))
June <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(6월).csv"),encoding="UTF-8"))
July <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(7월).csv"),encoding="UTF-8"))
Aug <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(8월).csv"),encoding="UTF-8"))
Sep <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(9월).csv"),encoding="UTF-8"))
Oct <- myReshape(fread(paste0(path,"올림픽공원 주차장 이용현황(10월).csv"),encoding="UTF-8"))

datalist <- list(Jan,Feb,March,Apr,May,June,July,Aug,Sep,Oct)
total <- Reduce(function(x,y) merge(x,y,all=TRUE),datalist)
total[is.na(total)] <- 0
View(total)

#==========================================================================================================

## 환경 변수 전처리 (기상 데이터)
env<- fread(paste0(path,"OBS_ASOS_TIM_20211110172352.csv"))
env[is.na(env)] <- 0
env <- env%>% 
  separate(col = 일시,sep=" |:",into = c("TRANSDATE","time",NA)) 
env <- env[,c(3,4,5,6,7,8,9,10)]

env <- env %>%
  mutate(time=as.numeric(time))

total <- merge(total,env,by=c("TRANSDATE","time"),all.x = TRUE)
#==========================================================================================================

## New column "시간대 별 올림픽공원 내 차량 수"
total <- total %>%
  mutate(allGATE=(In남2+In남3+In남4+In동2+In북2+In서2)-(Out남2+Out남3+Out남4+Out동2+Out북2+Out서2))

cum <- c()
for(i in 1:dim(total)[1]){
  if(i==1){
    cum <- append(cum,total$allGATE[i])
  }else{
    cum <- append(cum,cum[i-1]+total$allGATE[i])
  }
}

total <- cbind(total,cumulative=cum)

## New column "주말 여부"
weekn <- c()
for(i in 1:dim(total)[1]){
  if(weekdays(as.Date(total$TRANSDATE))[i] %in% c("월요일","화요일","수요일","목요일","금요일")){
    weekn <- append(weekn,"N")
  }
  else{
    weekn <- append(weekn,"Y")
  }
}

total <- cbind(total,weekn=as.factor(weekn))

# 1.다음으로 이벤트 컬럼도 넣고 환경 변수들로 cumulative 회귀분석 돌리기 
# 2.각 문마다의 혼잡도 컬럼도 만들어서 사람들이 시간에 따라 어느 문을 이용을 많이 하는지 각 문/전체 로 비중 구하기
# (사실상 기상 데이터가 각 문의 혼잡도에 영향을 안준다는 가정. 단 기상에 따라 올림픽 공원 내에서 목적지가 달라진다면 문의 혼잡도도 바뀔 것)
# 결국 1에서 나온 예측 사람 수를 기반으로 비중의 가중치에 따라 어디로 많이 들어올 것인가를 계산해서 웹에 띄워주기 


