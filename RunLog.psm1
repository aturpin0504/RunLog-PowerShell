# RunLog.psm1 - PowerShell Logging Module

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
	
	# Debug logging
	[void]Debug([string]$message)
	{
		$this.Debug($message, $null)
	}
	
	[void]Debug([string]$message, [System.Exception]$exception)
	{
		if ($this.ShouldLog([LogLevel]::Debug))
		{
			[LoggingService]::WriteLog($this.LogFilePath, [LogLevel]::Debug, $message, $exception)
		}
	}
	
	# Information logging
	[void]Information([string]$message)
	{
		$this.Information($message, $null)
	}
	
	[void]Information([string]$message, [System.Exception]$exception)
	{
		if ($this.ShouldLog([LogLevel]::Information))
		{
			[LoggingService]::WriteLog($this.LogFilePath, [LogLevel]::Information, $message, $exception)
		}
	}
	
	# Warning logging
	[void]Warning([string]$message)
	{
		$this.Warning($message, $null)
	}
	
	[void]Warning([string]$message, [System.Exception]$exception)
	{
		if ($this.ShouldLog([LogLevel]::Warning))
		{
			[LoggingService]::WriteLog($this.LogFilePath, [LogLevel]::Warning, $message, $exception)
		}
	}
	
	# Error logging
	[void]Error([string]$message)
	{
		$this.Error($message, $null)
	}
	
	[void]Error([string]$message, [System.Exception]$exception)
	{
		if ($this.ShouldLog([LogLevel]::Error))
		{
			[LoggingService]::WriteLog($this.LogFilePath, [LogLevel]::Error, $message, $exception)
		}
	}
	
	# Critical logging
	[void]Critical([string]$message)
	{
		$this.Critical($message, $null)
	}
	
	[void]Critical([string]$message, [System.Exception]$exception)
	{
		if ($this.ShouldLog([LogLevel]::Critical))
		{
			[LoggingService]::WriteLog($this.LogFilePath, [LogLevel]::Critical, $message, $exception)
		}
	}
}

# Logging Service Class - Handles actual file operations
class LoggingService {
	# Static method to write log entries
	static [void]WriteLog([string]$logFilePath, [LogLevel]$level, [string]$message, [System.Exception]$exception)
	{
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
		
		# Write to file with retry logic
		[LoggingService]::WriteToFileWithRetry($logFilePath, $logEntry)
	}
	
	# Static method with retry logic for file operations
	static [void]WriteToFileWithRetry([string]$filePath, [string]$content)
	{
		$maxRetries = 3
		$retryDelay = 100 # milliseconds
		
		for ($i = 0; $i -lt $maxRetries; $i++)
		{
			try
			{
				# Use .NET StreamWriter for better control and performance
				$streamWriter = [System.IO.StreamWriter]::new($filePath, $true, [System.Text.Encoding]::UTF8)
				try
				{
					$streamWriter.WriteLine($content)
					$streamWriter.Flush()
					return # Success, exit the method
				}
				finally
				{
					$streamWriter.Close()
				}
			}
			catch
			{
				if ($i -eq ($maxRetries - 1))
				{
					# Last retry failed, write to event log or console as fallback
					Write-Warning "Failed to write to log file '$filePath' after $maxRetries attempts. Last error: $($_.Exception.Message)"
					Write-Host "LOG FALLBACK: $content" -ForegroundColor Yellow
				}
				else
				{
					Start-Sleep -Milliseconds $retryDelay
					$retryDelay *= 2 # Exponential backoff
				}
			}
		}
	}
}

# Helper functions for convenience
function New-RunLogger
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$LogFilePath,
		[Parameter(Mandatory = $false)]
		[LogLevel]$MinimumLogLevel = [LogLevel]::Information
	)
	
	return [RunLogger]::new($LogFilePath, $MinimumLogLevel)
}

function Get-LogLevel
{
	[CmdletBinding()]
	param ()
	
	return [LogLevel].GetEnumNames()
}

# Export module members
Export-ModuleMember -Function @('New-RunLogger', 'Get-LogLevel') -Cmdlet @()