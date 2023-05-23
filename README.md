# glpichecker
Outil écrit en PowerShell pour comparer les machines présentes dans un AD avec les machines remontées dans GLPI.

# Installation :
Renseigner les informations comme suit dans le script avant de le lancer.
```
# Variables :
$Server = "put_your_server_here"
$Database = "put_your_database_here"
$username = "your_readonly_user_here"
$password = ConvertTo-Securestring "your_readonly_user's_password_here" -AsPlainText -Force
```
N'oubliez pas d'installer le module SimplySql depuis PowerShell Gallery ! Le script vous le rappellera ;)

# Utilisation
Lancez le script. 
Ce dernier va aller comparer les addresses IP des machines remontées dans GLPI avec celles disponibles dans votre AD, et vous renvoyer l'état des découvertes (Présent/Absent de GLPI). 
Vous pouvez choisir d'exporter le résultat sous la forme d'un fichier CSV.
