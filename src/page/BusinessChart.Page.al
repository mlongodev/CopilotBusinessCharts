namespace ML.Lab.CreateChart;
using System.Integration;
using System.Visualization;

page 50132 "Business Chart"
{
    PageType = CardPart;
    Caption = 'Business Chart';
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            usercontrol(Chart; BusinessChart)
            {
                ApplicationArea = All;
                trigger AddInReady()
                begin

                end;
            }
        }
    }

    local procedure GetDataType(FieldRefAxis: FieldRef): Option
    var
        ErrorDataTypeLbl: Label 'The data type %1 is not supported.';
    begin
        case FieldRefAxis.Type of
            FieldRefAxis.Type::Integer:
                exit(TempBuffer."Data Type"::Integer);
            FieldRefAxis.Type::Decimal:
                exit(TempBuffer."Data Type"::Decimal);
            FieldRefAxis.Type::Code, FieldRefAxis.Type::Text:
                exit(TempBuffer."Data Type"::String);
            FieldRefAxis.Type::DateTime, FieldRefAxis.Type::Date:
                exit(TempBuffer."Data Type"::DateTime)
            else
                Error(ErrorDataTypeLbl, FieldRefAxis.Type);
        end;

    end;

    procedure SetParameters(pTableId: Integer; pChartType: Enum "Business Chart Type"; pFieldNoXAxis: Integer; pFieldNoYAxis: Integer)
    begin
        TableId := pTableId;
        FieldNoXAxis := pFieldNoXAxis;
        FieldNoYAxis := pFieldNoYAxis;
        ChartType := pChartType;
    end;

    procedure Load()
    var
        RecRef: RecordRef;
        FieldRefYAxis: FieldRef;
        FieldRefXAxis: FieldRef;
        i: Integer;
        MaxNumMeasures: Integer;
    begin
        if TableId = 0 then
            exit;

        TempBuffer.Initialize();
        RecRef.OPEN(TableId);

        FieldRefYAxis := RecRef.Field(FieldNoYAxis);
        FieldRefXAxis := RecRef.Field(FieldNoXAxis);

        TempBuffer.AddMeasure(FieldRefYAxis.Name, 1, GetDataType(FieldRefYAxis), ChartType.AsInteger());
        TempBuffer.SetXAxis(FieldRefXAxis.Name, GetDataType(FieldRefXAxis));
        MaxNumMeasures := TempBuffer.GetMaxNumberOfMeasures();
        if RecRef.FindSet() then
            repeat
                i += 1;
                FieldRefYAxis := RecRef.Field(FieldNoYAxis);
                if FieldRefYAxis.Class = FieldRefYAxis.Class::FlowField then
                    FieldRefYAxis.CalcField();
                FieldRefXAxis := RecRef.FIELD(FieldNoXAxis);
                TempBuffer.AddColumn(FieldRefXAxis.Value);
                TempBuffer.SetValueByIndex(0, i - 1, FieldRefYAxis.Value());
            until (MaxNumMeasures = 0) or (RecRef.Next() = 0);

        TempBuffer.UpdateChart(CurrPage.Chart);
        RecRef.Close();
    end;

    var
        TempBuffer: Record "Business Chart Buffer" temporary;
        TableId: Integer;
        ChartType: Enum "Business Chart Type";
        FieldNoYAxis: Integer;
        FieldNoXAxis: Integer;
}