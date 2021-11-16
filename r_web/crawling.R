####### 올림픽공원 각 문 분포도 + 전체 차량수 예측 #######
#######            R shiny Web Project             #######
####### Producer. Jin Baek Lee, Ki Uk Kim          #######
#######              크롤링 파일                   #######

setwd("C:/Users/KIUK/Desktop/공모전")
getwd()
# 필요한 패키지 다운로드
library(shiny)
library(ggmap)
library(ggplot2)
library(tidyr)
library(tidyverse) # 시간 가공
library('lubridate') #시간 관련
library(dplyr)
library(data.table)
library(stringr)
library(reshape)
library(plotly)
library(lubridate)

##셀레니움 패키지
library("RSelenium")
library("rJava")
library("XML")
library("rvest")

# 셀레니움 설정
Sys.setenv(JAVA_HOME = 'C:\\Program Files\\Java\\jre1.8.0_311\\')
driver <- rsDriver(port=4421L,chromever="95.0.4638.69")

remDR<- driver$client
remDR$open()
url <- ("https://www.kma.go.kr/weather/observation/currentweather.jsp")
remDR$navigate(url)

# 기온 크롤링
tpr <- remDR$findElement(using = "xpath", value = '//*[@id="content_weather"]/table/tbody/tr[42]/td[6]')
tpr <- tpr$getElementText()
tpr <- unlist(tpr)

# 강수
rain <- remDR$findElement(using = "xpath", value = '//*[@id="content_weather"]/table/tbody/tr[42]/td[9]')
rain <- rain$getElementText()
rain <- unlist(rain)

# 적설
sn <- remDR$findElement(using = "xpath", value = '//*[@id="content_weather"]/table/tbody/tr[42]/td[10]')
sn <- sn$getElementText()
sn <- unlist(sn)

# 풍속
ws <- remDR$findElement(using = "xpath", value = '//*[@id="content_weather"]/table/tbody/tr[42]/td[13]')
ws <- ws$getElementText()
ws <- unlist(ws)

# 날짜 시간
rt <- remDR$findElement(using = "class", value = 'table_topinfo')
rt <- rt$getElementText()

rt <- gsub("기상실황표", "", rt)
rt <- lubridate::hour(ymd_hm(rt))

rain <- as.numeric(str_replace(rain, " " , '0'))
sn <- as.numeric(str_replace(sn, " ", '0'))

# 행사 일정 크롤링
remDR_event<- driver$client
remDR_event$open()
url_event <- ("https://olympicpark.kspo.or.kr:441/jsp/homepage/contents/culture/schedule_dselect_action.do#today")
remDR_event$navigate(url_event)

event_bt <- remDR_event$findElement(using = 'xpath', value = '//*[@id="board"]/div/fieldset/ul/li[1]/div/p[2]/a[1]/img')
remDR_event$mouseMoveToLocation(webElement = event_bt)
remDR_event$click(buttonId = 'LEFT')

event_date <- remDR_event$findElement(using = 'xpath', value = '//*[@id="spanYmd"]')
event_date <- event_date$getElementText()

event_name <- remDR_event$findElement(using = 'xpath', value = '//*[@id="listBody"]/tr/td[1]/dl/dt/a')
event_name <- event_name$getElementText()
event_name <- unlist(event_name)

event_cnt <- length(event_name)

we_csv <- data.frame(Time=rt, tmp = tpr,rain = rain, sn = sn, wind_speed = ws, count = event_cnt)
write.csv(we_csv, "weather.csv", row.names = FALSE)