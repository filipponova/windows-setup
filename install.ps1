# Check if winget is available
function Find-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget is not installed. Please install it first." -ForegroundColor Red
        exit 1
    }
}

# Validate the existence of the packages file
function Find-PackagesFile {
    param (
        [string]$FilePath
    )
    if (-not (Test-Path $FilePath)) {
        Write-Host "$FilePath file not found. Please create it with the list of packages." -ForegroundColor Red
        exit 1
    }
}

# Check if a package is already installed
function Get-PackageInstalled {
    param (
        [string]$PackageName
    )
    $isInstalled = winget list --id $PackageName -ErrorAction SilentlyContinue | Out-String
    return $isInstalled -match $PackageName
}

# Install a package
function Install-Package {
    param (
        [string]$PackageName
    )
    Write-Host "Installing $PackageName..." -ForegroundColor Cyan
    try {
        winget install --id $PackageName --silent --accept-source-agreements --accept-package-agreements --source winget
    } catch {
        Write-Host "Failed to install $PackageName" -ForegroundColor Red
    }
}

# Main script logic
function Main {
    Find-Winget

    $packageListFile = ".\packages.txt"
    Find-PackagesFile -FilePath $packageListFile

    $packages = Get-Content $packageListFile | Where-Object { $_ -and $_.Trim() -ne "" }

    foreach ($package in $packages) {
        Write-Host "Checking if $package is already installed..." -ForegroundColor Yellow
        if (Get-PackageInstalled -PackageName $package) {
            Write-Host "$package is already installed. Skipping..." -ForegroundColor Green
            continue
        }
        Install-Package -PackageName $package
    }

    Write-Host "All done!" -ForegroundColor Green
}

# Execute the main function
Main