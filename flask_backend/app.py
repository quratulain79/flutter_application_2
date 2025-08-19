from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from PIL import Image
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

model = load_model('lung_model.h5', compile=False)


@app.route('/')
def home():
    return "AI Model Flask Backend Running"

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # Preprocess the image
    img = Image.open(filepath).convert('RGB')
    img = img.resize((224, 224))  # Adjust if your model requires different size
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    # Predict
    prediction = model.predict(img_array)
    class_index = np.argmax(prediction)
    class_names = ['Bengin cases', 'Malignant cases', 'Normal cases']
    predicted_label = class_names[class_index]

    return jsonify({'prediction': predicted_label})

if __name__ == '__main__':
    app.run(debug=True)
