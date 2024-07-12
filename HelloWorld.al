// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

namespace DefaultPublisher.BusinessCharts;

using Microsoft.Sales.Customer;
using System.Integration;
using Microsoft.Inventory.Item;
using System.Visualization;

page 50132 "Test Chart"
{
    PageType = Card;
    Caption = 'Test Chart';
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            usercontrol(Chart; BusinessChart)
            {
                ApplicationArea = All;
                /*
                trigger DataPointClicked(point: JsonObject)
                var
                    JsonTxt: Text;
                begin
                    point.WriteTo(JsonTxt);
                    Message('%1', JsonTxt);
                end;
                
                trigger AddInReady()
                var
                    Buffer: Record "Business Chart Buffer" temporary;
                    Customer: Record Customer;
                    i: Integer;
                begin
                    Buffer.Initialize();
                    Buffer.AddMeasure('Sales', 1, Buffer."Data Type"::Decimal, Buffer."Chart Type"::Column); //Parameters: data type, chart type (asse y)
                    Buffer.SetXAxis('Customer', Buffer."Data Type"::String); //Parameters: data type  (asse x)

                    if Customer.FindSet(false) then
                        repeat
                            Customer.CalcFields("Sales (LCY)", "Profit (LCY)");
                            if Customer."Sales (LCY)" <> 0 then begin
                                Buffer.AddColumn(Customer.Name);
                                Buffer.SetValueByIndex(0, i, Customer."Sales (LCY)");
                                i += 1;
                            end;
                        until Customer.Next() = 0;

                    Buffer.UpdateChart(CurrPage.Chart);
                end;
                */

                trigger AddInReady()
                var
                    Buffer: Record "Business Chart Buffer" temporary;
                    RecRef: RecordRef;
                    FieldRefYAxis: FieldRef;
                    FieldRefXAxis: FieldRef;
                    i: Integer;
                    TableID: Integer;
                    FieldNoYAxis: Integer;
                    FieldNoXAxis: Integer;
                    MaxNumMeasures: Integer;
                    ChartType: Enum "Business Chart Type";
                begin
                    //Parameters
                    ChartType := ChartType::Column;
                    TableID := DATABASE::Item;
                    FieldNoYAxis := 68;
                    FieldNoXAxis := 1;

                    RecRef.OPEN(TableID);

                    FieldRefYAxis := RecRef.Field(FieldNoYAxis);
                    FieldRefXAxis := RecRef.Field(FieldNoXAxis);

                    Buffer.Initialize();
                    Buffer.AddMeasure(FieldRefYAxis.Caption, 1, GetDataType(FieldRefYAxis), ChartType.AsInteger());
                    Buffer.SetXAxis(FieldRefXAxis.Caption, GetDataType(FieldRefXAxis));
                    MaxNumMeasures := Buffer.GetMaxNumberOfMeasures();

                    if RecRef.FindSet() then
                        repeat
                            i += 1;
                            FieldRefYAxis := RecRef.Field(FieldNoYAxis);
                            if FieldRefYAxis.Class = FieldRefYAxis.Class::FlowField then
                                FieldRefYAxis.CalcField();
                            FieldRefXAxis := RecRef.FIELD(FieldNoXAxis);
                            Buffer.AddColumn(FieldRefXAxis.Value);
                            Buffer.SetValueByIndex(0, i - 1, FieldRefYAxis.Value());
                        until (MaxNumMeasures = 0) or (RecRef.Next() = 0);

                    Buffer.UpdateChart(CurrPage.Chart);
                    RecRef.Close();
                end;
            }
        }
    }

    local procedure GetDataType(FieldRefAxis: FieldRef): Option
    var
        Buffer: Record "Business Chart Buffer" temporary;
        ErrorDataTypeLbl: Label 'The data type %1 is not supported.';
    begin
        case FieldRefAxis.Type of
            FieldRefAxis.Type::Integer:
                exit(Buffer."Data Type"::Integer);
            FieldRefAxis.Type::Decimal:
                exit(Buffer."Data Type"::Decimal);
            FieldRefAxis.Type::Code, FieldRefAxis.Type::Text:
                exit(Buffer."Data Type"::String);
            FieldRefAxis.Type::DateTime, FieldRefAxis.Type::Date:
                exit(Buffer."Data Type"::DateTime)
            else
                Error(ErrorDataTypeLbl, FieldRefAxis.Type);
        end;


    end;
}