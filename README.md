# RunLog

A PowerShell logging module with class-based loggers and thread-safe file operations designed for use in PowerShell jobs and scripts.

## Description

RunLog provides a robust, thread-safe logging solution for PowerShell environments. It features a class-based architecture with configurable log levels, automatic retry logic for file operations, and built-in support for exception logging. The module is particularly well-suited for PowerShell jobs and multi-threaded scenarios where reliable logging is critical.

**Key Features:**
- Class-based `RunLogger` with five log levels (Debug, Information, Warning, Error, Critical)
- Thread-safe file operations using .NET StreamWriter
- Automatic retry logic with exponential backoff for file write operations
- Process and thread ID tracking in log entries
- Exception logging support with stack trace details
- Configurable minimum log levels for filtering
- Compatible with both PowerShell Desktop and Core editions

## Getting Started

### Prerequisites
- PowerShell 5.1 or higher
- .NET Framework 4.5.2 or higher (for Desktop edition)

### Installation

1. **From PowerShell Gallery**:
```powershell
Install-Module -Name RunLog
```

2. **Manual Installation**:
   - Download the module files (`RunLog.psm1`, `RunLog.psd1`)
   - Place them in your PowerShell modules directory:
     - `$env:PSModulePath` (typically `C:\Users\<username>\Documents\PowerShell\Modules\RunLog\`)

3. **Import the Module**:
```powershell
Import-Module RunLog
```

### Basic Usage

#### Creating a Logger
```powershell
# Create a logger with default Information level
$logger = New-RunLogger -LogFilePath "C:\Logs\application.log"

# Create a logger with custom minimum log level
$logger = New-RunLogger -LogFilePath "C:\Logs\debug.log" -MinimumLogLevel Debug
```

#### Logging Messages
```powershell
# Basic logging
$logger.Information("Application started successfully")
$logger.Warning("Configuration file not found, using defaults")
$logger.Error("Failed to connect to database")

# Logging with exceptions
try {
    # Some operation that might fail
    Get-Content "nonexistent-file.txt"
}
catch {
    $logger.Error("File operation failed", $_.Exception)
}
```

#### Advanced Examples

**Using in PowerShell Jobs:**
```powershell
$job = Start-Job -ScriptBlock {
    param($LogPath)
    Import-Module RunLog
    $logger = New-RunLogger -LogFilePath $LogPath
    
    $logger.Information("Job started")
    # Perform work...
    $logger.Information("Job completed")
} -ArgumentList "C:\Logs\job.log"
```

**Different Log Levels:**
```powershell
$logger = New-RunLogger -LogFilePath "C:\Logs\app.log" -MinimumLogLevel Debug

$logger.Debug("Detailed debugging information")
$logger.Information("General information about program execution")
$logger.Warning("Something unexpected happened, but program continues")
$logger.Error("An error occurred, but program may continue")
$logger.Critical("A critical error occurred, program may terminate")
```

**Log Level Filtering:**
```powershell
# Only Warning and above will be written to file
$logger = New-RunLogger -LogFilePath "C:\Logs\warnings-only.log" -MinimumLogLevel Warning

$logger.Debug("This will NOT be logged")
$logger.Information("This will NOT be logged")
$logger.Warning("This WILL be logged")
$logger.Error("This WILL be logged")
```

### Log Format

Log entries are formatted as follows:
```
[2025-05-26 19:30:15.123] [1234:5] [Information] Application started successfully
[2025-05-26 19:30:16.456] [1234:5] [Error] Database connection failed
    Exception: SqlException: Timeout expired. The timeout period elapsed prior to completion of the operation.
    StackTrace: at System.Data.SqlClient.SqlConnection.OnError(...)
```

Format breakdown:
- `[Timestamp]` - Precise timestamp with milliseconds
- `[ProcessId:ThreadId]` - Process and thread identification
- `[LogLevel]` - The log level of the entry
- `Message` - The log message
- `Exception Details` - Exception type, message, and stack trace (when applicable)

## Help

### Available Functions

#### `New-RunLogger`
Creates a new RunLogger instance.

**Parameters:**
- `LogFilePath` (Mandatory) - Path to the log file
- `MinimumLogLevel` (Optional) - Minimum log level to write (default: Information)

#### `Get-LogLevel`
Returns available log levels as an array of strings.

```powershell
Get-LogLevel
# Returns: Debug, Information, Warning, Error, Critical
```

### Log Levels

| Level | Value | Description |
|-------|-------|-------------|
| Debug | 0 | Detailed information for diagnosing problems |
| Information | 1 | General information about program execution |
| Warning | 2 | Indicates something unexpected happened |
| Error | 3 | An error occurred but program may continue |
| Critical | 4 | A critical error occurred |

### Thread Safety

RunLog is designed to be thread-safe and handles concurrent access from multiple PowerShell jobs or runspaces. The module uses .NET StreamWriter with proper disposal patterns and implements retry logic to handle file locking scenarios.

### Error Handling

If the module cannot write to the specified log file after 3 attempts with exponential backoff, it will:
1. Display a warning message
2. Write the log entry to the console as a fallback
3. Continue operation without throwing exceptions

### Troubleshooting

**Common Issues:**

1. **Permission Denied**: Ensure the PowerShell process has write permissions to the log directory
2. **Path Not Found**: The module automatically creates the log directory if it doesn't exist
3. **File Locked**: The retry mechanism handles temporary file locks automatically

## Authors

- **aaturpin** - Initial development and design

## Version History

- **1.0.0** - Initial release
  - Class-based logging with RunLogger
  - Thread-safe LoggingService for PowerShell jobs
  - Support for Debug, Information, Warning, Error, and Critical log levels
  - Exception logging support
  - Automatic retry logic for file operations
  - Process and thread ID tracking in log entries

## License

This project is licensed under the MIT License - see below for details.

```
MIT License

Copyright (c) 2025 aatur

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Acknowledgments

- Built using SAPIEN Technologies PowerShell Studio 2025
- Inspired by modern structured logging practices
- Designed for enterprise PowerShell automation scenarios