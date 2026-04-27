"""
Small HTTP service for Assignment 1 — used as the app under CI/CD.
"""
from flask import Flask, jsonify

app = Flask(__name__)

APP_NAME = "assignment-1-cicd-demo"
VERSION = "1.0.0"


@app.route("/")
def index():
    return jsonify(
        {
            "service": APP_NAME,
            "version": VERSION,
            "message": "CI/CD pipeline demo: Jenkins, GitHub, Docker Hub",
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
