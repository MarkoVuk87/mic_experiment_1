import os
from datetime import datetime
from time import sleep
import wave
import threading

STATUS_READY = 0
STATUS_ERROR = -1
STATUS_RECORDING = 1
STATUS_SAVED = 2
STATUS_TIMEOUT = -2

class WavWriter:

    def __init__(self):
        self.audiobytes = bytearray()
        self.status = STATUS_READY
        self.bytes_to_collect = 0  

    def version(self):
        return 1

    def start_timer(self):
        self.start_time = datetime.now()
        self.timer_thread = threading.Thread(target=self.timer_loop)
        self.timer_thread.start()

    def timer_loop(self):
        while True:
            if (self.status == STATUS_SAVED):
                break
            timedelta = datetime.now() - self.start_time
            if (timedelta.seconds < 10) and (self.status != STATUS_RECORDING):
                sleep(1)  
            else:
                if (self.status == STATUS_RECORDING):
                    self.start_time = datetime.now()
                else:
                    self.status = STATUS_TIMEOUT
                    break

    def set_attributes(self, sample_rate, sample_width_byte, channels):
        self.sample_rate = sample_rate
        self.channels = channels
        self.sample_width_byte = sample_width_byte

    def start_recording(self, seconds):
        self.status = STATUS_READY
        # make filename
        self.filename = 'rec_' + str(int(self.sample_rate/1000)) + 'k_' + '{:%Y-%m-%d_%H-%M-%S}'.format(datetime.now()) + '.wav'
        bytes_per_sample = self.channels * self.sample_width_byte
        self.bytes_to_collect = seconds * self.sample_rate * bytes_per_sample
        self.start_timer()
    
    def stop_recording(self):
        self.bytes_to_collect = 0    
        self.timer_thread.join()  
        self.audiobytes.clear()  
        if self.status != STATUS_SAVED:
            os.remove(self.filename)             

    def append_bytes(self, bytes_to_append):
        self.audiobytes.extend(bytes_to_append)
        self.status = STATUS_RECORDING
        if len(self.audiobytes) >= self.bytes_to_collect:
            with wave.open(self.filename, 'wb') as audiofile:
                audiofile.setnchannels(self.channels)
                audiofile.setsampwidth(self.sample_width_byte)
                audiofile.setframerate(self.sample_rate)
                audiofile.writeframesraw(self.audiobytes)
            # print('File saved as ' + self.filename)    
            self.audiobytes.clear()
            self.status = STATUS_SAVED
    
    def is_finished(self):
        if self.status == STATUS_SAVED:
            return True
        return False

# writer = WavWriter()
# writer.set_attributes(4000, 16, 2)
# writer.start_recording()
# print(writer.filename)