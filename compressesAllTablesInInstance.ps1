function inportModuleSql {

    if (-not (Get-Module -Name "sqlserver")) {
        Import-Module sqlserver -Verbose
    }
}
  
function createFolder {
    [CmdletBinding()]
    param(
        $global:path = 'C:\Users\compressTables\'
    )

    try {
        New-Item -Path "$path" -ItemType Directory -ErrorAction Stop -Verbose
    }
    catch {
        Write-Host $Error[0] -ForegroundColor Red 
    }
      
}
      
function compressTables {
    [cmdletbinding()]
    param (
        ${SqlServerName} = "SERVER_HD_ETL",
        ${user} = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        ${delim} = ";"
    )
  
    createFolder   
    inportModuleSql 
  
    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server(${SqlServerName}) 
      
    foreach ($Database in (
            $SqlServer.Databases | 
            Where-Object { $_.owner -eq ${user} })) {
      
        ${database_name} = $Database.Name
      
        $Database.Tables | 
        Select-Object @{Name = "DatabaseName"; Expression = { $Database.Name } },
        @{Name = "SchemaName"; Expression = { $_.Schema } },
        @{Name = "TableName"; Expression = { $_.Name } } `
        | ConvertTo-Csv -Delimiter ${delim} `
        | Select-object -skip 1 `
        | Add-Content -Path (${path} + ${database_name} + ".csv") -Verbose
      
      
        Import-Csv -Path (${path} + ${database_name} + ".csv") -Delimiter ';' -Verbose | `
            Foreach-object {
      
            ${fullTableNameSql} = $_.DatabaseName + "." + $_.SchemaName + "." + $_.TableName 
            Write-Host ${fullTableNameSql} -BackgroundColor Cyan
      
            Try {
     
                Invoke-Sqlcmd -ServerInstance ${SqlServerName} -Database ${database_name} `
                    -Query ("ALTER TABLE ${fullTableNameSql} REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
                  GO 
                  EXEC sp_spaceused N'${fullTableNameSql}';
                  GO") | Export-Csv -Path (${path} + ${database_name} + "infoCompress.csv") -NoTypeInformation -UseCulture
            }
            Catch {
                Write-Host $Error[0] -ForegroundColor Red 
            }
        } 
    } 
}