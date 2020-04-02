# author: Orlando Rocha
# email: ornrocha@gmail.com
# Modified by Levi Sands; March 2020; ldsands@outlook.com

$ProgressPreference = 'SilentlyContinue'

# This function is from https://scatteredcode.net/download-and-extract-gzip-tar-with-powershell/
Function DeGZip-File {
    Param(
        $infile,
        $outfile = ($infile -replace '\.gz$', '')
    )
    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
    $buffer = New-Object byte[](1024)
    while ($true) {
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0) { break }
        $output.Write($buffer, 0, $read)
    }
    $gzipStream.Close()
    $output.Close()
    $input.Close()
}

# Taken from https://community.spiceworks.com/topic/2203658-check-if-choco-already-installed-and-install-if-not
function installChocolatey {
    $testchoco = powershell choco -v
    if(-not($testchoco)){
        Write-Output "Seems Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else{
        Write-Output "Chocolatey Version $testchoco is already installed"
    }
}

function check_if_installed($p1) {
    $software = $p1;
    $installed = ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match $p1).Length -gt 0
    If (-Not $installed) {
        Write-Host "'$software'  is not installed.";
    }
    else {
        Write-Host "'$software' is installed."
    }
    return $installed
}

function Install7Zip4PowerShell {
    if (-not (Get-Module -ListAvailable -Name 7Zip4PowerShell)) {
        Set-PsRepository -Name PSGallery -InstallationPolicy Trusted
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
        Install-Module -Name 7Zip4PowerShell
        Import-Module PowerShellGet
    }
}

function installscala() {
    $scala = check_if_installed -p1 "Scala"
    if (-Not $scala) {
        Write-Host 'Downloading Scala 2.11.12...'
        Invoke-WebRequest https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.msi -OutFile "$env:TEMP\scala-2.11.12.msi"
        $TemptFiles += "$env:TEMP\scala-2.11.12.msi"
        Write-Host 'Installing Scala 2.11.12...'
        Start-Process msiexec.exe -Wait -ArgumentList "/I `"$env:TEMP\scala-2.11.12.msi`" "
    }
    else {
        Write-Host 'Scala is already installed'
    }
}

function installmaven() {
    $tempArchive = "$env:TEMP\apache-maven-3.6.2-bin"
    Write-Host "Downloading Maven..."
    Invoke-WebRequest -Uri https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.zip -OutFile "$($tempArchive).zip"
    Write-Host "Decompressing archive..."
    Expand-7Zip "$($tempArchive).zip" "$env:TEMP\apache-maven-3.6.2-bin"
    Copy-Item -Path "$($tempArchive)\apache-maven-3.6.2" -Destination C:\bin\maven -recurse -Force
    Write-Host "Maven installation is complete." -ForegroundColor Green
}

function installjava() {
    $java = (Get-Command java | Select-Object -ExpandProperty Version).Length -gt 0
    if (-Not $java) {
        Write-Host "Java is not installed.";
        Write-Host 'Downloading Java... '
        Invoke-WebRequest https://download.bell-sw.com/java/8u222/bellsoft-jdk8u222-windows-amd64.msi -OutFile "$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi"
        $TemptFiles += "$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi"
        Write-Host 'Installing Java jdk8u222...'
        Start-Process msiexec.exe -Wait -ArgumentList "/I `"$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi`" "
        Write-Host "Java installation is complete." -ForegroundColor Green
    }
    else {
        Write-Host 'Java is already installed'
    }
}

function installhadoopwinutils() {
    $tempArchive = "$env:TEMP\hadoop-winutils"
    Write-Host "Downloading Hadoop Winutils..."
    Invoke-WebRequest -Uri https://github.com/steveloughran/winutils/archive/master.zip -OutFile "$($tempArchive).zip"
    Write-Host "Decompressing archive..."
    Expand-7Zip "$($tempArchive).zip" "$env:TEMP\tmp-hadoop-winutils"
    Copy-Item -Path "$env:TEMP\tmp-hadoop-winutils\winutils-master\hadoop-2.7.1" -Destination C:\bin\hadoop -recurse -Force
    Write-Host "Hadoop installation is complete." -ForegroundColor Green
}

function installspark() {
    $tempArchive = "$env:TEMP\spark-2.4.5-bin-hadoop2.7"
    Write-Host "Downloading Spark 2.4.5..."
    Invoke-WebRequest -Uri https://apache.mirrors.lucidnetworks.net/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz -OutFile "$($tempArchive).tgz"
    $TemptFiles += "$($tempArchive).tar"
    Write-Host "Decompressing archive..."
    DeGZip-File "$($tempArchive).tgz" "$($tempArchive).tar"
    Expand-7Zip "$($tempArchive).tar" "C:\bin"
    Rename-Item C:\bin\spark-2.4.5-bin-hadoop2.7 C:\bin\spark
    Write-Host "Spark installation is complete." -ForegroundColor Green
}

# I should probably add something to this to uninstall chocolatey once this is done if they didn't have it before
function dotnetInstall($dotnetInstall) {
    $dotnetCheck = check_if_installed -p1 "Microsoft .NET Core Host - 3.1"
    if (-Not $dotnetCheck) {
        installChocolatey
        choco install dotnetcore-sdk -y
        Write-Host ".NET Core has been installed please reboot after the script has completed and rerun the script to install other dotnet requirements"
    }
}

function dotnetExtras() {
    $dotnetCheck = check_if_installed -p1 "Microsoft .NET Core Host - 3.1"
    if (-Not $dotnetCheck) {
        dotnet add package Microsoft.Spark
    }
}

function setenvvars() {
    Write-Host "Setting environment variables..."
    [System.Environment]::SetEnvironmentVariable('MAVEN_HOME', "C:\bin\maven\bin", [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('HADOOP_HOME', "C:\bin\hadoop", [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('SPARK_HOME', "C:\bin\spark\", [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('Path', $env:Path + ";%MAVEN_HOME%;%SPARK_HOME%\bin;%HADOOP_HOME%\bin", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Settings are complete." -ForegroundColor Green
}

# get the user options (this should really be in a function)
$dotnetInstall = $null;
while (@('y', 'n') -notcontains $dotnetInstall) {
    $dotnetInstall = (Read-Host -Prompt 'Do you want to install what is needed for using .NET for Apache Spark? [y/n]').ToLower();
}
$ScalaInstall = $null;
while (@('y', 'n') -notcontains $ScalaInstall) {
    $ScalaInstall = (Read-Host -Prompt 'Do you want to install what is needed for using Spark in Scala? [y/n]').ToLower();
}

Install7Zip4PowerShell
installjava
installmaven
installhadoopwinutils
installspark
setenvvars

if ($ScalaInstall -eq 'y') {
    installscala
}

if ($dotnetInstall -eq 'y') {
    dotnetInstall
    dotnetExtras
}

Write-Host "Spark installation is finished." -ForegroundColor Green
