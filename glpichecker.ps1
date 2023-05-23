# Variables :
    $Server = "your_server_name_here"
    $Database = "your_database_name_here"
    $username = "your_readonly_user_here"
    $password = ConvertTo-SecureString "your_readonly_user's_password_here" -AsPlainText -Force

function Get-GLPIData {
    $credential = New-Object System.Management.Automation.PSCredential ($username,$password)
    $Query = "select name from glpi_ipaddresses where mainitemtype = 'computer' and version ='4' and name != '127.0.0.1'"
    $result = New-Object System.Collections.ArrayList
    Open-MySqlConnection -Server $Server -Database $Database -Credential $credential
    $data = $(Invoke-SqlQuery -Query $Query)
    Close-SqlConnection
    foreach ($element in $data){
        [void]$result.Add($element.Item(0))
    }
    return $result
}

function Get-Computerpark {
    param(
        [string]$InjectSQLData
    )
    $computersWithIP = @()
    $computersWithoutIP = @()
    $resp = ""
    $computers = Get-ADComputer -Filter * -Properties IPv4Address
    foreach ($computer in $computers) {
        if ($computer.IPv4Address) {
            $computersWithIP += $computer
        } else {
            $computersWithoutIP += $computer
        }
    }
    # Afficher les ordinateurs avec une adresse IP
    Write-Host "Ordinateurs avec une adresse IP :" -ForegroundColor Yellow
    foreach ($element in $computersWithIP){
        if($element.IPv4Address -in $InjectSQLData.Split(" ")){
            $element | Add-Member -Force GLPI Present
        }
        else{
            $element | Add-Member -Force GLPI Absent
        }
    }
    $computersWithIP | Format-Table -AutoSize Name, IPv4Address, @{
        Label = "GLPI"
        Expression = {
            switch ($_.GLPI){
                'Present' { $color = '92' }
                'Absent' { $color = '91' }
                default { $color = '93' }
            }
            $e=[char]27
            "$e[${color}m$($_.GLPI)${e}[0m" 
        }
    }
    Start-Sleep -Seconds 2
    # Afficher les ordinateurs sans adresse IP
    Write-Host "Ordinateurs sans adresse IP :" -ForegroundColor Yellow
    $computersWithoutIP | Select-Object Name | Format-Table -AutoSize
    Start-Sleep -Seconds 2
    Write-Host 'Terminé' -ForegroundColor Yellow
    Write-Host ""
    While ($resp -notin @("Y", "y", "N", "n")) {
        $resp = Read-Host "Voulez-vous exporter les données en CSV ? [Y/N]"
        if ( $resp -in @('Y', 'y') ) {
            $FilePath = Read-Host "Entrez le chemin du fichier à enregistrer "
            $computersWithIP | Select-Object -Property Name, IPv4Address, GLPI | Export-CSV -Path $FilePath -NoTypeInformation
        }
        elseif ( $resp -in @('N', 'n') ) {
            Write-Host "Le programme va quitter."
        }
    }
}

Write-Host -ForegroundColor Red '         .__           .__               .__                     __                   '
Write-Host -ForegroundColor Red '   ____  |  |  ______  |__|        ____  |  |__    ____   ____  |  | __  ____ _______ '
Write-Host -ForegroundColor Red '  / ___\ |  |  \____ \ |  |      _/ ___\ |  |  \ _/ __ \_/ ___\ |  |/ /_/ __ \\_  __ \'
Write-Host -ForegroundColor Red ' / /_/  >|  |__|  |_> >|  |      \  \___ |   Y  \\  ___/\  \___ |    < \  ___/ |  | \/'
Write-Host -ForegroundColor Red ' \___  / |____/|   __/ |__|       \___  >|___|  / \___  >\___  >|__|_ \ \___  >|__|   '
Write-Host -ForegroundColor Red '/_____/        |__|                   \/      \/      \/     \/      \/     \/        '
Write-Host -ForegroundColor Red '                                                                      By Gabriel Morin'
Write-Host ''
Start-Sleep -Seconds 1
if (Get-Module -ListAvailable -Name SimplySql) {
    Write-Host "Le module SimplySQL est installé."
    Write-Host ''
    Start-Sleep -Seconds 1
    Import-Module SimplySql
    $glpiData = Get-GLPIData
    Get-Computerpark -InjectSQLData $glpiData 
} 
else {
    Write-Host "Le module SimplySQL n'est pas installé."
    Write-Host "Vous pouvez l'installer en utilisant la commande 'Install-Module SimplySQL'."
    Start-Sleep -Seconds 2
    Exit
}
