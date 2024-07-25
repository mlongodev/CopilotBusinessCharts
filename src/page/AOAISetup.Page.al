namespace ML.Lab.CreateChart;
page 50101 "AOAI Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Endpoint; Endpoint)
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint';

                    trigger OnValidate()
                    begin
                        IsolatedStorage.Set('AOAI-Endpoint', Endpoint);
                    end;

                }
                field(Deployment; Deployment)
                {
                    ApplicationArea = All;
                    Caption = 'Deployment';

                    trigger OnValidate()
                    begin
                        IsolatedStorage.Set('AOAI-Deployment', Deployment);
                    end;

                }
                field(ApiKey; ApiKey)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Caption = 'ApiKey';

                    trigger OnValidate()
                    begin
                        IsolatedStorage.Set('AOAI-ApiKey', ApiKey);
                    end;

                }
            }
        }
    }

    var
        Endpoint: Text;
        Deployment: Text;
        [NonDebuggable]
        ApiKey: Text;

    trigger OnInit()
    begin
        if IsolatedStorage.Get('AOAI-Endpoint', Endpoint) then;
        if IsolatedStorage.Get('AOAI-Deployment', Deployment) then;
        if IsolatedStorage.Get('AOAI-ApiKey', ApiKey) then;
    end;
}