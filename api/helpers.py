import logging
import json

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

with open('config.json', mode="r") as input_file:
    config = json.load(input_file)
    storage = config['storage']