from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import tensorflow as tf
import os
from flask_cors import CORS
import cv2

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
    try:
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
            
        # Check for green color presence
        img_array = np.array(image)
        hsv = cv2.cvtColor(img_array, cv2.COLOR_RGB2HSV)
        green_lower = np.array([25, 40, 40])
        green_upper = np.array([85, 255, 255])
        green_mask = cv2.inRange(hsv, green_lower, green_upper)
        green_ratio = np.sum(green_mask > 0) / (image.size[0] * image.size[1])
        
        if green_ratio < 0.15:  # At least 15% should be green
            raise ValueError("The image doesn't appear to be a maize leaf. Please ensure the image shows a maize leaf clearly.")

        # Resize and normalize for model
        image = image.resize((224, 224))
        img_array = np.array(image, dtype=np.float32)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array / 255.0
        
        return img_array

    except Exception as e:
        raise ValueError(f"Image preprocessing failed: {str(e)}")

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
        image_file = request.files['image']
        image = Image.open(io.BytesIO(image_file.read()))
        
        try:
            processed_image = preprocess_image(image)
        except ValueError as e:
            return jsonify({'error': str(e)}), 400
            
        # Run inference
        interpreter.set_tensor(input_details[0]['index'], processed_image)
        interpreter.invoke()
        prediction = interpreter.get_tensor(output_details[0]['index'])
        
        # Get probabilities for all classes
        probabilities = prediction[0].tolist()
        max_confidence = float(np.max(probabilities))
        predicted_class = class_labels[np.argmax(probabilities)]
        
        # Create confidence scores for all classes
        confidence_scores = {
            class_label: float(prob) 
            for class_label, prob in zip(class_labels, probabilities)
        }
        
        if max_confidence < 0.70:
            return jsonify({
                'error': 'Unable to make a confident prediction. Please ensure the image is clear and well-lit.',
                'confidence_scores': confidence_scores
            }), 400
        elif max_confidence < 0.80:
            # Uncertain case - show all probabilities
            return jsonify({
                'status': 'uncertain',
                'message': 'The prediction is uncertain. Here are the possibilities:',
                'confidence_scores': confidence_scores,
                'recommendations': get_recommendations(predicted_class)
            })
        else:
            # Confident prediction
            return jsonify({
                'status': 'confident',
                'disease': predicted_class,
                'confidence': max_confidence,
                'confidence_scores': confidence_scores,
                'recommendations': get_recommendations(predicted_class)
            })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port) 