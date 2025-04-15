import os
import json
import time
import random
import logging
import mysql.connector
from flask import Flask, jsonify
from prometheus_client import start_http_server, Counter, Histogram, Gauge

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)

# Define Prometheus metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total app HTTP requests')
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency in seconds')
DB_CONNECTION_GAUGE = Gauge('app_db_connections', 'Database connection status (1=connected, 0=disconnected)')

# Function to get database credentials from AWS Secrets Manager
def get_db_credentials():
    # In production, this would use boto3 to get secrets from AWS Secrets Manager
    # For local development, we'll use environment variables
    return {
        'host': os.environ.get('DB_HOST', 'localhost'),
        'user': os.environ.get('DB_USER', 'admin'),
        'password': os.environ.get('DB_PASSWORD', 'password'),
        'database': os.environ.get('DB_NAME', 'hellodb')
    }

# Function to connect to the database
def get_db_connection():
    try:
        credentials = get_db_credentials()
        conn = mysql.connector.connect(
            host=credentials['host'],
            user=credentials['user'],
            password=credentials['password'],
            database=credentials['database']
        )
        DB_CONNECTION_GAUGE.set(1)  # Connected
        return conn
    except Exception as e:
        logger.error(f"Database connection error: {e}")
        DB_CONNECTION_GAUGE.set(0)  # Disconnected
        return None

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/')
@REQUEST_LATENCY.time()
def hello_world():
    REQUEST_COUNT.inc()
    
    # Simulate some processing time
    time.sleep(random.uniform(0.05, 0.2))
    
    # Try to connect to the database
    conn = get_db_connection()
    db_status = "connected" if conn else "disconnected"
    
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT NOW()")
            db_time = cursor.fetchone()[0]
            cursor.close()
            conn.close()
        except Exception as e:
            logger.error(f"Database query error: {e}")
            db_time = "Error querying database"
    else:
        db_time = "No database connection"
    
    return jsonify({
        "message": "Hello, World!",
        "database_status": db_status,
        "database_time": str(db_time) if db_status == "connected" else db_time
    })

if __name__ == '__main__':
    # Start Prometheus metrics endpoint on port 8000
    start_http_server(8000)
    # Start Flask app on port 5000
    app.run(host='0.0.0.0', port=5000)
