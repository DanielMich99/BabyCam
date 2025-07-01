import cv2
import threading
import time

class ESP32StreamBuffer:
    def __init__(self, stream_url):
        self.stream_url = stream_url  # URL to the ESP32-CAM stream
        self.frame = None  # Last successfully read frame
        self.running = False  # Indicates whether the reading loop is active
        self._lock = threading.Lock()  # Lock to ensure thread-safe access to the frame

    def start(self):
        """Starts the background thread that reads frames from the stream."""
        if self.running:
            return
        self.running = True
        threading.Thread(target=self._read_loop, daemon=True).start()

    def _read_loop(self):
        """Continuously reads frames from the ESP32 stream into memory."""
        cap = cv2.VideoCapture(self.stream_url)
        print(self.stream_url)
        if not cap.isOpened():
            print(f"[ERROR] Failed to open stream: {self.stream_url}")
            self.running = False
            return

        while self.running:
            ret, frame = cap.read()
            if ret:
                # Update the latest frame with a lock for thread safety
                with self._lock:
                    self.frame = frame
            else:
                print("[WARNING] Failed to read frame, retrying in 0.5s")
                with self._lock:
                    self.frame = None
                time.sleep(0.5)

        # Clean up when stopping
        cap.release()

    def stop(self):
        """Stops the reading loop."""
        self.running = False

    def restart(self):
        """Stops and restarts the stream reading thread."""
        self.stop()
        time.sleep(1)
        self.start()

    def get_latest_frame(self):
        """Returns the most recent frame (thread-safe copy)."""
        with self._lock:
            return self.frame.copy() if self.frame is not None else None
