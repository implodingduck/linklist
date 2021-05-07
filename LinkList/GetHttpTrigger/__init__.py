import logging

import azure.functions as func
from azure.cosmos import exceptions, CosmosClient, PartitionKey

import os 

def main(req: func.HttpRequest) -> func.HttpResponse:
    trigger_name = 'Get'
    logging.info(f'{trigger_name} HTTP trigger function processed a request.')
    client = CosmosClient(os.environ.get('COSMOSDB_ENDPOINT'), os.environ.get('COSMOSDB_KEY'))
    db = client.get_database_client(os.environ.get('COSMOSDB_NAME'))
    container = db.get_container_client(os.environ.get('COSMOSDB_CONTAINER'))
    query = "SELECT * FROM c WHERE c.id=@id"
    items = list(container.query_items(
        query=query,
        parameters=[
            { "name":"@id", "value": req.route_params.get('id') }
        ],
        enable_cross_partition_query=True
    ))
    if len(items) > 0:
        return func.HttpResponse(
                f'{items[0]}',
                status_code=200
        )
    else:
        return func.HttpResponse(
                f'Link not found',
                status_code=404
        )
