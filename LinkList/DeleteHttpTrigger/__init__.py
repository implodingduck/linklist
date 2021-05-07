import logging

import azure.functions as func
from azure.cosmos import exceptions, CosmosClient, PartitionKey

import os 

def main(req: func.HttpRequest) -> func.HttpResponse:
    trigger_name = 'Delete'
    logging.info(f'{trigger_name} HTTP trigger function processed a request.')
    client = CosmosClient(os.environ.get('COSMOSDB_ENDPOINT'), os.environ.get('COSMOSDB_KEY'))
    db = client.get_database_client(os.environ.get('COSMOSDB_NAME'))
    container = db.get_container_client(os.environ.get('COSMOSDB_CONTAINER'))
    container.delete_item(item=req.route_params.get('id'), partition_key=req.route_params.get('id'))
    return func.HttpResponse(
            f'',
            status_code=204
    )
