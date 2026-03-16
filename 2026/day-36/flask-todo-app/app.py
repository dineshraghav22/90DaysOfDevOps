from flask import Flask, jsonify, request
import os

app = Flask(__name__)

tasks = []
task_id = 1

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "todo-api"})

@app.route('/tasks', methods=['GET'])
def get_tasks():
    return jsonify(tasks)

@app.route('/tasks', methods=['POST'])
def add_task():
    global task_id
    data = request.get_json()
    task = {"id": task_id, "title": data.get("title", ""), "done": False}
    tasks.append(task)
    task_id += 1
    return jsonify(task), 201

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
