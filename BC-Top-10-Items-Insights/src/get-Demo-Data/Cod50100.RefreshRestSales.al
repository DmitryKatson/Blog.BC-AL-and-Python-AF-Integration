codeunit 50100 "AIR RefreshRestSales"
{
    procedure Refresh();
    var
        restsales: Record "AIR RestSalesEntry";
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonText: text;
        i: Integer;
    begin
        restsales.DeleteAll;

        // Simple web service call
        HttpClient.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        if not HttpClient.Get('https://dkatsonpublicdatasource.blob.core.windows.net/machinelearning/AML-restaurant-sales-by-menu-item.json',
                              ResponseMessage)
        then
            Error('The call to the web service failed.');

        if not ResponseMessage.IsSuccessStatusCode then
            error('The web service returned an error message:\' +
                  'Status code: %1' +
                  'Description: %2',
                  ResponseMessage.HttpStatusCode,
                  ResponseMessage.ReasonPhrase);

        ResponseMessage.Content.ReadAs(JsonText);

        // Process JSON response
        if not JsonArray.ReadFrom(JsonText) then begin
            // probably single object
            JsonToken.ReadFrom(JsonText);
            Insertrestsales(JsonToken);
        end else begin
            // array
            for i := 0 to JsonArray.Count - 1 do begin
                JsonArray.Get(i, JsonToken);
                Insertrestsales(JsonToken);
            end;
        end;
    end;

    procedure Insertrestsales(JsonToken: JsonToken);
    var
        JsonObject: JsonObject;
        restsales: Record "AIR RestSalesEntry";
    begin
        JsonObject := JsonToken.AsObject;

        restsales.init;

        restsales."date" := GetJsonToken(JsonObject, 'date').AsValue.AsDate();
        restsales."menu_item" := COPYSTR(GetJsonToken(JsonObject, 'menu_item').AsValue.AsText, 1, 250);
        restsales."stock_count" := GetJsonToken(JsonObject, 'stock_count').AsValue.AsInteger;
        restsales."orders" := GetJsonToken(JsonObject, 'orders').AsValue.AsInteger;
        restsales."menu_item_id" := GetJsonToken(JsonObject, 'menu_item_id').AsValue.AsCode();
        restsales."in_children_menu" := GetJsonToken(JsonObject, 'in_children_menu').AsValue.AsBoolean();
        restsales."max_stock_quantity" := GetJsonToken(JsonObject, 'max_stock_quantity').AsValue.AsInteger;
        restsales."Children_Event" := YesNo2Boolean(GetJsonToken(JsonObject, 'Children_Event').AsValue.AsText());
        restsales."Music_Event" := YesNo2Boolean(GetJsonToken(JsonObject, 'Music_Event').AsValue.AsText());
        restsales."fest_name" := jsonWithNull2Text(GetJsonToken(JsonObject, 'fest_name').AsValue());

        restsales.Insert(true);
    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure SelectJsonToken(JsonObject: JsonObject; Path: text) JsonToken: JsonToken;
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            Error('Could not find a token with path %1', Path);
    end;

    local procedure YesNo2Boolean(YesNoText: Text[3]): Boolean
    begin
        case YesNoText of
            'Yes':
                exit(true);
            'No':
                exit(false);
        end;

    end;

    local procedure jsonWithNull2Text(someJsonValue: JsonValue): Text
    begin
        if someJsonValue.IsNull then
            exit('NA')
        else
            exit(someJsonValue.AsText());
    end;

    local procedure TextWithNull2Int(someText: Text): Integer
    begin
        if someText = 'NA' then
            exit(0)
        else
            exit(1);
    end;

    local procedure Boolean2Int(someBool: Boolean): Integer
    begin
        if someBool = false then
            exit(0)
        else
            exit(1)
    end;

}