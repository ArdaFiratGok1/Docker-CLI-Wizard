import os
from flask import Flask

app = Flask(__name__)

# Ortam değişkeninden mesajı oku, eğer yoksa varsayılan bir mesaj kullan
greeting_message = os.getenv('GREETING_MESSAGE', 'Merhaba Docker!')

@app.route('/')
def hello():
    return f'<h1>{greeting_message}</h1>'

if __name__ == '__main__':
    # Container içinde çalışması için host='0.0.0.0' ve port=5000 olmalı
    app.run(host='0.0.0.0', port=5000)
