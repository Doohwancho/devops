import requests
import time
import traceback

def performGetRequest(url):
  try:
    result = requests.get(url)
    if result.status_code == 200:
      print(result)
      print('.', end='', flush=True)
      time.sleep(1)
    else:
      print ("Request Failed")
      print(result)
      exit(1)
  except Exception as e:
      print("Something Went Wrong, Retry in 30 sec")
      print("Error:", str(e))
      traceback.print_exc()  # Print the stack trace
      time.sleep(30)

print ("Performing Load Testing")
print ("wait 30 seconds until springboot app launches")
time.sleep(30)

while (True):
  performGetRequest("http://demo-app:8080/countries")
  performGetRequest("http://demo-app:8080/country/US")
