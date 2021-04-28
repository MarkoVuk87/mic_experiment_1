import paho.mqtt.client as paho
import time
import sys
import threading
import datetime
import time
import csv
import re
import wave

line = 'Q: Do I write ;/.??? No!!!'

re.sub('\[|\]|\"', '', line)
'QDoIwriteNo'

test_audio_fn = "test.wav"

broker="localhost"  #host name
topic_1="rfid_event" #topic name
topic_2="temperature" #topic name
topic_time="timestamp" #topic name
topic_mic="mic" #topic name
port=1883 #MQTT data listening port
# ACCESS_TOKEN='M7OFDCmemyKoi461BJ4j' #not manditory

audiobytes = bytearray()
cnt = int(0)

from datetime import datetime
# mic_save = list()

# flag_connected = 0

def on_connect(client, userdata, flags, rc):
  #  global flag_connected
  #  flag_connected = 1
  print(client, "connected")

def on_disconnect(client, userdata, rc):
  #  global flag_connected
  #  flag_connected = 0
  print(client, "disconnected")

def receiving():
  while 1:
    client.loop_start() #contineously checking for message 

def on_publish(client,userdata,result): #create function for callback
  print("published timestamp : ")
  pass

def clean_message(message):
  clean_msg = re.sub('\[|\]|\"', '', message.payload.decode("utf-8"))
  str_list = list(clean_msg.split(","))
  str_list.insert(0, message.topic)
  str_list[1] = datetime.fromtimestamp(float(str_list[1]))
  return str_list

def on_message(client, userdata, message):
  if message.topic in (topic_1, topic_2):
    str_list = clean_message(message)
    with open('results.csv', 'a', newline='') as csvfile:
      spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
      spamwriter.writerow(str_list)
  else:
    audiobytes.extend(message.payload)
    global cnt
    if cnt == 20:
      with wave.open(test_audio_fn, 'wb') as audiofile:
        audiofile.setnchannels(2)
        audiofile.setsampwidth(2)
        audiofile.setframerate(4000)
        audiofile.writeframesraw(audiobytes)
        cnt = 0
        print("end")
        quit()
        while (1):
          time.sleep(10000)
    cnt += 1
    print (cnt)
  # print("received :", message.topic, str(message.payload)) #printing Received message
  print("new message")
    
client= paho.Client("receiver") #create client object 
client.on_message = on_message
client.on_connect = on_connect
client.on_disconnect = on_disconnect
   
print("connecting to broker host",broker)
client.connect(broker, port, keepalive=1200)#connection establishment with broker
print("subscribing begins here")    
client.subscribe(topic_1, 1)#subscribe topic test
client.subscribe(topic_2, 1)#subscribe topic test
client.subscribe(topic_mic)#subscribe topic test

client.loop_start()
# rec_thread = threading.Thread(target=receiving)
# rec_thread.start()

client1= paho.Client("control1") #create client object
client1.on_publish = on_publish #assign function to callback
# # client1.username_pw_set(ACCESS_TOKEN) #access token from thingsboard device
client1.connect(broker, port, keepalive=60) #establishing connection

# #publishing after every 5 secs
i = 0
while i < 120:
  # payload=int(datetime.timestamp(datetime.now()) // 1)
  # ret= client1.publish(topic_time,payload) #topic name is test
  # print(payload)
  time.sleep(5)
  i += 1
  # file.close
  # file = open('test.csv','a')

time.sleep(120)
client.loop_stop(force=False)
time.sleep(5)

# while 1:
#     time.sleep(10000)