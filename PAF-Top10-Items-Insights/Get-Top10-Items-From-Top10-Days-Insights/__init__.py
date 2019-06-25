import logging

import azure.functions as func

import pandas as pd

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Get sales transactions data from AF input in JSON format
    salesJson = req.params.get('sales')
    if not salesJson:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            salesJson = req_body.get('sales')

    if salesJson:
        # Get Insights

        # Convert from Json to pandas dataframe
        sales = pd.DataFrame(salesJson)

        # Execute Python script and convert result to Json
        result = GetTop10ItemsInsight(sales).to_json(orient='records')

        logging.info(type(result))

        # return insights to the AF output in JSON format
        return json.dumps(result)
    else:
        return func.HttpResponse(
             "Please pass sales transactions on the query string or in the request body",
             status_code=400
        )

def GetTop10ItemsInsight(dataframe1 = None):

    # Execution logic goes here
    sales = dataframe1

    # Get TOP 10 best selling days 
    top_days = sales.groupby(['date'])['orders'].sum().nlargest(10).reset_index()

    # Filter Sales by these days
    sales_top_days = sales[sales.date.isin(top_days.date)]

    # Get TOP 10 Items best selling in these days
    sales_top_items = sales_top_days.groupby(['menu_item'])['orders'].sum().nlargest(10).reset_index()
    
    # Return value must be of a sequence of pandas.DataFrame
    return sales_top_items