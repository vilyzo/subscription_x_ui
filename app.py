import logging
from starlette.responses import PlainTextResponse
from base64encoder import Base64Encoder
import config
from database import Database
from fastapi import FastAPI, HTTPException

logging.basicConfig(level=logging.INFO)
file_handler = logging.FileHandler('app.log', mode='a')
file_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(file_handler)

SERVER_ADDRESS = config.SERVER_ADDRESS
PORT = config.SERVER_PORT
DB_PATCH = config.DB_PATCH
PUBLIC_KEY = config.PUBLIC_KEY
FP = config.FP
SNI = config.SNI
SID = config.SID


app = FastAPI()
db = Database(DB_PATCH)
encoder = Base64Encoder()


@app.get("/sub/{sub_id}", response_class=PlainTextResponse)
async def send_sub(sub_id: str):
    await db.connect()
    client_data = await db.get_data_by_sub_id(sub_id)
    await db.close()
    if client_data is None:
        raise HTTPException(status_code=404, detail="Subscription not found")
    uuid = client_data["uuid"]
    email = client_data["email"]
    key = f'vless://{uuid}@{SERVER_ADDRESS}:{PORT}?type=tcp&security=reality&pbk={PUBLIC_KEY}&fp={FP}&sni={SNI}&sid=9b534a13&spx=%2F&flow=xtls-rprx-vision#{email}'

    return encoder.encode(key)
