from pydantic import BaseModel
from datetime import datetime


class ExampleModel(BaseModel):
    title: str
    description: str
    is_completed: bool = False
    is_deleted: bool = False
    updated_at: int = int(datetime.timestamp(datetime.now()))
    creation: int = int(datetime.timestamp(datetime.now()))
