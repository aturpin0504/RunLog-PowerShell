<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2025 v5.9.256
	 Created on:   	5/26/2025 7:49 PM
	 Created by:   	aaturpin
	 Organization: 	
	 Filename:     	RunLog.psd1
	 -------------------------------------------------------------------------
	 Module Manifest
	-------------------------------------------------------------------------
	 Module Name: RunLog
	===========================================================================
#>
@{
	
	# Script module or binary module file associated with this manifest
	RootModule			   = 'RunLog.psm1'
	
	# Version number of this module.
	ModuleVersion		   = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID				   = 'd67b132a-7e32-46f9-97f8-cd36e5bd8923'
	
	# Author of this module
	Author				   = 'aatur'
	
	# Company or vendor of this module
	CompanyName		       = ''
	
	# Copyright statement for this module
	Copyright			   = '(c) 2025 aaturpin. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description		       = 'PowerShell logging module with class-based loggers and thread-safe file operations for use in PowerShell jobs and scripts.'
	
	# Supported PSEditions
	CompatiblePSEditions   = @('Desktop', 'Core')
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion	   = '5.1'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName	   = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion  = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '4.5.2'
	
	# Minimum version of the common language runtime (CLR) required by this module
	# CLRVersion = ''
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture  = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules	       = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies	   = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess	   = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess		   = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess	   = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
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
	
	# DSC class resources to export from this module.
	#DSCResourcesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList			   = @()
	
	# List of all files packaged with this module
	FileList			   = @('RunLog.psm1', 'RunLog.psd1')
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData		       = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags		 = @('Logging', 'PowerShell', 'Jobs', 'Threading', 'Utilities')
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/aturpin0504/RunLog-PowerShell?tab=MIT-1-ov-file'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/aturpin0504/RunLog-PowerShell'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = @'
Version 1.0.0:
- Initial release
- Class-based logging with RunLogger
- Thread-safe LoggingService for PowerShell jobs
- Support for Debug, Information, Warning, Error, and Critical log levels
- Exception logging support
- Automatic retry logic for file operations
- Process and thread ID tracking in log entries
'@
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}