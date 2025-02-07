"""flask_bazel_sample service"""

from flask import Flask

# App
app = Flask(__name__)


@app.route("/")
def sample():
    """welcome API"""
    return "Welcome to Bazel built Flask!"


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
