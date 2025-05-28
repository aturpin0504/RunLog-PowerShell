# RunLog.psm1 - Simplified PowerShell Logging Module

# Enum for log levels
enum LogLevel {
	Debug = 0
	Information = 1
	Warning = 2
	Error = 3
	Critical = 4
}

# Main Logger Class
class RunLogger {
	[string]$LogFilePath
	[LogLevel]$MinimumLogLevel
	
	# Constructor
	RunLogger([string]$logFilePath)
	{
		$this.LogFilePath = $logFilePath
		$this.MinimumLogLevel = [LogLevel]::Information
		$this.Initialize()
	}
	
	RunLogger([string]$logFilePath, [LogLevel]$minimumLogLevel)
	{
		$this.LogFilePath = $logFilePath
		$this.MinimumLogLevel = $minimumLogLevel
		$this.Initialize()
	}
	
	# Initialize method to ensure log directory exists
	hidden [void]Initialize()
	{
		$logDirectory = Split-Path -Path $this.LogFilePath -Parent
		if (-not (Test-Path -Path $logDirectory))
		{
			New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
		}
	}
	
	# Private method to check if log level should be written
	hidden [bool]ShouldLog([LogLevel]$level)
	{
		return $level -ge $this.MinimumLogLevel
	}
	
	# Core logging method - handles all the heavy lifting
	hidden [void]WriteLogEntry([LogLevel]$level, [string]$message, [System.Exception]$exception = $null)
	{
		if (-not $this.ShouldLog($level)) { return }
		
		$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
		$processId = [System.Diagnostics.Process]::GetCurrentProcess().Id
		$threadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
		
		# Build the log entry
		$logEntry = "[$timestamp] [$processId`:$threadId] [$level] $message"
		
		# Add exception details if provided
		if ($exception)
		{
			$logEntry += "`n    Exception: $($exception.GetType().Name): $($exception.Message)"
			if ($exception.StackTrace)
			{
				$logEntry += "`n    StackTrace: $($exception.StackTrace)"
			}
		}
		
		# Simple retry with exponential backoff
		$maxRetries = 5
		$retryDelay = 50 # milliseconds
		$mutex = $null
		
		for ($i = 0; $i -lt $maxRetries; $i++)
		{
			try
			{
				# Use mutex for thread safety across processes
				$mutexName = "RunLogger_" + ($this.LogFilePath -replace '[\\/:*?"<>|]', '_')
				$mutex = [System.Threading.Mutex]::new($false, $mutexName)
				
				if ($mutex.WaitOne(1000))
				{
					# 1 second timeout
					try
					{
						# Atomic write operation
						[System.IO.File]::AppendAllText($this.LogFilePath, $logEntry + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
						return # Success
					}
					finally
					{
						$mutex.ReleaseMutex()
					}
				}
				else
				{
					throw "Mutex timeout - file may be locked"
				}
			}
			catch
			{
				if ($i -eq ($maxRetries - 1))
				{
					# Final fallback - write to console
					Write-Host "[$timestamp] [CONSOLE-FALLBACK] [$level] $message" -ForegroundColor Yellow
					if ($exception)
					{
						Write-Host "    Exception: $($exception.GetType().Name): $($exception.Message)" -ForegroundColor Red
					}
					return
				}
				else
				{
					Start-Sleep -Milliseconds $retryDelay
					$retryDelay *= 2 # Exponential backoff
				}
			}
			finally
			{
				if ($mutex)
				{
					$mutex.Dispose()
					$mutex = $null
				}
			}
		}
	}
	
	# Public logging methods
	[void]Debug([string]$message) { $this.WriteLogEntry([LogLevel]::Debug, $message, $null) }
	[void]Debug([string]$message, [System.Exception]$exception) { $this.WriteLogEntry([LogLevel]::Debug, $message, $exception) }
	
	[void]Information([string]$message) { $this.WriteLogEntry([LogLevel]::Information, $message, $null) }
	[void]Information([string]$message, [System.Exception]$exception) { $this.WriteLogEntry([LogLevel]::Information, $message, $exception) }
	
	[void]Warning([string]$message) { $this.WriteLogEntry([LogLevel]::Warning, $message, $null) }
	[void]Warning([string]$message, [System.Exception]$exception) { $this.WriteLogEntry([LogLevel]::Warning, $message, $exception) }
	
	[void]Error([string]$message) { $this.WriteLogEntry([LogLevel]::Error, $message, $null) }
	[void]Error([string]$message, [System.Exception]$exception) { $this.WriteLogEntry([LogLevel]::Error, $message, $exception) }
	
	[void]Critical([string]$message) { $this.WriteLogEntry([LogLevel]::Critical, $message, $null) }
	[void]Critical([string]$message, [System.Exception]$exception) { $this.WriteLogEntry([LogLevel]::Critical, $message, $exception) }
}

# Helper functions
function New-RunLogger
{
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[string]$LogFilePath,
		[Parameter(Mandatory = $false)]
		[LogLevel]$MinimumLogLevel = [LogLevel]::Information
	)
	
	if ($PSCmdlet.ShouldProcess("Creating logger with file path '$LogFilePath'"))
	{
		return [RunLogger]::new($LogFilePath, $MinimumLogLevel)
	}
}

function Get-LogLevel
{
	[CmdletBinding()]
	param ()
	
	return [LogLevel].GetEnumNames()
}

# Export functions
Export-ModuleMember -Function @('New-RunLogger', 'Get-LogLevel')