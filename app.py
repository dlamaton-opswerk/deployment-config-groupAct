from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return {"VERSION": "1.0.0"}

if __name__ == '__main__':
    # Bind to 0.0.0.0 so it is accessible outside the container
    app.run(host='0.0.0.0', port=5000)
