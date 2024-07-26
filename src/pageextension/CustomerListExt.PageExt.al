namespace ML.Lab.CreateChart;
using Microsoft.Sales.Customer;

pageextension 50100 "Customer List - Ext." extends "Customer List"
{
    actions
    {
        addafter(WordTemplate)
        {
            action(CreateChart)
            {
                ApplicationArea = All;
                Caption = 'Create Chart';
                Image = Sparkle;

                trigger OnAction()
                var
                    CreateChartCopilot: Page "Create Chart - Copilot";
                begin
                    CreateChartCopilot.SetPageNo(Page::"Customer List");
                    CreateChartCopilot.RunModal();
                end;
            }
        }
    }
}
