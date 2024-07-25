namespace ML.Lab.CreateChart;
using System.AI;
using System.Reflection;
using System.Visualization;
codeunit 50100 "Create Chart - Copilot"
{
    trigger OnRun()
    begin

    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://www.mariolongo.com', locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Generate Chart") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Generate Chart", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;



    local procedure Generate(PageNo: Integer; UserPrompt: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        Result: Text;
        CapabilityEnabledErrorLbl: Label 'Generate chart capability is not enabled';
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Generate Chart") then
            Error(CapabilityEnabledErrorLbl);

        SetAuthoration(AzureOpenAI);
        AOAIChatCompletionParams.SetMaxTokens(5000);
        AOAIChatCompletionParams.SetTemperature(0);

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Generate Chart");
        AOAIChatMessages.AddSystemMessage(GetSystemPrompt(PageNo));

        AOAIChatMessages.AddUserMessage(UserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    [TryFunction]
    procedure GetData(PageNo: Integer; UserPrompt: Text; var pChartType: Enum "Business Chart Type"; var pFieldNoXAxis: Integer; var pFieldNoYAxis: Integer)
    var
        ChatCompletionResult: Text;
    begin
        ChatCompletionResult := Generate(PageNo, UserPrompt);
        GetJsonData(ChatCompletionResult, pChartType, pFieldNoXAxis, pFieldNoYAxis);
    end;

    local procedure SetAuthoration(var OpenAzureAI: Codeunit "Azure OpenAI")
    var
        Endpoint: Text;
        Deployment: Text;
        [NonDebuggable]
        APIKey: Text;
    begin
        IsolatedStorage.Get('AOAI-Endpoint', Endpoint);
        IsolatedStorage.Get('AOAI-Deployment', Deployment);
        IsolatedStorage.Get('AOAI-ApiKey', ApiKey);

        OpenAzureAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", Endpoint, Deployment, APIKey);
    end;

    local procedure GetSystemPrompt(PageNo: Integer): Text
    var
        SystemPrompt: TextBuilder;
    begin
        SystemPrompt.AppendLine('Determine the appropriate x-axis, y-axis fields and chart type for a Chart based on user input. ');
        SystemPrompt.Append('Your goal is not to generate the chart but only to extract the x-axis, y-axis, and chart type fields from the user input. ');
        SystemPrompt.Append('Possible Fields in CSV format:');
        SystemPrompt.AppendLine();
        GetFieldList(PageNo, SystemPrompt);
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('Possible Chart Types with description between bracket: ');
        SystemPrompt.AppendLine('Point (Uses points to represent data points.); Bubble (A variation of the Point chart type, where the data points are replaced by bubbles of different sizes.); ');
        SystemPrompt.Append('Line (Illustrates trends in data with the passing of time.); StepLine (Similar to the Line chart type, but uses vertical and horizontal lines to connect the data points in a series forming a step-like progression.); ');
        SystemPrompt.Append('Column (Uses a sequence of columns to compare values across categories.); StackedColumn (Used to compare the contribution of each value to a total across categories.); ');
        SystemPrompt.Append('StackedColumn100 (Displays multiple series of data as stacked columns. The cumulative proportion of each stacked element is always 100% of the Y axis.); ');
        SystemPrompt.Append('Area (Emphasizes the degree of change over time and shows the relationship of the parts to a whole.); StackedArea (An Area chart that stacks two or more data series on top of one another.); ');
        SystemPrompt.Append('StackedArea100 (Displays multiple series of data as stacked areas. The cumulative proportion of each stacked element is always 100% of the Y axis.); ');
        SystemPrompt.Append('Pie (Shows how proportions of data, shown as pie-shaped pieces, contribute to the data as a whole.); Doughnut (Similar to the Pie chart type, except that it has a hole in the center.); ');
        SystemPrompt.Append('Range (Displays a range of data by plotting two Y values per data point, with each Y value being drawn as a line chart.); ');
        SystemPrompt.Append('Radar (A circular chart that is used primarily as a data comparison tool.); Funnel (Displays in a funnel shape data that equals 100% when totaled.).');
        SystemPrompt.AppendLine('Output Requirements: the result must always be in JSON format without any additional text. ');
        SystemPrompt.Append('Use the following structure for the JSON output:');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('{');
        SystemPrompt.AppendLine('    "chartType": "Chart_type",');
        SystemPrompt.AppendLine('    "x_axis": FieldId_for_x_axis,');
        SystemPrompt.AppendLine('    "y_axis": FieldId_for_y_axis');
        SystemPrompt.AppendLine('}');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('The response MUST BE just the json as per the example without any other text or sentences.');

        exit(SystemPrompt.ToText())
    end;

    local procedure GetFieldList(pPageNo: Integer; var pSystemPrompt: TextBuilder)
    var
        PageCtrlField: Record "Page Control Field";
    begin
        pSystemPrompt.AppendLine('FieldName;FieldId');
        PageCtrlField.SetRange(PageNo, pPageNo);
        if PageCtrlField.FindSet() then
            repeat
                pSystemPrompt.AppendLine(PageCtrlField.SourceExpression + ';' + Format(PageCtrlField.FieldNo))
            until PageCtrlField.Next() = 0;
    end;

    local procedure GetJsonData(ChatCompletionOutput: Text; var pChartType: Enum "Business Chart Type"; var pFieldNoXAxis: Integer; var pFieldNoYAxis: Integer)
    var
        JsonObj: JsonObject;
        JsonToken: JsonToken;
    begin
        JsonObj.ReadFrom(ChatCompletionOutput);
        JsonObj.Get('chartType', JsonToken);
        pChartType := GetChartType(JsonToken.AsValue().AsText());
        JsonObj.Get('x_axis', JsonToken);
        pFieldNoXAxis := JsonToken.AsValue().AsInteger();
        JsonObj.Get('y_axis', JsonToken);
        pFieldNoYAxis := JsonToken.AsValue().AsInteger();
    end;

    local procedure GetChartType(ChartTypeTxt: Text): Enum "Business Chart Type"
    begin

        case ChartTypeTxt of
            'Point':
                exit(Enum::"Business Chart Type"::Point);
            'Bubble':
                exit(Enum::"Business Chart Type"::Bubble);
            'Line':
                exit(Enum::"Business Chart Type"::Line);
            'StepLine':
                exit(Enum::"Business Chart Type"::StepLine);
            'Column':
                exit(Enum::"Business Chart Type"::Column);
            'StackedColumn':
                exit(Enum::"Business Chart Type"::StackedColumn);
            'StackedColumn100':
                exit(Enum::"Business Chart Type"::StackedColumn100);
            'Area':
                exit(Enum::"Business Chart Type"::"Area");
            'StackedArea':
                exit(Enum::"Business Chart Type"::StackedArea);
            'StackedArea100':
                exit(Enum::"Business Chart Type"::StackedArea100);
            'Pie':
                exit(Enum::"Business Chart Type"::Pie);
            'Doughnut':
                exit(Enum::"Business Chart Type"::Doughnut);
            'Range':
                exit(Enum::"Business Chart Type"::Range);
            'Radar':
                exit(Enum::"Business Chart Type"::Radar);
            'Funnel':
                exit(Enum::"Business Chart Type"::Funnel);

        end;
    end;

    procedure GetTableId(pPageNo: Integer): Integer
    var
        PageCtrlField: Record "Page Control Field";
    begin
        PageCtrlField.SetRange(PageNo, pPageNo);
        PageCtrlField.FindFirst();
        exit(PageCtrlField.TableNo)
    end;

}