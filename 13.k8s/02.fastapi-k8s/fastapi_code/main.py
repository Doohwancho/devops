import logging
from logging.config import dictConfig
import logstash 
import socket
from fastapi import FastAPI, HTTPException
from pymongo import MongoClient
from pydantic import BaseModel
import os

# 로깅 설정
LOGSTASH_HOST = 'logstash-service'
LOGSTASH_PORT = 5044

log_config = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "json": {
            "()": "pythonjsonlogger.jsonlogger.JsonFormatter",
            "format": "%(asctime)s %(levelname)s %(name)s %(message)s %(hostname)s",
            "datefmt": "%Y-%m-%d %H:%M:%S",
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "json",
            "stream": "ext://sys.stdout",
        },
        "logstash": {
            "class": "logstash.TCPLogstashHandler",
            "host": "logstash-service",
            "port": 5044,
            "version": 1,
            "message_type": "python-logstash",
            "tags": ["fastapi"]
        }
    },
    "loggers": {
        "app": {
            "handlers": ["console", "logstash"],
            "level": "INFO",
            "propagate": True
        },
    }
}

# 로깅 설정 적용
dictConfig(log_config)
logger = logging.getLogger("app")

# hostname 추가
logger = logging.LoggerAdapter(logger, {'hostname': socket.gethostname()})

app = FastAPI()

try:
    client = MongoClient(f"mongodb://{os.getenv('MONGODB_USERNAME')}:{os.getenv('MONGODB_PASSWORD')}@{os.getenv('MONGODB_URL')}")
    print("DB Connection successful")
except Exception as e: print(e)


class User(BaseModel): # Define a Pydantic model for the User data
    Name: str
    Age: int
    Occupation: str
    Learning: str

# If the database and collection do not exist, MongoDB will create them automatically
db = client.my_db
collection = db.my_collection


@app.get("/")
def read_root():
    return "Hello from the other sideeeeeee!!!!!!!!"


@app.post("/create_user/")
async def create_user(user: User):
    try:
        logger.info(f"Creating user: {user.Name}")
        result = collection.insert_one(user.dict())
        logger.info(f"User created successfully: {user.Name}")
        return {"message": "User created successfully", "id": str(result.inserted_id)}
    except Exception as e:
        logger.error(f"Error creating user {user.Name}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))



@app.get("/get_users/{name}")
async def get_user(name: str):
    try:
        logger.info(f"Fetching user: {name}")
        user = collection.find_one({"Name": name})
        if user:
            # ObjectId를 문자열로 변환
            user["_id"] = str(user["_id"])
            logger.info(f"User found: {name}")
            return user
        logger.warning(f"User not found: {name}")
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        logger.error(f"Error fetching user {name}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    return {"status": "OK"}

