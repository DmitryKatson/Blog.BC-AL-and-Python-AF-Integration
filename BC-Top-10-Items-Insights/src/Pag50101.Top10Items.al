page 50101 "AIR Top 10 Items"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Top Customers By Sales Buffer";
    Caption = 'Top 10 Items';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CustomerName; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Item Description';
                }
                field(SalesLCY; SalesLCY)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}