from flask import Flask, Response
import requests

app = Flask(__name__)

@app.route('/stream')
def stream():
    # Forward the stream from your ESP32-CAM
    resp = requests.get('http://192.168.1.55:81/stream', stream=True)
    return Response(
        resp.iter_content(chunk_size=1024),
        content_type=resp.headers.get('Content-Type', 'application/octet-stream')
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050) 