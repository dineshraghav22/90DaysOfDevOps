from flask import Flask, jsonify
import os
import redis
import psycopg2

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Hello from Flask!", "status": "ok"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
