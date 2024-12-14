import os
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise ValueError("Missing MONGO_URI environment variable")

client = MongoClient(MONGO_URI, server_api=ServerApi("1"))

db = client.DirectCareDB  # Change this to your DB name
collection = db["care_data"]
