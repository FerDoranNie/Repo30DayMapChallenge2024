####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################



import time
import numpy as np 

from selenium import webdriver
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import datetime
from dateutil.relativedelta import relativedelta


geckoDriver ='C:/Users/fernando.dorantes/local/web_scrapping_drivers/geckodriver-v0.35.0-win32/geckodriver.exe'
firefoxLocation = 'C:/Program Files/Mozilla Firefox/firefox.exe'

firefox_options = webdriver.FirefoxOptions()
firefox_options.set_preference("browser.download.folderList", 2)
firefox_options.set_preference("browser.download.dir", "C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Cutzamala_status_historical")  
firefox_options.set_preference("browser.helperApps.neverAsk.saveToDisk", "text/csv,application/vnd.ms-excel")  
firefox_options.binary_location = firefoxLocation


mainWebPage = 'https://sinav30.conagua.gob.mx:8080/Presas/'



listDates = []
today = datetime.date.today()
initialDate = datetime.date(2019, 2, 1)
while initialDate<= today:
    listDates.append(initialDate)
    initialDate += relativedelta(months=1)

for i in listDates:
    try:
        service = Service(geckoDriver)
        yearInput = i.year
        monthInput = i.month
        dayInput = i.day
        print(f'Date to be evaluated: {i}, {yearInput}, {monthInput}, {dayInput}')
        driver = webdriver.Firefox(service=service, options=firefox_options) 
        driver.get(mainWebPage)
        driver.execute_script("window.stop();")    
        time.sleep(3)
        # Insertar el mes
        month_field = driver.find_element(By.CSS_SELECTOR, ".react-date-picker__inputGroup__month")
        month_field.clear()
        month_field.send_keys(str(monthInput))  # Mes

        # Insertar el día
        day_field = driver.find_element(By.CSS_SELECTOR, ".react-date-picker__inputGroup__day")
        day_field.clear()
        day_field.send_keys(str(dayInput))  # Día

        # Insertar el año
        year_field = driver.find_element(By.CSS_SELECTOR, ".react-date-picker__inputGroup__year")
        year_field.clear()
        year_field.send_keys(str(yearInput))  # Año
        time.sleep(5)    
        actions = ActionChains(driver)

        # Enviar la tecla Escape globalmente
        actions.send_keys(Keys.ESCAPE).perform()
        #driver.find_element(By.CSS_SELECTOR, '.react-date-picker__calendar-button__icon').click()
        #driver.find_element(By.TAG_NAME , 'body').click()
        time.sleep(5)
        driver.find_element(By.TAG_NAME , 'body').click()
        driver.find_element(By.CSS_SELECTOR, '.react-date-picker__calendar-button__icon').click()
        driver.find_element(By.TAG_NAME , 'body').click()
        reportElement = driver.find_elements(By.XPATH, "//*[contains(text(), 'Reporte')]")
        reportElement[0].click()
        linkCsv = driver.find_element(By.CSS_SELECTOR, 'div.col-1:nth-child(3)')
        linkCsv.click()
        print(linkCsv.get_attribute("href"))
        driver.find_element(By.CSS_SELECTOR, '.btn-close').click()
        driver.quit()
        time.sleep(5)
    except Exception:
        break
