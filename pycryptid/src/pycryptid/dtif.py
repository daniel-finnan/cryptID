from pycryptid.db import Database, Jsonb, Error
from pycryptid.helpers import logger
from dotenv import load_dotenv
import os
import json

class DTIF(Database):

    def __init__(self):
        super().__init__()

    def files_generator(self, type, files = None):
        # Insert all files from directory
        if files == None or isinstance(files, list):
            if files == None:
                match type:
                    case 'tokens':
                        files = os.listdir(os.getenv('DTIF_TOKENS'))
                    case 'ledgers':
                        files = os.listdir(os.getenv('DTIF_LEDGERS'))
            logger.info(f'Inserting: {files}')
            if len(files) == 0:
                logger.error('No files to insert!')
                return
            for file in files:
                logger.info(f'Processing: {file}')
                match type:
                    case 'tokens':
                        with open(f"{os.getenv('DTIF_TOKENS')}{file}", mode="r") as input_file:
                            json_obj = json.load(input_file)                        
                    case 'ledgers':
                        with open(f"{os.getenv('DTIF_LEDGERS')}{file}", mode="r") as input_file:
                            json_obj = json.load(input_file)                                      
                yield json_obj
        else:
            logger.error("If you wish to insert specific files, then 'files' parameter must be a list!")
            return  

class Ledger(DTIF):
    
    def __init__(self):
        super().__init__()
        self.OTHER = 0
        self.BLOCKCHAIN = 1

    def insert(self, files = None):
        counter = 0
        for json_obj in self.files_generator('ledgers', files):
            logger.info(f'Inserting: {json_obj}')
            if int(json_obj['Header']['DLTType']) != self.OTHER and int(json_obj['Header']['DLTType']) != self.BLOCKCHAIN :
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
            counter += 1
        self.commit()
        logger.info(f'Inserted {counter} ledger file(s) to the database.')
        self.close()  
        return

    def get_all(self):
        try:
            self.cur.execute(
                "SELECT * FROM dtif.ledger;"
            )
            result = self.cur.fetchall()
            if result is None:
                logger.info(f'Returned 0 ledger files from the database.')
            else:
                logger.info(f'Returned {len(result)} ledger file(s) from the database.')             
        except Error as error:
            logger.error(f'Error: {error}')
            self.close()
            return        
        self.close()
        return result
    
    def get_by_dli(self, dli):
        try:
            self.cur.execute(
                "SELECT * FROM dtif.ledger WHERE dli = %s;", (dli,)
            )
            result = self.cur.fetchone()
            if result is None:
                logger.info(f'Returned 0 ledger files from the database.')
            else:
                logger.info(f'Returned {len(result)} ledger file from the database.')            
        except Error as error:
            logger.error(f'Error: {error}')
            self.close()
            return        
        self.close()
        return result

    def get_by_long_name(self, long_name):
        try:
            self.cur.execute(
                "SELECT * FROM dtif.ledger WHERE long_name = %s;", (long_name,)
            )
            result = self.cur.fetchone()
            if result is None:
                logger.info(f'Returned 0 ledger files from the database.')
            else:
                logger.info(f'Returned {len(result)} ledger file from the database.')
        except Error as error:
            logger.error(f'Error: {error}')
            self.close()
            return        
        self.close()
        return result              


#Ledger().insert() #['P0T79M291.json', 'T73D7L1RM.json'])
# query_result = Ledger().get_all()
# query_result = Ledger().get_by_dli('9DDKPFN21')
# query_result = Ledger().get_by_long_name('Flow')
# logger.info(query_result)

class Token(DTIF):
    
    def __init__(self):
        super().__init__()
        self.AUXILIARY = 0
        self.EQUIVALENT = 2        

    def insert(self, files = None):
        auxiliary = 0
        # Have to insert auxiliary tokens first then equivalent tokens
        for json_obj in self.files_generator('tokens', files):
            match int(json_obj['Header']['DTIType']):
                case self.AUXILIARY:
                    logger.info('Found auxiliary token...')
                    logger.info(f'Inserting: {json_obj}')
                    try:
                        self.cur.execute(
                            "SELECT dtif.insert_auxiliary_token(%s)", [Jsonb(json_obj)]
                        )
                        result = self.cur.fetchone()
                        logger.info(f'Result: {result}')
                        auxiliary += 1
                    except Error as error:
                        logger.error(f'Error: {error}')
                        self.close()
                        return
                case self.EQUIVALENT:
                    pass
                case _:
                    logger.error('Incorrect DTIType!')
                    return                    
        equivalent = 0
        for json_obj in self.files_generator('tokens', files):
            match int(json_obj['Header']['DTIType']):
                case self.AUXILIARY:
                    pass
                case self.EQUIVALENT:
                    logger.info('Found equivalent token...')
                    logger.info(f'Inserting: {json_obj}')
                    try:
                        self.cur.execute(
                            "SELECT dtif.insert_equivalent_token(%s)", [Jsonb(json_obj)]
                        )
                        result = self.cur.fetchone()
                        logger.info(f'Result: {result}')
                        equivalent += 1
                    except Error as error:
                        logger.error(f'Error: {error}')
                        self.close()
                        return
                case _:
                    logger.error('Incorrect DTIType!')
                    return                    
        self.commit()
        logger.info(f'Inserted {auxiliary} auxiliary & {equivalent} equivalent token file(s) to the database.')
        self.close()  
        return
    
#Token().insert() #['2BKLSP3D6.json'])
