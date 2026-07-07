import os
from dotenv import load_dotenv
import psycopg
from psycopg import DatabaseError
from psycopg.types.json import Jsonb
from psycopg.errors import Error
from psycopg.rows import dict_row
from pycryptid.helpers import logger
from datetime import datetime

class Database:
    def __init__(self):
        logger.info('Loading env variables...')
        load_dotenv('./.env')
        logger.info('Connecting to database...')
        try:
            self.conn = psycopg.connect(
                host=os.getenv('PG_HOST'),
                dbname=os.getenv('PG_DATABASE'),
                user=os.getenv('PG_USER'),
                password=os.getenv('PG_PASSWORD'),
                port=os.getenv('PG_PORT'),
                row_factory=dict_row
                
            )
            logger.info(f'Time: {datetime.now()}')
            logger.info(f'Connection info: {self.conn.info}')
            logger.info(f'Connection status: {self.conn.info.status}')
            logger.info(f'Connection encoding: {self.conn.info.encoding}')
            logger.info(f'Connection parameters: {self.conn.info.get_parameters()}')
            self.cur = self.conn.cursor()
        except (Exception, DatabaseError) as error:
                logger.error(error)
        return
    
    def version(self):
        sql = """
            SELECT version();
        """
        self.cur.execute(sql)
        result = self.cur.fetchone()
        logger.info(f'Version: {result[0]}')
        self.close()
        return       

    def close(self):
        self.cur.close()
        self.conn.close()
        logger.info(f'Connection to database closed')
        return
    
    def commit(self):
        self.conn.commit()
        logger.info(f'Changes to database committed')
        return
    
    def reset(self):
        logger.warning(f'Deleting contents of all tables...')
        confirmation = input('Are you sure? (Yes/No)')
        if confirmation == "Yes":
            sql = """
                DELETE FROM dtif.fork;
                DELETE FROM dtif.issuer_identifier;
                DELETE FROM dtif.maintainer_identifier;
                DELETE FROM dtif.auxiliary_token;
                DELETE FROM dtif.ledger;
                DELETE FROM dtif.short_name;
                DELETE FROM dtif.digital_asset_external_identifier;
                DELETE FROM dtif.dti_external_identifier;
                DELETE FROM dtif.equivalent_digital_token_group;
                DELETE FROM dtif.token;
                DELETE FROM dtif.staging_json;            
            """
            self.cur.execute(sql)
            logger.warning(f'Contents of all tables deleted!')
            return
        else:
            logger.info('Not deleted contents of tables.')
            

# db = Database()
# db.reset()
# db.commit()