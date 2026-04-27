from flask import Flask, jsonify

app = Flask(__name__)

APP_NAME = "sc-assignment1-api"
VERSION = "1.0.0"


@app.route("/")
def index():
    return jsonify(
        {
            "service": APP_NAME,
            "version": VERSION,
            "message": "Software Construction — Assignment 1 (Flask, Jenkins, Docker)",
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
