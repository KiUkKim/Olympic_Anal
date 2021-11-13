# 라이브러리 사용
from selenium.webdriver.chrome import options
import pyautogui # 화면 자동클릭을 위한 라이브러리
from selenium import webdriver
from selenium.webdriver.chrome.options import Options # 전체화면으로 창 띄우기
import time

options = Options()
# 다운로드 경로 설정
prefs = {'download.default_directory': 'C:\\Users\\KIUK\\Desktop\\공모전'}
# chrome에서 전체화면으로 창 띄워주기
options.add_argument('--start-maximized')
options.add_experimental_option('prefs', prefs)

# selenium에서 사용할 웹 드라이버 절대 경로 정보
# 웹사이트 연결 정보
chromedriver = 'C:\\Users\\KIUK\\Desktop\\map_workspace\\python_crawling\\chromedriver.exe'
url_login = 'https://www.bigdata-culture.kr/bigdata/user/member/login.do'
url_datashop = 'https://www.bigdata-culture.kr/bigdata/user/data_market/detail.do?id=a2d6393d-246e-439b-8bfb-c25204e808fb'
url_cart = 'https://www.bigdata-culture.kr/bigdata/user/mypage/mydata/cert.do'
url_history = 'https://www.bigdata-culture.kr/bigdata/user/mypage/mydata/history.do'

# selenum의 webdriver에 앞서 설치한 chromedirver를 연동한다.
driver = webdriver.Chrome(chromedriver, chrome_options=options)

#driver로 특정 페이지로 접속
driver.get('https://www.bigdata-culture.kr/bigdata/user/member/login.do')

# 대기시간 부여
driver.implicitly_wait(3)

driver.find_element_by_id('loginId').send_keys('zidh249')
driver.find_element_by_id('loginPw').send_keys('rose@8342')
driver.find_element_by_id('loginBtn').click()

time.sleep(2)
driver.implicitly_wait(3)

driver.get(url_datashop)

driver.implicitly_wait(3)
# 웹사이트 이동
driver.get(url_datashop)

# 해당 디스트리뷰션으로 스크롤 내림
driver.execute_script("window.scrollTo(0, 1400)")

driver.implicitly_wait(3)

# 디스트리뷰션 선택
pyautogui.moveTo(380, 546, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

# 장바구니 버튼 선택
pyautogui.moveTo(2126, 374, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

# 장바구니 확인 버튼
pyautogui.moveTo(1448, 253, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

# 장바구니창으로 이동
driver.get(url_cart)
driver.implicitly_wait(3)

# 결제하기 창
pyautogui.moveTo(376, 1087, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

# 결제하기
pyautogui.moveTo(1263, 1493, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
time.sleep(1)
driver.implicitly_wait(3)

# 해당 디스트리뷰션으로 스크롤 내림
driver.execute_script("window.scrollTo(0, 700)")

pyautogui.moveTo(331, 513, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

pyautogui.moveTo(336, 617, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

pyautogui.moveTo(332, 973, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

pyautogui.moveTo(1275, 1114, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

pyautogui.moveTo(1432, 241, 1) # 절대 좌표로 1초 동안 이동
pyautogui.click()
driver.implicitly_wait(3)

# 결제 내역으로 이동
driver.get(url_history)
driver.implicitly_wait(3)

# csv 파일 저장
# 저장된 결제 내역 중 마지막 버튼 클릭 (가장 최근 업데이트 된 데이터)
driver.find_element_by_xpath('html/body/div[2]/form[1]/div/div/div/div[3]/div[2]/div/ul/li[last()]/div[1]').click()
time.sleep(1)

driver.find_element_by_xpath('html/body/div[2]/form[1]/div/div/div/div[3]/div[2]/div/ul/li[last()]/div[9]/a').click()
driver.implicitly_wait(3)

# 데이터 활용목적 클릭창
pyautogui.moveTo(962, 893, 1)
pyautogui.click()
driver.implicitly_wait(3)

pyautogui.moveTo(1280, 1055, 1)
pyautogui.click()
driver.implicitly_wait(3)