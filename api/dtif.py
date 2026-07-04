from db import Database, Jsonb, Error
from helpers import logger, storage
import os
import json


class DTIF(Database):

    def __init__(self):
        super().__init__() 

class Ledger(DTIF):
    
    def __init__(self):
        super().__init__()
      
    def insert(self, files = None):
        # Insert all files from directory
        if files == None or isinstance(files, list):
            if files == None:
                files = os.listdir(storage['dtif']['ledgers'])
            logger.info(f'Inserting: {files}')
            if len(files) == 0:
                logger.error('No files to insert!')
                return
            for file in files:
                logger.info(f'Processing: {file}')
                with open(f"{storage['dtif']['ledgers']}{file}", mode="r") as input_file:
                    json_obj = json.load(input_file)
                logger.info(f'Inserting: {json_obj}')
                if int(json_obj['Header']['DLTType']) != 0 and int(json_obj['Header']['DLTType']) != 1:
                    logger.error('Incorrect DLTType!')
                    return
                try:
                    self.cur.execute(
                        "SELECT dtif.insert_ledger(%s)", [Jsonb(json_obj)]
                    )
                    result = self.cur.fetchone()
                except Error as error:
                    logger.error(f'Error: {error}')
                    self.close()
                    return
                logger.info(f'Result: {result}')
        else:
            logger.error("If you wish to insert specific files, then 'files' parameter must be a list!")
            return        
        # Only insert files specified in 'files' parameter
        self.commit()
        self.close()  
        return          





Ledger().insert(['P0T79M291.json', 'T73D7L1RM.json'])
