$ErrorActionPreference = 'Stop'

Set-Location -LiteralPath $PSScriptRoot

$rubyCommand = Get-Command ruby -ErrorAction SilentlyContinue
$rubyBin = if ($rubyCommand) {
    Split-Path -Parent $rubyCommand.Source
} elseif (Test-Path -LiteralPath 'C:\Ruby40-x64\bin\ruby.exe') {
    'C:\Ruby40-x64\bin'
} else {
    throw 'Ruby is not installed. Install Ruby+Devkit for Windows, then run this script again.'
}

$rubyRoot = Split-Path -Parent $rubyBin
$env:Path = "$rubyBin;$rubyRoot\msys64\ucrt64\bin;$rubyRoot\msys64\usr\bin;$env:Path"
$env:BUNDLE_USER_HOME = Join-Path $PSScriptRoot '.bundle\user'
$env:BUNDLE_PATH = Join-Path $PSScriptRoot '.bundle\gems'
$env:GEM_HOME = $env:BUNDLE_PATH
$env:GEM_PATH = $env:GEM_HOME

if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
    $bundleBat = Join-Path $rubyBin 'bundle.bat'
    if (-not (Test-Path -LiteralPath $bundleBat)) {
        throw 'Bundler is unavailable. Run: gem install bundler'
    }
}

Write-Host 'Checking and installing project dependencies...'
bundle install
if ($LASTEXITCODE -ne 0) {
    throw "bundle install failed with exit code $LASTEXITCODE. Check that Ruby+Devkit is installed and initialized."
}

Write-Host 'Starting Jekyll at http://localhost:4000 (press Ctrl+C to stop)...'
bundle exec jekyll serve --host 127.0.0.1 --port 4000
if ($LASTEXITCODE -ne 0) {
    throw "Jekyll exited with code $LASTEXITCODE."
}
