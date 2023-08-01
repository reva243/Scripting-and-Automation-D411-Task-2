#Rhaje Evans-Harris         Student ID: 010765647

try {
    $sqlServerInstanceName = "SRV19-PRIMARY\SQLEXPRESS"
    $databaseName = "ClientDB"

    # Check for the existence of the database
    $databaseExists = Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "SELECT COUNT(*) FROM sys.databases WHERE name = '$databaseName'"
    
    if ($databaseExists -eq 1) {
        Write-Host "The database '$databaseName' already exists. Deleting it..."
        Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "DROP DATABASE [$databaseName]"
        Write-Host "The database '$databaseName' has been deleted."
    }
    
    # Create the new database
    Write-Host "Creating the database '$databaseName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "CREATE DATABASE [$databaseName]"
    Write-Host "The database '$databaseName' has been created."
    
    # Create the new table
    $tableName = "Client_A_Contacts"
    $tableScript = @"
CREATE TABLE [$databaseName].[dbo].[$tableName]
(
    First_Name varchar(100),
    Last_Name varchar(100),
    City varchar(50),
    County varchar(50),
    Zip varchar(20),
    OfficePhone varchar(15),
    MobilePhone varchar(15)
)
"@
    Write-Host "Creating the table '$tableName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $tableScript
    Write-Host "The table '$tableName' has been created."
    
    # Insert data from the CSV file
    $csvPath = Join-Path $PSScriptRoot "NewClientData.csv"
    $insertScript = @"
BULK INSERT [$databaseName].[dbo].[$tableName]
FROM '$csvPath'
WITH (FORMAT = 'CSV', FIRSTROW = 2)
"@
    Write-Host "Inserting data from '$csvPath' into '$tableName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $insertScript
    Write-Host "Data has been inserted into '$tableName'."
    
    # Generate the output file
    $outputFilePath = Join-Path $PSScriptRoot "SqlResults.txt"
    $outputScript = "SELECT * FROM [$databaseName].[dbo].[$tableName]"
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $outputScript | Out-File -FilePath $outputFilePath -Encoding UTF8
    Write-Host "The 'SqlResults.txt' file has been generated."
}
catch {
    Write-Host "An error occurred: $_"
}
