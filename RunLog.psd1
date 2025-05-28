@{
	# Script module or binary module file associated with this manifest
	RootModule			   = 'RunLog.psm1'
	
	# Version number of this module.
	ModuleVersion		   = '2.0.0'
	
	# ID used to uniquely identify this module
	GUID				   = 'd67b132a-7e32-46f9-97f8-cd36e5bd8923'
	
	# Author of this module
	Author				   = 'aatur'
	
	# Company or vendor of this module
	CompanyName		       = ''
	
	# Copyright statement for this module
	Copyright			   = '(c) 2025 aaturpin. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description		       = 'Simplified PowerShell logging module with thread-safe file operations for use in PowerShell jobs and scripts.'
	
	# Supported PSEditions
	CompatiblePSEditions   = @('Desktop', 'Core')
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion	   = '5.1'
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '4.5.2'
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture  = 'None'
	
	# Modules that must be imported into the global environment prior to importing this module
	RequiredModules	       = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies	   = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to importing this module
	ScriptsToProcess	   = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess		   = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess	   = @()
	
	# Modules to import as nested modules of the module specified in ModuleToProcess
	NestedModules		   = @()
	
	# Functions to export from this module
	FunctionsToExport	   = @(
		'New-RunLogger',
		'Get-LogLevel'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport	       = @()
	
	# Variables to export from this module
	VariablesToExport	   = @()
	
	# Aliases to export from this module
	AliasesToExport	       = @()
	
	# List of all modules packaged with this module
	ModuleList			   = @()
	
	# List of all files packaged with this module
	FileList			   = @('RunLog.psm1', 'RunLog.psd1')
	
	# Private data to pass to the module specified in ModuleToProcess
	PrivateData		       = @{
		PSData = @{
			# Tags applied to this module
			Tags		 = @('Logging', 'PowerShell', 'Jobs', 'Threading', 'Utilities', 'Simplified')
			
			# A URL to the license for this module
			LicenseUri   = 'https://github.com/aturpin0504/RunLog-PowerShell?tab=MIT-1-ov-file'
			
			# A URL to the main website for this project
			ProjectUri   = 'https://github.com/aturpin0504/RunLog-PowerShell'
			
			# ReleaseNotes of this module
			ReleaseNotes = @'
Version 2.0.0:
- BREAKING: Simplified architecture - removed complex queue system
- BREAKING: Removed queue management functions (Get-RunLogQueueStats, Clear-RunLogFailedQueue, etc.)
- IMPROVED: Better cross-process thread safety using named mutex
- IMPROVED: Console fallback prevents log entry loss
- IMPROVED: Significantly reduced code complexity (~70% reduction)
- IMPROVED: Better performance for successful writes
- IMPROVED: More reliable in PowerShell jobs and multi-process scenarios
- MAINTAINED: All core logging functionality (Debug, Information, Warning, Error, Critical)
- MAINTAINED: Exception logging support
- MAINTAINED: Process and thread ID tracking
- MAINTAINED: Configurable minimum log levels
'@
		}
	}
}