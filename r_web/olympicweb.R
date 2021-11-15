####### 올림픽공원 각 문 분포도 + 전체 차량수 예측 #######
#######            R shiny Web Project             #######
####### Producer. Jin Baek Lee, Ki Uk Kim          #######

# 경로 설정
setwd("C:\\Users\\KIUK\\Desktop\\map_workspace\\r_web")
setwd("C:/Users/KIUK/Desktop/공모전")
path ="C:\\Users\\KIUK\\Desktop\\공모전\\"
setRepositories(ind = 1:7)
# 필요 패키지 설치
#install.packages("ggmap")
# install.packages("shiny")

# ggmap 2.7 설치
# install.packages("devtools")
# devtools::install_github('dkahle/ggmap')

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
#구글 드라이브 연동
library("googledrive")
drive_auth()

# 구글 지도 API 인증키 등록
register_google(key = 'AIzaSyB0hz2PKlXN5hZGSQSf-s3zUxg-NgQ1bDA')

# 데이터 전처리 R script import
source("ayl (2).R", encoding = 'utf-8')
myReshape()
###################### 지도 좌표 ######################

# 남2문 lon = 127.12269175840116 con = 37.51434223590718
# 남3문 con, lon - 37.515826432931874, 127.11848071277946
# 남4문 con, lon - 37.51667795259269, 127.11614058425518
# 동2문 con, lon - 37.51588148167364, 127.13037185783178
# 서2문 con, lon - 37.51998850944507, 127.11447719937004
# 북2문 con, lon - 37.52356986500902, 127.12778052948829

map <- get_map(location=c(127.12081265253084, 37.52045297279662), 
        zoom = 15,
        size = c(1500,1000),
        maptype = 'roadmap') 

# 지도 깔끔하게 정리
my_theme <- theme(panel.background = element_blank(),
                  axis.title = element_blank(),
                  axis.text = element_blank(),
                  axis.ticks = element_blank(),
                  )

# 남2문
s2_point <- geom_point(aes(x=127.12269175840116, y=37.51434223590718),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2) + geom_text()


# 남3문
s3_point <- geom_point(aes(x=127.11848071277946, y=37.515826432931874),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2,)
# 남4문
s4_point <- geom_point(aes(x=127.11614058425518, y=37.51667795259269),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2)

# 동2문
e2_point <- geom_point(aes(x=127.13037185783178, y=37.51588148167364),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2)

# 서2문
w2_point <- geom_point(aes(x=127.11447719937004, y=37.51998850944507),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2)

# 북2문
n2_point <- geom_point(aes(x=127.12778052948829, y=37.52356986500902),
                       size = 7,
                       color = "#FF0000",
                       alpha = 0.2)

olympic_gate <- ggmap(map) + s2_point + s3_point + s4_point + e2_point + w2_point + n2_point
olympic_gate
# 웹 로그인 페이지
# credentials <- data.frame(
#   user = c("123", "shinymanager"),
#   password = c("123", "shinymanager"), stringsAsFactors = FALSE)

# 셀레니움 설정
Sys.setenv(JAVA_HOME = 'C:\\Program Files\\Java\\jre1.8.0_311\\')
driver <- rsDriver(port=1234L,chromever="95.0.4638.69")

# xpath 정보
# //*[@id="content_weather"]/table/tbody/tr[42]/td[6] # 기온
# //*[@id="content_weather"]/table/tbody/tr[42]/td[9] # 강수
# //*[@id="content_weather"]/table/tbody/tr[42]/td[10] # 적설
# //*[@id="content_weather"]/table/tbody/tr[42]/td[13] # 풍속
# //*[@id="observation_text"]
# /html/body/div/div[3]/div[2]/div[2]/div[2]/form/fieldset[1]/input[3] #월,별,시간
# 크롤링
crawling <- function()
{
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
}
view(we_csv)

#데이터 읽기
df <- read.csv("weather.csv", fileEncoding = "euc-kr")
ui_tmp <- df$tmp
ui_rain <- df$rain
ui_snow <- df$snow
ui_cloud <- df$cloud
ui_time <- df$癤퓍o_time

# 시간
to_date <- Sys.Date()
to_time <- format(Sys.time(), "%H:%M")
time <- paste(to_date, to_time)

cu_hour <- format(Sys.time(), "%H")
cu_hour <- as.numeric(cu_hour)

for (i in 1:3){
  if(ui_time[i] == cu_hour){
    print(ui_time[i])
  }
}

# ui.R
ui <- shinyUI(fluidPage(
  includeCSS("style.css"),
  sidebarLayout(
    sidebarPanel(
      titlePanel(
        h1(textOutput("to_time"))
      ),
    verticalLayout(
      wellPanel(
        h6("기온"),
        h4(textOutput("today_t"))
      ),
      wellPanel(
        h6("강수량"),
        h4(textOutput("today_r"))
      ),
      wellPanel(
        h6("적설량"),
        h4(textOutput("today_sn"))
      ),
      wellPanel(
        h6("풍속"),
        h4(textOutput("today_cl"))
      )
    )
    ),
    mainPanel(
      plotlyOutput("map", width = "100%", height = "100%") 
    )
  )
))
# ui <- secure_app(ui)

## server.R
server <- shinyServer(function(input, output){
  autoInvalidate <- reactiveTimer()
  
  output$map <- renderPlotly({
    plot <- ggmap(map, extent="device") + s2_point + s3_point + s4_point + e2_point + w2_point + n2_point
  })

  cu_hour <- format(Sys.time(), "%H")
  cu_hour <- as.numeric(cu_hour)
  
  output$today_t <- renderPrint({
      tt <- df$tmp
      cat(temp2)
  })
  
  output$today_r <- renderPrint({
      rr <- df$rain
      cat(rr)
  })
  
  output$today_sn <- renderPrint({
      sn <- df$sn
      cat(sn)
  })
  
  output$today_cl <- renderPrint({
    cl <- df$wind_speed
    cat(cl)
  })
  
  
  
  # 실시간 시간 처리(2초마다 갱신)
  autoInvalidate <- reactiveTimer(2 * 1000)
  
  observe({
    autoInvalidate()
  })
  
  output$to_time <- renderText({
    autoInvalidate()
    current_timer <- paste0("현재 " , Sys.Date(), " ", format(Sys.time(), "%H:%M"))
  })
})

shinyApp(ui = ui, server = server)


