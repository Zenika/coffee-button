import RPi.GPIO as GPIO
import time

RED = 18
GREEN = 12

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(GREEN,GPIO.OUT)
GPIO.setup(RED,GPIO.OUT)

for x in range(0, 10):
  GPIO.output(GREEN,GPIO.HIGH)
  time.sleep(.125)
  GPIO.output(GREEN,GPIO.LOW)
  GPIO.output(RED,GPIO.HIGH)
  time.sleep(.125)
  GPIO.output(RED,GPIO.LOW)
