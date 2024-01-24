from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/receive_message', methods=['POST'])
def receive_message():
    data = request.get_json()
    message = data.get('message')
    
    # 여기에서 채팅 메시지를 처리하고 응답을 생성합니다.
    response_message = f"서버에서 받은 메시지: {message}"
    print(response_message)
    return jsonify({'response_message': response_message})

if __name__ == '__main__':
    app.run(debug=True)
