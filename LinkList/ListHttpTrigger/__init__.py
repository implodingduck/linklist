import logging

import azure.functions as func
from azure.cosmos import exceptions, CosmosClient, PartitionKey

import os 

def main(req: func.HttpRequest) -> func.HttpResponse:
    trigger_name = 'List'
    logging.info(f'{trigger_name} HTTP trigger function processed a request.')
    client = CosmosClient(os.environ.get('COSMOSDB_ENDPOINT'), os.environ.get('COSMOSDB_KEY'))
    db = client.get_database_client(os.environ.get('COSMOSDB_NAME'))
    container = db.get_container_client(os.environ.get('COSMOSDB_CONTAINER'))
    query = "SELECT * FROM c"
    items = container.query_items(
        query=query,
        enable_cross_partition_query=True
    )
    retval = []
    for i in items:
        retval.append( {
            'id': i['id'],
            'url': i['url'],
            'description': i['description']
        } )
    return func.HttpResponse(
            f'{retval}',
            status_code=200
    )
