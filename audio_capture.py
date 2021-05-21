from datetime import datetime
import paho.mqtt.client as paho
import wav_writer

broker="localhost"  #host name
topic_mic="mic" #topic name
port=1883 #MQTT data listening port
# ACCESS_TOKEN='M7OFDCmemyKoi461BJ4j' #not manditory

receiving = True
is_connected = False

audio = wav_writer.WavWriter()
audio.set_attributes(16000, 2, 2)

def version():
    return '4.' + str(audio.version())

def cb_save_audio_file(client, userdata, message):
    if not audio.is_finished():
        audio.append_bytes(message.payload)
    else:
        # print('Recording finished!')
        client.unsubscribe(message.topic)
        global receiving
        receiving = False

def on_connect(client, userdata, flags, rc):
    # print(client, "connected")
    global receiving
    receiving = True

def on_disconnect(client, userdata, rc):
    # print(client, "disconnected")
    global receiving
    receiving = False

def on_subscribe(client, userdata, mid, granted_qos):
    # print(client, "subscribed")
    pass

def on_unsubscribe(client, userdata, mid):
    # print(client, "unsubscribed")
    pass

def on_message(client, userdata, message):
    # print("received :", message.topic, str(message.payload)) #printing Received message
    pass
    
def record(seconds):
    global receiving
    receiving = True
    client= paho.Client("receiver") #create client object 
    client.on_message = on_message
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_subscribe = on_subscribe
    client.on_unsubscribe = on_unsubscribe
    
    # print("connecting to broker host",broker)
    client.connect(broker, port, keepalive=60)#connection establishment with broker

    # print("subscribing begins here")    
    client.subscribe(topic_mic, 1)#subscribe topic test

    audio.start_recording(seconds)
    client.message_callback_add(topic_mic, cb_save_audio_file)
    client.loop_start()

    while (receiving and audio.status != wav_writer.STATUS_TIMEOUT):
        pass 
    client.loop_stop()
    audio.stop_recording()
    return [audio.status, audio.filename]

# print(record(2))
# print(record(3))
# print('end')