import json
import logging
import config
import aiosqlite
# import sqlite3


class Database:
    def __init__(self, db_path):
        self.db_path = db_path
        self.connection = None

    async def connect(self):
        try:
            self.connection = await aiosqlite.connect(self.db_path)
            logging.info("Successful connection to the database.")
        except Exception as e:
            logging.error(f"Failed to connect to database: {e}")

    async def close(self):
        try:
            await self.connection.close()
            logging.info("The connection to the database is closed.")
        except Exception as e:
            logging.error(f"Failed to close database connection: {e}")


    async def get_data_by_sub_id(self, sub_id):
        try:
            async with self.connection.execute(
                    """
                    SELECT 
                        json_extract(client.value, '$.id') AS client_id,
                        json_extract(client.value, '$.email') AS client_email
                    FROM 
                        inbounds,
                        json_each(json_extract(settings, '$.clients')) AS client
                    WHERE 
                        json_extract(client.value, '$.subId') = ?
                    """, (sub_id,)
            ) as cursor:
                result = await cursor.fetchone()
                if result:
                    client_id, client_email = result
                    logging.info(f"Client found: id={client_id}, email={client_email}")
                    return {"id": client_id, "email": client_email}
                else:
                    logging.warning(f"No client found with sub_id {sub_id}")
                    return {"error": "No client found with the given sub_id"}
        except Exception as e:
            logging.error(f"Failed to fetch data by sub_id: {e}")
            return {"error": f"Failed to fetch data: {e}"}


      # async def get_data_by_sub_id(self, sub_id):
      #   try:
      #       async with self.connection.execute(
      #               "SELECT uuid, email FROM clients WHERE sub_id = ?", (sub_id,)
      #       ) as cursor:
      #           result = await cursor.fetchone()
      #           if result:
      #               logging.info(f"Data found for sub_id {sub_id}: uuid={result[0]}, email={result[1]}")
      #               return {"uuid": result[0], "email": result[1]}
      #           else:
      #               logging.warning(f"No data found for sub_id {sub_id}")
      #               return None
      #   except Exception as e:
      #       logging.error(f"Failed to fetch data by sub_id: {e}")
      #       return None
