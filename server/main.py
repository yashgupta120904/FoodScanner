from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import pytesseract
from PIL import Image
import openai
import os
import uvicorn
import re
import tempfile
import base64
import json
from dotenv import load_dotenv
from typing import Dict, List, Any, Union, Tuple, Optional
import csv
import itertools

# Load environment variables
load_dotenv()

app = FastAPI(title="Food Analysis API",
              description="API for analyzing food ingredients and comparing nutritional profiles")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

openai.api_key = OPENAI_API_KEY
MAX_TOKENS = 800

# Set Tesseract path for Windows - adjust as needed for your environment
if os.name == 'nt':  # Windows
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Sample harmful combinations (can be loaded from CSV)
DEFAULT_HARMFUL_COMBINATIONS = [
    ("sugar", "water"),
    ("natural flavors", "preservative"),
]

def extract_text_from_image(image_bytes: bytes) -> str:
    """Extract ingredients text from image using OCR"""
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(image_bytes)
            tmp_path = tmp.name

        with Image.open(tmp_path) as img:
            img = img.convert('L')
            text = pytesseract.image_to_string(img)
            os.unlink(tmp_path)
            return text.strip() or "Sugar, Water, Natural Flavors"
    except Exception as e:
        print(f"OCR Error: {str(e)}")
        return "Sugar, Water, Natural Flavors"

def analyze_with_gpt(ingredients: str) -> dict:
    """Get comprehensive ingredient analysis from OpenAI API"""
    try:
        prompt = f"""Analyze these food ingredients and provide detailed information:

Ingredients: {ingredients}

Return ONLY valid JSON with these keys:
1. "quality_score": integer from 0-10 (10 is highest quality)
2. "harmful_ingredients": list of ingredients that may be harmful to health
3. "banned_by_country": dictionary mapping country names to lists of ingredients banned in those countries
4. "common_allergens": list of common allergens present
5. "alternatives": list of healthier alternative products

Example format:
{{
  "quality_score": 7,
  "harmful_ingredients": ["Red Dye 40", "High Fructose Corn Syrup"],
  "banned_by_country": {{
    "European Union": ["Red Dye 40"],
    "Japan": ["Potassium Bromate"]
  }},
  "common_allergens": ["Soy", "Dairy"],
  "alternatives": ["Stevia", "Monk Fruit Sweetener"]
}}"""

        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a food safety expert who responds only with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=MAX_TOKENS,
            temperature=0.2,
        )

        content = response.choices[0].message.content

        try:
            json_match = re.search(r'({[\s\S]*})', content)
            if json_match:
                return json.loads(json_match.group(1))
            return {}
        except json.JSONDecodeError as e:
            print(f"JSON parsing error: {e}")
            return {}

    except Exception as e:
        print(f"GPT Analysis Error: {str(e)}")
        return {}

def detect_harmful_interactions(
        extracted_ingredients: List[str],
        harmful_combinations: Union[str, List[Tuple[str, str]], List[dict]] = DEFAULT_HARMFUL_COMBINATIONS
) -> List[Tuple[str, str]]:
    """
    Detect harmful ingredient interactions from multiple data formats

    :param extracted_ingredients: List of ingredients from product
    :param harmful_combinations: Data source can be:
        - CSV string
        - A list of tuples (e.g., [("Ingredient1", "Ingredient2")])
        - A list of dictionaries (e.g., [{"Ingredient1": "X", "Ingredient2": "Y"}])

    :return: List of detected harmful ingredient pairs
    """
    harmful_pairs = set()
    known_harmful = set()

    try:
        # Handle different input formats
        if isinstance(harmful_combinations, str):
            # Process CSV string
            reader = csv.DictReader(harmful_combinations.splitlines())
            for row in reader:
                if pair := (row.get("Ingredient1", "").lower().strip(),
                            row.get("Ingredient2", "").lower().strip()):
                    known_harmful.add(pair)
        elif isinstance(harmful_combinations, list):
            for item in harmful_combinations:
                if isinstance(item, tuple):
                    known_harmful.add((item[0].lower().strip(), item[1].lower().strip()))
                elif isinstance(item, dict):
                    if pair := (item.get("Ingredient1", "").lower().strip(),
                                item.get("Ingredient2", "").lower().strip()):
                        known_harmful.add(pair)
    except Exception as e:
        print(f"Error processing harmful combinations: {e}")

    # Check all ingredient combinations
    extracted_lower = [i.lower().strip() for i in extracted_ingredients]
    for i1, i2 in itertools.combinations(extracted_lower, 2):
        if (i1, i2) in known_harmful or (i2, i1) in known_harmful:
            harmful_pairs.add((i1, i2))

    return list(harmful_pairs)

def compare_food_items(food1: str, food2: str) -> dict:
    """
    Compare the nutritional profiles of two food items and identify any potential side effects when consumed together.

    Args:
        food1: Name of the first food item
        food2: Name of the second food item

    Returns:
        dict: A JSON-like dictionary with keys:
            - food1: Name of the first food item
            - food2: Name of the second food item
            - better_nutritional_value: Which food is nutritionally superior, or 'tie'
            - comparison_details: Detailed side-by-side nutritional breakdown
            - potential_side_effects: Any known interactions or adverse effects when eaten together
    """
    system_msg = "You are an expert nutritionist. Provide clear, concise nutritional comparisons."
    user_msg = (
        f"Compare the nutritional profiles of '{food1}' and '{food2}', including macronutrients (proteins, carbohydrates, fats), "
        "key vitamins and minerals, and overall caloric content. Specify which food has better nutritional value or state 'tie'. "
        "Also list any known interactions or side effects if these items are consumed together. "
        "Respond strictly with a JSON object containing the keys: food1, food2, better_nutritional_value, comparison_details, "
        "potential_side_effects. Do not include additional text. "
        "Limit your response to under 100 words."
    )

    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_msg},
                {"role": "user", "content": user_msg}
            ],
            temperature=0,
            max_tokens=300
        )

        content = response.choices[0].message.content

        try:
            json_match = re.search(r'({[\s\S]*})', content)
            if json_match:
                return json.loads(json_match.group(1))
            return json.loads(content)
        except json.JSONDecodeError as e:
            print(f"JSON parsing error in food comparison: {e}")
            return {
                "food1": food1,
                "food2": food2,
                "error": "Failed to parse response"
            }
    except Exception as e:
        print(f"Food comparison error: {str(e)}")
        return {
            "food1": food1,
            "food2": food2,
            "error": str(e)
        }

@app.post("/analyze", response_model=Dict[str, Any])
async def analyze_food(file: UploadFile = File(...)):
    """
    Analyze food ingredients from an image

    - **file**: An image file containing food ingredients label

    Returns a JSON with ingredient analysis including:
    - Extracted ingredients list
    - Quality score (0-10)
    - Health concerns (harmful ingredients, allergens, etc.)
    - Alternative healthier options
    """
    try:
        image_bytes = await file.read()
        base64_image = base64.b64encode(image_bytes).decode('utf-8')

        ocr_text = extract_text_from_image(image_bytes)
        ingredients_list = [i.strip() for i in ocr_text.split(',') if i.strip()]

        gpt_results = analyze_with_gpt(ocr_text)

        # Initialize concerns
        concerns = {
            "harmful_ingredients": [],
            "banned_by_country": {},
            "allergens": [],
            "harmful_interactions": []
        }

        quality_score = 5
        alternatives = []

        if gpt_results:
            quality_score = min(max(gpt_results.get("quality_score", 5), 0), 10)
            concerns["harmful_ingredients"] = list(set(gpt_results.get("harmful_ingredients", [])))
            concerns["banned_by_country"] = {k: list(set(v)) for k, v in gpt_results.get("banned_by_country", {}).items()}
            concerns["allergens"] = list(set(gpt_results.get("common_allergens", [])))
            alternatives = list(set(gpt_results.get("alternatives", [])))

        # Detect harmful interactions
        concerns["harmful_interactions"] = detect_harmful_interactions(ingredients_list)

        return {
            "image_base64": base64_image,
            "ingredients": ingredients_list,
            "quality_score": quality_score,
            "concerns": concerns,
            "alternatives": alternatives
        }

    except Exception as e:
        print(f"Analysis Error: {str(e)}")
        return {
            "error": str(e),
            "quality_score": 5,
            "concerns": {
                "harmful_ingredients": [],
                "banned_by_country": {},
                "allergens": [],
                "harmful_interactions": []
            },
            "alternatives": []
        }

@app.post("/compare", response_model=Dict[str, Any])
async def compare_foods(
        food1: str = Form(..., description="First food item to compare"),
        food2: str = Form(..., description="Second food item to compare")
):
    """
    Compare nutritional profiles of two food items

    - **food1**: Name of the first food item
    - **food2**: Name of the second food item

    Returns a JSON with:
    - Which food has better nutritional value
    - Detailed nutritional comparison
    - Potential side effects when consumed together
    """
    try:
        comparison = compare_food_items(food1, food2)
        return comparison
    except Exception as e:
        return {
            "error": str(e),
            "food1": food1,
            "food2": food2
        }

@app.get("/health")
async def health_check():
    """Simple health check endpoint"""
    return {"status": "healthy", "message": "Food Analysis API is running"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=2525)

