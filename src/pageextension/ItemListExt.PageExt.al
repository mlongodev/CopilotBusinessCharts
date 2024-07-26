namespace ML.Lab.CreateChart;
using Microsoft.Inventory.Item;

pageextension 50101 "Item List Ext." extends "Item List"
{
    actions
    {
        addafter(ApplyTemplate)
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
                    CreateChartCopilot.SetPageNo(Page::"Item List");
                    CreateChartCopilot.RunModal();
                end;
            }
        }
    }
}
