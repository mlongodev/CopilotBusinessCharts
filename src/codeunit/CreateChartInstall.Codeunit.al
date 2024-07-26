namespace ML.Lab.CreateChart;

codeunit 50101 "Create Chart - Install"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    var
        CreateChartCopilot: Codeunit "Create Chart - Copilot";
    begin
        CreateChartCopilot.RegisterCapability();
    end;

}
