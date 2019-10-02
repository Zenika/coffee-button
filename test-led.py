import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18,GPIO.OUT)
GPIO.setup(12,GPIO.OUT)
print "Red LED on"
GPIO.output(18,GPIO.HIGH)

time.sleep(1)
print "Green LED on"
print "Red LED off"
GPIO.output(18,GPIO.LOW)
GPIO.output(12,GPIO.HIGH)
time.sleep(1)
print "Green LED off"
GPIO.output(12,GPIO.LOW)
