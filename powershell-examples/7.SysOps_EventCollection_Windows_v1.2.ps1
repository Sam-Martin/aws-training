<#
System Operations - Lab 7: Event Monitoring (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

1. Locate the section you need. Each section in this file matches a section in the lab instructions.


2. Replace items in angle brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.



++++2. Observe Amazon RDS Events++++


==================================================================================================================
2.2 Observe Amazon RDS Events from the AWS CLI
==================================================================================================================
#>

2.2.4 Describe all Amazon RDS events

#### Get Values
#Set-DefaultAWSRegion (Read-Host "AWS Region (e.g. us-west-2)");
$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content
# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);

# Set default region
Set-DefaultAWSRegion $localRegion

# Get events
Get-RDSEvent


<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.
#>