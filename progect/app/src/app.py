from flask import Flask, jsonify
import os
import mysql.connector

app = Flask(__name__)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'app_user'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'app_db')
}

@app.route('/')
def health():
    return jsonify({'service':'yc-final-project','status':'ok','version':'1.0.0'}), 200

@app.route('/db')
def db_check():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({'status':'connected','mysql_version':version}), 200
    except Exception as e:
        return jsonify({'status':'error','message':str(e)}), 500

@app.route('/api/data')
def get_data():
    return jsonify({'message':'Я был тут!','db_host':DB_CONFIG['host']}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
