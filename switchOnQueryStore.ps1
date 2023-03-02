Function SwitchOnQueryStore {
    param (
        $SqlServerName = "XXXXXX"
    )

    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServerName)

    foreach ($Database in (
            $SqlServer.Databases `
            | Where-Object { $_.owner -eq [System.Security.Principal.WindowsIdentity]::GetCurrent().Name })) {

        $database_name = $Database.Name

        try {

            if (-not (Get-Module -Name "sqlserver")) {
                Import-Module sqlserver
            }

            Invoke-Sqlcmd -ServerInstance $SqlServerName `
                -Query ("ALTER DATABASE $database_name SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE)")
        }
        catch {
            "Error occurred when running $_"
        }
        
    }
}