import logging

import azure.functions as func
from azure.cosmos import exceptions, CosmosClient, PartitionKey

import os 

def main(req: func.HttpRequest) -> func.HttpResponse:
    trigger_name = 'Update'
    logging.info(f'{trigger_name} HTTP trigger function processed a request.')
    client = CosmosClient(os.environ.get('COSMOSDB_ENDPOINT'), os.environ.get('COSMOSDB_KEY'))
    db = client.get_database_client(os.environ.get('COSMOSDB_NAME'))
    container = db.get_container_client(os.environ.get('COSMOSDB_CONTAINER'))
    item = container.read_item(item=req.route_params.get('id'), partition_key=req.route_params.get('id'))
    req_body = req.get_json()
    if 'url' in req_body:
        item['url'] = req_body['url']
    if 'description' in req_body:
        item['description'] = req_body['description']
    container.upsert_item(body=item)

    return func.HttpResponse(
            f'{item}',
            status_code=200
    )
