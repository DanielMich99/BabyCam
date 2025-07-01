import cv2
from flask import Flask, Response

app = Flask(__name__)

def generate():
    cap = cv2.VideoCapture(0)  # מצלמת מחשב או קובץ וידאו
    while True:
        success, frame = cap.read()
        if not success:
            break
        _, buffer = cv2.imencode('.jpg', frame)
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

@app.route('/stream')
def video_feed():
    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

app.run(host="0.0.0.0", port=8081)