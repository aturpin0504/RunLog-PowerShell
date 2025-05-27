<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2025 v5.9.256
	 Created on:   	5/26/2025 7:49 PM
	 Created by:   	aaturpin
	 Organization: 	
	 Filename:     	Test-Module.ps1
	===========================================================================
	.DESCRIPTION
	The Test-Module.ps1 script lets you test the functions and other features of
	your module in your PowerShell Studio module project. It's part of your project,
	but it is not included in your module.
	In this test script, import the module (be careful to import the correct version)
	and write commands that test the module features. You can include Pester
	tests, too.
	To run the script, click Run or Run in Console. Or, when working on any file
	in the project, click Home\Run or Home\Run in Console, or in the Project pane, 
	right-click the project name, and then click Run Project.
#>

# Clean up any existing module instances
Remove-Module RunLog -Force -ErrorAction SilentlyContinue

# Explicitly import the module for testing
Import-Module '.\RunLog.psd1' -Force

# Test log file path
$testLogPath = "C:\Temp\RunLogTest.log"

# Clean up any existing test log
if (Test-Path $testLogPath)
{
	Remove-Item $testLogPath -Force
}

Write-Host "=== RunLog Module Test Script ===" -ForegroundColor Green
Write-Host "Testing concurrent logging with PowerShell jobs..." -ForegroundColor Yellow

# Test 1: Basic logger functionality
Write-Host "`n1. Testing basic logger creation and logging..." -ForegroundColor Cyan
$mainLogger = New-RunLogger -LogFilePath $testLogPath -MinimumLogLevel Debug

$mainLogger.Information("Main script: Starting RunLog tests")
$mainLogger.Debug("Main script: Debug message test")
$mainLogger.Warning("Main script: Warning message test")
$mainLogger.Error("Main script: Error message test")

# Test exception logging
try
{
	throw "Test exception for logging"
}
catch
{
	$mainLogger.Error("Main script: Caught test exception", $_.Exception)
}

Write-Host "Basic logging completed. Check log file at: $testLogPath"

# Test 2: Concurrent job logging (file contention test)
Write-Host "`n2. Starting concurrent job test (10 jobs, same log file)..." -ForegroundColor Cyan

$jobs = @()
$jobCount = 10
$messagesPerJob = 5

# Get the current module path for jobs
$modulePath = (Get-Module RunLog).Path

for ($i = 1; $i -le $jobCount; $i++)
{
	$jobs += Start-Job -Name "LogTest$i" -ScriptBlock {
		param ($ModulePath,
			$LogPath,
			$JobId,
			$MessageCount)
		
		# Import module in job context
		Import-Module $ModulePath -Force
		
		# Create logger instance
		$jobLogger = New-RunLogger -LogFilePath $LogPath -MinimumLogLevel Debug
		
		$jobLogger.Information("Job $JobId starting with $MessageCount messages")
		
		# Write multiple messages with small delays to increase contention
		for ($msg = 1; $msg -le $MessageCount; $msg++)
		{
			$jobLogger.Debug("Job $JobId - Debug message $msg")
			Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 50)
			
			$jobLogger.Information("Job $JobId - Info message $msg")
			Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 50)
			
			if ($msg -eq 3)
			{
				$jobLogger.Warning("Job $JobId - Warning message $msg")
			}
		}
		
		# Test exception logging in job
		try
		{
			if ($JobId -eq 5)
			{
				throw "Simulated error in job $JobId"
			}
		}
		catch
		{
			$jobLogger.Error("Job $JobId caught exception", $_.Exception)
		}
		
		$jobLogger.Information("Job $JobId completed successfully")
		
		return "Job $JobId finished"
		
	} -ArgumentList $modulePath, $testLogPath, $i, $messagesPerJob
}

Write-Host "Started $jobCount concurrent jobs. Waiting for completion..." -ForegroundColor Yellow

# Wait for all jobs to complete with progress
$completed = 0
do
{
	Start-Sleep -Seconds 1
	$runningJobs = $jobs | Where-Object { $_.State -eq 'Running' }
	$newCompleted = ($jobCount - $runningJobs.Count)
	
	if ($newCompleted -ne $completed)
	{
		$completed = $newCompleted
		Write-Host "Jobs completed: $completed/$jobCount" -ForegroundColor Yellow
	}
}
while ($runningJobs.Count -gt 0)

# Get job results
Write-Host "`n3. Collecting job results..." -ForegroundColor Cyan
foreach ($job in $jobs)
{
	$result = Receive-Job $job
	if ($job.State -eq 'Failed')
	{
		Write-Host "Job $($job.Name) failed: $($job.ChildJobs[0].JobStateInfo.Reason)" -ForegroundColor Red
	}
	else
	{
		Write-Host "$result" -ForegroundColor Green
	}
}

# Clean up jobs
$jobs | Remove-Job -Force

# Test 3: Analyze log file results
Write-Host "`n4. Analyzing log file results..." -ForegroundColor Cyan

if (Test-Path $testLogPath)
{
	$logContent = Get-Content $testLogPath
	$totalLines = $logContent.Count
	$debugLines = ($logContent | Where-Object { $_ -match '\[Debug\]' }).Count
	$infoLines = ($logContent | Where-Object { $_ -match '\[Information\]' }).Count
	$warningLines = ($logContent | Where-Object { $_ -match '\[Warning\]' }).Count
	$errorLines = ($logContent | Where-Object { $_ -match '\[Error\]' }).Count
	$exceptionLines = ($logContent | Where-Object { $_ -match 'Exception:' }).Count
	
	Write-Host "Log Analysis Results:" -ForegroundColor Green
	Write-Host "  Total log entries: $totalLines"
	Write-Host "  Debug entries: $debugLines"
	Write-Host "  Information entries: $infoLines"
	Write-Host "  Warning entries: $warningLines"
	Write-Host "  Error entries: $errorLines"
	Write-Host "  Exception details: $exceptionLines"
	
	# Expected counts (rough estimate)
	$expectedTotal = 4 + ($jobCount * ($messagesPerJob * 2 + 2)) + 2 # main + jobs + exceptions
	Write-Host "  Expected approximately: $expectedTotal entries"
	
	if ($totalLines -ge ($expectedTotal * 0.9))
	{
		# Allow 10% variance
		Write-Host "✓ Log file appears complete - no significant message loss detected!" -ForegroundColor Green
	}
	else
	{
		Write-Host "⚠ Possible message loss detected. Check for file contention issues." -ForegroundColor Yellow
	}
	
	# Show last few entries
	Write-Host "`nLast 5 log entries:" -ForegroundColor Cyan
	$logContent | Select-Object -Last 5 | ForEach-Object { Write-Host "  $_" }
	
}
else
{
	Write-Host "❌ Log file not found!" -ForegroundColor Red
}

# Test 4: Test log levels
Write-Host "`n5. Testing log level filtering..." -ForegroundColor Cyan

$errorOnlyLogger = New-RunLogger -LogFilePath "C:\Temp\ErrorOnly.log" -MinimumLogLevel Error

$errorOnlyLogger.Debug("This should not appear")
$errorOnlyLogger.Information("This should not appear")
$errorOnlyLogger.Warning("This should not appear")
$errorOnlyLogger.Error("This should appear")
$errorOnlyLogger.Critical("This should appear")

if (Test-Path "C:\Temp\ErrorOnly.log")
{
	$errorLogContent = Get-Content "C:\Temp\ErrorOnly.log"
	Write-Host "Error-only log entries: $($errorLogContent.Count) (should be 2)"
	if ($errorLogContent.Count -eq 2)
	{
		Write-Host "✓ Log level filtering working correctly!" -ForegroundColor Green
	}
}

# Test 5: Test available log levels
Write-Host "`n6. Available log levels:" -ForegroundColor Cyan
Get-LogLevel | ForEach-Object { Write-Host "  - $_" }

Write-Host "`n=== Test Summary ===" -ForegroundColor Green
Write-Host "✓ Module imported successfully"
Write-Host "✓ Basic logging functionality tested"
Write-Host "✓ Concurrent job logging tested ($jobCount jobs)"
Write-Host "✓ Exception logging tested"
Write-Host "✓ Log level filtering tested"
Write-Host "✓ File contention handling tested"

Write-Host "`nTest log files created:"
Write-Host "  Main log: $testLogPath"
Write-Host "  Error-only log: C:\Temp\ErrorOnly.log"

Write-Host "`nRunLog module testing completed!" -ForegroundColor Green