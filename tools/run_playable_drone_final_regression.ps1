param(
    [Parameter(Mandatory=$true)][string]$GodotExe,
    [ValidateRange(5,600)][int]$TimeoutSeconds = 60
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$exe = (Resolve-Path -LiteralPath $GodotExe).Path
$manifest = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'playable_drone_final_regression.csv'))
if ($manifest.Count -ne 52 -or ($manifest | Measure-Object -Property ExpectedChecks -Sum).Sum -ne 741) {
    throw 'Unexpected regression manifest; stop.'
}
$logs = Join-Path ([System.IO.Path]::GetTempPath()) ('iw-drone-regression-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $logs | Out-Null
$results = @()
foreach ($suite in $manifest) {
    $scene = $suite.Scene
    $scenePath = Join-Path $root ('tests/' + $scene)
    $out = Join-Path $logs ($scene + '.stdout.txt')
    $err = Join-Path $logs ($scene + '.stderr.txt')
    $status = 'REVIEW'
    $reason = ''
    $proc = $null
    try {
        $sceneText = Get-Content -LiteralPath $scenePath -Raw
        $scriptMatches = [regex]::Matches($sceneText, 'path="res://([^"]+\.gd)"')
        if ($scriptMatches.Count -ne 1) { throw 'Cannot identify unique test script; use F6.' }
        $scriptPath = Join-Path $root $scriptMatches[0].Groups[1].Value
        $source = Get-Content -LiteralPath $scriptPath -Raw
        if ($scene -eq 'inventory_trasnfer_test.tscn') {
            $markers = @(
                'PASS: Partial transfer and resource conservation',
                'PASS: Full destination correctly blocked transfer',
                'PASS: Empty source correctly blocked transfer',
                'PASS: Invalid transfers correctly rejected'
            )
        } else {
            $matches = [regex]::Matches($source, 'print\("(?<banner>ALL [^"\r\n]*PASSED)"\)')
            if ($matches.Count -ne 1) { throw 'No unique literal ALL ... PASSED banner; use F6.' }
            $markers = @($matches[0].Groups['banner'].Value)
        }

        $arguments = @('--headless', '--path', ('"{0}"' -f $root), ('res://tests/' + $scene))
        $proc = Start-Process -FilePath $exe -ArgumentList $arguments -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -NoNewWindow
        $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
        $found = $false
        do {
            Start-Sleep -Milliseconds 250
            $actual = [string](Get-Content -LiteralPath $out -Raw -ErrorAction SilentlyContinue)
            $found = $true
            foreach ($marker in $markers) {
                if ($actual -notmatch ('(?m)^' + [regex]::Escape($marker) + '\s*$')) {
                    $found = $false
                    break
                }
            }
            $proc.Refresh()
        } until ($found -or $proc.HasExited -or [DateTime]::UtcNow -ge $deadline)
        # Allow final prints to flush; do not assume zero exit means success.
        Start-Sleep -Milliseconds 350
        $proc.Refresh()
        $exitError = $proc.HasExited -and $proc.ExitCode -ne 0
        if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
        $proc.WaitForExit()
        $actual = [string](Get-Content -LiteralPath $out -Raw -ErrorAction SilentlyContinue)
        $stderr = [string](Get-Content -LiteralPath $err -Raw -ErrorAction SilentlyContinue)
        $found = $true
        foreach ($marker in $markers) {
            if ($actual -notmatch ('(?m)^' + [regex]::Escape($marker) + '\s*$')) { $found = $false }
        }
        if ($exitError -or (($actual + "\n" + $stderr) -match '(?im)^\s*(SCRIPT ERROR|ERROR|FATAL|Assertion failed|FAIL(?:ED)?\b)')) {
            $reason = 'Error output or nonzero natural exit; inspect logs and F6.'
        } elseif (-not $found) {
            $reason = 'Completion banner absent (timeout or early exit); use F6.'
        } else {
            $status = 'CANDIDATE'
            $reason = 'Expected completion marker(s) present; verify check groups and logs.'
        }
    } catch {
        $reason = $_.Exception.Message
    } finally {
        if ($null -ne $proc) {
            $proc.Refresh()
            if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
            $proc.Dispose()
        }
    }
    $results += [pscustomobject]@{Scene=$scene;ExpectedChecks=[int]$suite.ExpectedChecks;Status=$status;Reason=$reason;Stdout=$out;Stderr=$err}
    Write-Host ("{0,-10} {1,2}  {2} -- {3}" -f $status,$suite.ExpectedChecks,$scene,$reason)
}
$results | Export-Csv -LiteralPath (Join-Path $logs 'results.csv') -NoTypeInformation
$candidates = @($results | Where-Object Status -eq 'CANDIDATE')
$expected = ($candidates | Measure-Object -Property ExpectedChecks -Sum).Sum
Write-Host "Candidates: $($candidates.Count)/52 suites; associated expected checks: $expected/741 (not yet verified)."
Write-Host "Review logs and results.csv: $logs"
