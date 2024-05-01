import google.generativeai as genai
from flask import Flask, request, jsonify
import requests
import json
from google.generativeai.types import GenerateContentResponse
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

gemini_key = "AIzaSyBJZFWd-9GMVZCJPFRgqdVEB7p4PpKIcZ8"

genai.configure(api_key = gemini_key)
        
model = genai.GenerativeModel('gemini-pro')

def generate_prompt(ingredients, servings):
  prompt = "With access to only " + ingredients + "and no other ingredients, create a complete recipe for " + str(servings) + " people."
  return prompt

def extract_text_from_response(response: GenerateContentResponse) -> str:
  candidate = response.candidates[0]
  
  text_content = candidate.content.parts[0].text
  
  return text_content


def generate_recipe(ingredients, servings):  
  prompt = generate_prompt(ingredients, servings)
  recipe = model.generate_content(prompt)
  candidate = recipe.candidates[0]
  text_content = candidate.content.parts[0].text
  return text_content

@app.route('/generate-response', methods=['POST'])
def generate_response():
  data = request.json
  ingredients = data.get('ingredients')
  servings = data.get('servings')
  
  response = generate_recipe(ingredients, servings)
  return jsonify({'response': response})

if __name__ == '__main__':
  app.run(debug=True)