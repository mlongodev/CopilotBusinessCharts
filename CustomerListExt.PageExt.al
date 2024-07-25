namespace CopilotBusinessCharts.CopilotBusinessCharts;

using Microsoft.Sales.Customer;
using ML.Lab.CreateChart;
using System.Visualization;

pageextension 50100 "Customer List - Ext." extends "Customer List"
{
    actions
    {
        addafter(Sales)
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
