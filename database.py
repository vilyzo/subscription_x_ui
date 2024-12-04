import config
import aiosqlite
import sqlite3
import logging

class Database:
    def __init__(self, db_path):
        self.db_path = db_path
        self.connection = None

    async def connect(self):
        try:
            self.connection = await aiosqlite.connect(self.db_path)
            logging.info("Успешное подключение к базе данных.")
        except Exception as e:
            logging.error(f"Failed to connect to database: {e}")

    async def close(self):
        try:
            await self.connection.close()
            logging.info("Соединение с базой данных закрыто.")
        except Exception as e:
            logging.error(f"Failed to close database connection: {e}")

    async def get_data_by_sub_id(self, sub_id):
        try:
            async with self.connection.execute(
                    "SELECT uuid, email FROM clients WHERE sub_id = ?", (sub_id,)
            ) as cursor:
                result = await cursor.fetchone()
                if result:
                    logging.info(f"Data found for sub_id {sub_id}: uuid={result[0]}, email={result[1]}")
                    return {"uuid": result[0], "email": result[1]}
                else:
                    logging.warning(f"No data found for sub_id {sub_id}")
                    return None
        except Exception as e:
            logging.error(f"Failed to fetch data by sub_id: {e}")
            return None