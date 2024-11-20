def Example_Individual_data(todo):
    return {
        "id": str(todo["_id"]),
        "title": todo["title"],
        "description": todo["description"],
        "status": todo["is_completed"],
    }

def all_tasks(todos):
    return [Example_Individual_data(todo) for todo in todos]
