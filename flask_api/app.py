from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import tensorflow as tf
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Define class labels
class_labels = ['Blight', 'Common Rust', 'Gray Leaf Spot', 'Healthy']

# Get absolute path to model file
model_path = os.path.join(os.path.dirname(__file__), 'model', 'best_model.tflite')

# Load the TFLite model
try:
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    # Get input and output tensors
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    print("Model loaded successfully!")
    print("Input shape:", input_details[0]['shape'])
    print("Output shape:", output_details[0]['shape'])
except Exception as e:
    print(f"Error loading model: {e}")

def preprocess_image(image):
    print("Original image size:", image.size)
    # Resize image to 224x224
    image = image.resize((224, 224))
    print("Resized image shape:", image.size)
    # Convert to array and add batch dimension
    img_array = np.array(image, dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)
    # Normalize
    img_array = img_array / 255.0
    print("Final array shape:", img_array.shape)
    return img_array

def get_recommendations(disease):
    recommendations = {
        'Blight': [
            'Remove and destroy infected leaves',
            'Apply appropriate fungicide',
            'Ensure good air circulation'
        ],
        'Common Rust': [
            'Apply fungicide early in the season',
            'Plant resistant varieties',
            'Monitor humidity levels'
        ],
        'Gray Leaf Spot': [
            'Rotate crops annually',
            'Remove crop debris',
            'Consider fungicide application'
        ],
        'Healthy': [
            'Continue regular maintenance',
            'Monitor for early signs of disease',
            'Maintain proper irrigation'
        ]
    }
    return recommendations.get(disease, ['Consult a local agricultural expert'])

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    
    try:
        # Get and preprocess the image
        image_file = request.files['image']
        image = Image.open(io.BytesIO(image_file.read()))
        processed_image = preprocess_image(image)
        
        # Set the tensor to point to the input data to be inferred
        interpreter.set_tensor(input_details[0]['index'], processed_image)
        
        # Run the inference
        interpreter.invoke()
        
        # Get prediction results
        prediction = interpreter.get_tensor(output_details[0]['index'])
        
        # Get predicted class and confidence
        predicted_class = class_labels[np.argmax(prediction)]
        confidence = float(np.max(prediction))
        
        print(f"Predicted class: {predicted_class}")
        print(f"Confidence: {confidence}")
        print(f"All probabilities: {prediction}")
        
        # Get recommendations for the predicted disease
        recommendations = get_recommendations(predicted_class)
        
        return jsonify({
            'disease': predicted_class,
            'confidence': confidence,
            'recommendations': recommendations
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port) 