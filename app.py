from flask import Flask, request, jsonify, render_template, send_file
import qrcode
import io

app = Flask(__name__)

# Store session IDs and their corresponding authentication status
sessions = {}

# Sample home page
@app.route('/')
def home():
    return render_template('home.html')

# Route to receive scanned QR code data
@app.route('/receive_qr_data', methods=['POST'])
def receive_qr_data():
    data = request.json
    session_id = data.get('session_id')
    sessions[session_id] = False  # Mark session as not authenticated
    return jsonify({'success': True})

# Route to update authentication status
@app.route('/update_authentication_status', methods=['POST'])
def update_authentication_status():
    if request.method == 'POST':
        # Check if the request contains authentication data
        data = request.json
        authenticated = data.get('authenticated')
        if authenticated is not None:
            # Assuming you have some logic to determine the session ID
            session_id = "123"
            sessions[session_id] = authenticated
            app.logger.debug("Successfully updated authentication status")
            return render_template('status.html', message="Successfully logged in")
    return jsonify({'error': 'Invalid request'}), 400

# Route to generate and display a QR code
@app.route('/generate_qr')
def generate_qr():
    # Generate the URL to be encoded in the QR code
    url = f'http://{request.host}/receive_qr_data'
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)

    img = qr.make_image(fill='black', back_color='white')
    buffer = io.BytesIO()
    img.save(buffer, 'PNG')
    buffer.seek(0)

    return send_file(buffer, mimetype='image/png')

# Route to serve the QR code HTML page
@app.route('/qr_code')
def qr_code():
    return render_template('qr_code.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
