page 50100 "AIR RestSalesEntries"
{
    PageType = List;
    SourceTable = "AIR RestSalesEntry";
    CaptionML = ENU = 'List of restsales';
    Editable = false;
    SourceTableView = order(descending);
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(date; "date")
                {
                    ApplicationArea = All;
                }
                field("menu_item_id"; "menu_item_id")
                {
                    ApplicationArea = All;
                }
                field(orders; "orders")
                {
                    ApplicationArea = All;
                }
                field("s_go_list"; "s_go_list")
                {
                    ApplicationArea = All;
                }

                field("menu_item"; "menu_item")
                {
                    ApplicationArea = All;
                }
                field("max_stock_quantity"; "max_stock_quantity")
                {
                    ApplicationArea = All;
                }

                field("stock_count"; "stock_count")
                {
                    ApplicationArea = All;
                }
                field("in_children_menu"; "in_children_menu")
                {
                    ApplicationArea = All;
                }
                field("Children_Event"; "Children_Event")
                {
                    ApplicationArea = All;
                }
                field("Music_Event"; "Music_Event")
                {
                    ApplicationArea = All;
                }
                field("fest_name"; "fest_name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Refreshrestsales)
            {
                CaptionML = ENU = 'Refresh restsales';
                Promoted = true;
                PromotedCategory = Process;
                Image = RefreshLines;
                ApplicationArea = All;
                trigger OnAction();
                begin
                    RefreshRestSales();
                    CurrPage.Update;
                    if FindFirst then;
                end;
            }
        }
    }
}