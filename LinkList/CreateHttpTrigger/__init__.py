import logging

import azure.functions as func
from azure.cosmos import exceptions, CosmosClient, PartitionKey

import os 

import uuid

def main(req: func.HttpRequest) -> func.HttpResponse:
    trigger_name = 'Create'
    logging.info(f'{trigger_name} HTTP trigger function processed a request.')
    client = CosmosClient(os.environ.get('COSMOSDB_ENDPOINT'), os.environ.get('COSMOSDB_KEY'))
    db = client.get_database_client(os.environ.get('COSMOSDB_NAME'))
    container = db.get_container_client(os.environ.get('COSMOSDB_CONTAINER'))
    
    try:
        logging.info('I WONDER WHATS IN REQ.GET_JSON()')
        req_body = req.get_json()
        logging.info(req_body)
        if 'url' in req_body:
            req_body['id']=str(uuid.uuid4())
            container.create_item(body=req_body)
            return func.HttpResponse(
                f'{trigger_name}HttpTrigger called',
                status_code=201
            )
    except Exception as e:
        logging.error(e)
    return func.HttpResponse(
            f'{trigger_name}HttpTrigger called',
            status_code=400
    )
