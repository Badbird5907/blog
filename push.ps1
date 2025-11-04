param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Message
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
  param([string[]]$Arguments)
  git @Arguments
}

try {
  # First repo
  Invoke-Git @('add', '.')
  try {
    Invoke-Git @('commit', '-m', $Message)
  } catch {
    Write-Host "No changes to commit in first repo (or commit failed). Continuing..." -ForegroundColor Yellow
  }
  Invoke-Git @('push')

  # Parent dir, then content in parent repo
  Push-Location ..
  try {
    # Stage changes to 'content/' if it exists
    if (Test-Path -Path 'content') {
      Invoke-Git @('add', 'content/')
    } else {
      Write-Host "Warning: 'content/' not found in parent directory." -ForegroundColor Yellow
    }

    try {
      Invoke-Git @('commit', '-m', 'chore: update blog content')
    } catch {
      Write-Host "No changes to commit in parent repo (or commit failed). Continuing..." -ForegroundColor Yellow
    }

    Invoke-Git @('push')
  } finally {
    Pop-Location
  }
}
catch {
  Write-Error $_
  exit 1
}
