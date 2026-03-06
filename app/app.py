"""
Simple Flask web application for the GitOps pipeline demo.
"""
import os
from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
APP_ENV = os.environ.get("APP_ENV", "production")


@app.route("/")
def index():
    return jsonify({
        "message": "Hello from the GitOps pipeline!",
        "version": APP_VERSION,
        "environment": APP_ENV,
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
