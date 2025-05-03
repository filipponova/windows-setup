# Check if winget is available
function Find-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Output "Winget is not installed. Please install it first."
        exit 1
    }
}

# Validate the existence of the packages file
function Find-PackagesFile {
    param (
        [string]$FilePath
    )
    if (-not (Test-Path $FilePath)) {
        Write-Output "$FilePath file not found. Please create it with the list of packages."
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
function Add-Package {
    param (
        [string]$PackageName
    )
    Write-Output "Installing $PackageName..."
    try {
        winget install --id $PackageName --silent --accept-source-agreements --disable-interactivity --accept-package-agreements --source winget
    } catch {
        Write-Output "Failed to install $PackageName"
    }
}

# Main script logic
function Main {
    Find-Winget

    $packageListFile = ".\packages.txt"
    Find-PackagesFile -FilePath $packageListFile

    $packages = Get-Content $packageListFile | Where-Object { $_ -and $_.Trim() -ne "" }

    foreach ($package in $packages) {
        Write-Output "Checking if $package is already installed..."
        if (Get-PackageInstalled -PackageName $package) {
            Write-Output "$package is already installed. Skipping..."
            continue
        }
        Add-Package -PackageName $package
    }

    Write-Output "All done!"
}

# Execute the main function
Main