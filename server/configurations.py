from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

MONGODB_URI = "mongodb+srv://RandyBatista:DirectCare@cluster0.xfk02.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

client = MongoClient(MONGODB_URI, server_api=ServerApi("1"))
db = client.DirectCareDB  # Change this to your DB name
collection = db["care_data"]


# from fastapi import FastAPI
# from motor.motor_asyncio import AsyncIOMotorClient
# from dotenv import load_dotenv
# import os

# # Load environment variables from .env file
# load_dotenv(dotenv_path="./../.env")

# app = FastAPI()

# # MongoDB connection
# MONGODB_URI = os.getenv("MONGODB_URI")  # Get this from your .env file
# if MONGODB_URI is None:
#     raise ValueError("MONGODB_URI environment variable is not set.")

# client = AsyncIOMotorClient(MONGODB_URI)
# db = client.DirectCareDB  # Change this to your DB name
# collection = db["items"]
# print(db.list_collection_names())
