import cv2
import threading
import time

class ESP32StreamBuffer:
    def __init__(self, stream_url):
        self.stream_url = stream_url
        self.frame = None
        self.running = False
        self._lock = threading.Lock()

    def start(self):
        if self.running:
            return
        self.running = True
        threading.Thread(target=self._read_loop, daemon=True).start()

    def _read_loop(self):
        cap = cv2.VideoCapture(self.stream_url)
        print(self.stream_url)
        if not cap.isOpened():
            print(f"[ERROR] Failed to open stream: {self.stream_url}")
            self.running = False
            return

        while self.running:
            ret, frame = cap.read()
            if ret:
                with self._lock:
                    self.frame = frame
            else:
                print("[WARNING] Failed to read frame, retrying in 0.5s")
                with self._lock:
                    self.frame = None
                time.sleep(0.5)
        cap.release()

    def stop(self):
        self.running = False

    def restart(self):
        self.stop()
        time.sleep(1)
        self.start()

    def get_latest_frame(self):
        with self._lock:
            return self.frame.copy() if self.frame is not None else None
