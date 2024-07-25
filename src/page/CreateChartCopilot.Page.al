namespace ML.Lab.CreateChart;
using Microsoft.Utilities;
using System.Visualization;

page 50100 "Create Chart - Copilot"
{
    PageType = PromptDialog;
    Extensible = false;
    ApplicationArea = All;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    Caption = 'Create Chart - Copilot';
    IsPreview = true;

    layout
    {
        area(Prompt)
        {

            field(UserInput; UserInput)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }
        area(Content)
        {
            part(Chart; "Business Chart")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                trigger OnAction()
                var
                    CreateChartCopilot: Codeunit "Create Chart - Copilot";
                begin
                    CreateChartCopilot.GetData(PageNo, UserInput, ChartType, FieldNoXAxis, FieldNoYAxis);
                    CurrPage.Chart.Page.SetParameters(CreateChartCopilot.GetTableId(PageNo), ChartType, FieldNoXAxis, FieldNoYAxis);
                    CurrPage.Chart.Page.Load();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Add suggestion to the database.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard suggestion proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate proposal with Dynamics 365 Copilot.';
                trigger OnAction()
                var
                    CreateChartCopilot: Codeunit "Create Chart - Copilot";
                begin
                    CreateChartCopilot.GetData(PageNo, UserInput, ChartType, FieldNoXAxis, FieldNoYAxis);
                    CurrPage.Chart.Page.SetParameters(CreateChartCopilot.GetTableId(PageNo), ChartType, FieldNoXAxis, FieldNoYAxis);
                    CurrPage.Chart.Page.Load();
                end;
            }
        }
    }
    procedure SetPageNo(pPageNo: Integer)
    begin
        PageNo := pPageNo;
    end;

    var
        UserInput: Text;
        PageNo: Integer;
        ChartType: Enum "Business Chart Type";

        FieldNoXAxis: Integer;

        FieldNoYAxis: Integer;

}