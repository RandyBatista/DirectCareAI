from fastapi import FastAPI, APIRouter, HTTPException
from configurations import collection
from database.schemas import all_tasks
from database.models import ExampleModel
from bson import ObjectId
from datetime import datetime

app = FastAPI()
router = APIRouter()


@router.get("/")
async def get_post():
    try:
        data = list(collection.find({"is_deleted": False}))
        return all_tasks(data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching posts: {e}")



@router.post("/")
async def create_post(new_post: ExampleModel):
    try:
        resp = collection.insert_one(dict(new_post))
        return {"status_code": 200, "id": str(resp.inserted_id)}
    except Exception as e:
        return HTTPException(status_code=500, detail=f"Some error occurred {e}")


@router.put("/{post_id}")
async def update_post(post_id: str, updated_post: ExampleModel):
    try:
        try:
            id = ObjectId(post_id)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid post ID")

        existing_doc = collection.find_one({"_id": id, "is_deleted": False})
        if not existing_doc:
            raise HTTPException(status_code=404, detail="Post does not exist")

        updated_post.updated_at = datetime.now()
        resp = collection.update_one({"_id": id}, {"$set": updated_post.dict()})
        return {"status_code": 200, "message": "Task updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating post: {e}")

@router.delete("/{post_id}")
async def delete_post(post_id: str):
    try:
        try:
            id = ObjectId(post_id)
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid post ID")

        existing_doc = collection.find_one({"_id": id, "is_deleted": False})
        if not existing_doc:
            raise HTTPException(status_code=404, detail="Post does not exist")

        collection.update_one({"_id": id}, {"$set": {"is_deleted": True}})
        return {"status_code": 200, "message": "Task deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting post: {e}")


app.include_router(router)
