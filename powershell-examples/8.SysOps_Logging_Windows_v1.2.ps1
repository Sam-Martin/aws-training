<#System Operations - Lab 8: Archiving Log Data to Amazon S3 (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

# 1. Locate the section you need. Each section in this file matches a section in the lab instructions.


# 2. Replace items in angle brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.



++++1. Create and Configure Amazon S3 Bucket++++


==================================================================================================================
1.4 Test Amazon S3 Bucket Access
==================================================================================================================
#>

# 1.4.6 List your available Amazon S3 buckets

#aws s3 ls
Get-S3Bucket

# 1.4.7 Create a small test file to upload

# echo "hello" > c:\aws\bucketTest.txt
Set-Content C:\aws\bucketTest.txt "hello"

# 1.4.8 Upload this file to your Amazon S3 bucket

#aws s3 cp c:\aws\bucketTest.txt s3://[s3-bucket]/
Write-S3Object -BucketName "YourOwnUniqueName" -File C:\aws\bucketTest.txt -key "bucketTest.txt"

# 1.4.9 Verify that the file uploaded successfully

# aws s3 ls s3://[s3-bucket]
Get-S3Object -BucketName "YourOwnUniqueName" | Format-Table 


# ++++2. Create a Log Rotation Process++++

<#
==================================================================================================================
2.1 Verify Upload Script
==================================================================================================================
#>

# 2.1.4 Create a test file in Z:\application_logs

#echo "testing script upload" > Z:\application_logs\test.log
Set-Content  Z:\application_logs\test.log "testing script upload"

# 2.1.5 Grant unrestricted execution for Powershell scripts

Set-ExecutionPolicy unrestricted

# 2.1.6 Run the Powershell script archive-syslogs.ps1

C:\aws\archive-syslogs.ps1

# 2.1.7 Confirm that these files were uploaded to your bucket

# aws s3 ls s3://[s3-bucket]
Get-S3Object -BucketName "YourOwnUniqueName" | Format-Table 

<# 
==================================================================================================================
2.4 Verify the Automated Upload Process
==================================================================================================================
#>

# 2.4.1 Create a small text file in the Z:\application_logs directory

#echo "Hello, Amazon S3!" > Z:\application_logs\test-auto-upload.txt
Set-Content Z:\application_logs\test-auto-upload.txt "Hello, Amazon S3!"

# 2.4.3 Verify that the test file appears in Amazon S3

# aws s3 ls s3://s3-bucket
Get-S3Object -BucketName "YourOwnUniqueName" | Format-Table 


# ++++3. Adding Additional Enhancements++++

<#
==================================================================================================================
3.1 Add File Prefixes and Compression
==================================================================================================================
#>

# 3.1.1 Replace the contents of the C:\aws\archive-syslogs.ps1 file with the following file

<# 
.SYNOPSIS 
    Archives files to S3 in a zip file optionally using a regex file pattern
.DESCRIPTION 
    If a pattern with is provided, only matching files are archived, otherwise
    everything in a folder is zipped and uploaded
.NOTES 
    Author : awsstudent
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)][ValidateScript({Test-Path $_ -PathType 'Container'})][string] 
    $Path = "Z:\application_logs",
    [Parameter(Mandatory=$false)][string]
    $Bucket = "s3-bucket-name",
    [Parameter(Mandatory=$false)][string]
    $Pattern = ".*"
    )

$logs = Get-ChildItem $Path | Where-Object { $_.Name -match $Pattern -and ! $_.PSIsContainer -and $_.Length -gt 0 } |
    Select-Object Name, FullName

if (!($logs | Measure-Object).Count) { 
	Write-Warning "no files at $Path" -WarningAction Stop}

	$archive = (Join-Path (Resolve-Path $Path) "logs.zip")
	Set-Content $archive ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
	$ns = (New-Object -com shell.application).NameSpace($archive);

	$logs | ForEach-Object { $ns.MoveHere($_.FullName) 
}

#aws s3 cp $archive "s3://$Bucket/$(Get-Date -UFormat "%Y/%m/%d/%H/%M")/logs.zip"
Write-S3Object -BucketName $Bucket -File $archive  -key "$(Get-Date -UFormat "%Y/%m/%d/%H/%M")/logs.zip"
Remove-Item $archive

<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.
#>