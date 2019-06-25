codeunit 50101 "AIR Insights Mgt."
{
    procedure GetTop10ItemsInsight()
    var
        InsightsJsonResponse: Text;
    begin
        SendSalesTransactionsToAzure(InsightsJsonResponse);
        SaveAndShowResult(InsightsJsonResponse);
    end;

    local procedure SendSalesTransactionsToAzure(var InsightsJson: Text)
    var
        SalesTransactions: Record "AIR RestSalesEntry";
        SalesTransactionsJson: Text;
    begin
        ConvertSalesTransactionsToJson(SalesTransactions, SalesTransactionsJson);
        SendRequestAndGetResponse(SalesTransactionsJson, InsightsJson);
    end;

    local procedure ConvertSalesTransactionsToJson(var SalesTransactions: Record "AIR RestSalesEntry"; var SalesTransactionsJson: Text)
    var
        Jarr: JsonArray;
        Jobj: JsonObject;
    begin
        with SalesTransactions do begin
            If FindFirst() then
                repeat
                    AddToJSONArray(Jarr, SalesTransactions);
                until Next() = 0;
        end;

        AddDataSetLabel('sales', Jarr, Jobj);
        Jobj.WriteTo(SalesTransactionsJson);
    end;

    local procedure AddToJSONArray(var Jarr: JsonArray; var SalesTransactions: Record "AIR RestSalesEntry")
    var
        Jobj: JsonObject;
    begin
        Jobj.Add('date', SalesTransactions.date);
        Jobj.Add('menu_item', SalesTransactions.menu_item);
        Jobj.Add('orders', SalesTransactions.orders);
        Jarr.Add(Jobj);
    end;

    local procedure AddDataSetLabel(dataSetLabel: Text; Jarr: JsonArray; var Jobj: JsonObject)
    begin
        Jobj.Add(dataSetLabel, Jarr);
    end;

    local procedure SendRequestAndGetResponse(SalesTransactionsJson: Text; InsightsJson: Text)
    var
        RequestMessage: HttpRequestMessage;
        RequestContent: HttpContent;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
    begin
        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(GetAzureFunctionUri());
        RequestContent.WriteFrom(SalesTransactionsJson);
        RequestMessage.Content := RequestContent;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(InsightsJson);

        Message(SalesTransactionsJson);
        Message(InsightsJson);

    end;

    local procedure GetAzureFunctionUri(): Text
    begin
        exit(StrSubstNo('%1/%2', getBaseAFuri(), getAFuri()));
    end;

    local procedure getBaseAFuri(): Text
    begin
        exit('https://bc-get-top10-items-from-top10-days-insights-blog.azurewebsites.net/api');
    end;

    local procedure getAFuri(): Text
    begin
        exit('Get-Top10-Items-From-Top10-Days-Insights');
    end;

    local procedure SaveAndShowResult(JsonResponse: Text)
    var
        TopItems: Record "Top Customers By Sales Buffer" temporary;
        Jarr: JsonArray;
        Jtoken: JsonToken;
        Jobj: JsonObject;
        i: Integer;
    begin
        If not JArr.ReadFrom(JsonResponse) then error('Invalid response, expected an JSON array as root object');
        TopItems.DeleteAll();
        For i := 0 to Jarr.Count - 1 do begin
            Jarr.Get(i, Jtoken);
            Jobj := Jtoken.AsObject;
            WITH TopItems do begin
                Init();
                Ranking := i;
                Validate(CustomerName, GetJsonValueAsText(Jobj, 'menu_item'));
                Validate(SalesLCY, GetJsonValueAsDecimal(Jobj, 'orders'));
                Insert(true);
            end;
        end;

        Page.Run(page::"AIR Top 10 Items", TopItems);
    end;

    local procedure GetJsonValueAsText(var JsonObject: JsonObject; Property: text) Value: Text;
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonValue(JsonObject, Property, JsonValue) then EXIT;
        Value := JsonValue.AsText;
    end;

    local procedure GetJsonValueAsDecimal(var JsonObject: JsonObject; Property: text) Value: Decimal;
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonValue(JsonObject, Property, JsonValue) then EXIT;
        Value := JsonValue.AsDecimal();
    end;


    local procedure GetJsonValue(var JsonObject: JsonObject;
    Property: text;
    var JsonValue: JsonValue): Boolean;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(Property, JsonToken) then exit;
        JsonValue := JsonToken.AsValue;
        Exit(true);
    end;
}
