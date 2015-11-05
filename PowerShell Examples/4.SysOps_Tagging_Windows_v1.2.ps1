<#
System Operations - Lab 2: Creating Elastic Compute Cloud (Amazon EC2) Instances (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

1. Locate the section you need. Each section in this file matches a section in the lab instructions.


2. Replace items in square brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.



++++3. Using Tags in the AWS CLI++++


==================================================================================================================
3.2 Search for Resources Using Tags
==================================================================================================================

#>
#### Get Values
#Set-DefaultAWSRegion (Read-Host "AWS Region (e.g. us-west-2)");
$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content
# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);

# Set default region
Set-DefaultAWSRegion $localRegion



# 3.2.1 Show every tag for all EC2 resources you own

#aws ec2 describe-tags
Get-EC2Tag

# 3.2.2 Display all tags for edited instance

# aws ec2 describe-tags --filters "Name=resource-id,Values=[edited-instance-id]"
$filter = New-Object Amazon.EC2.Model.Filter
$filter.Name = "resource-id"
$filter.Value.Add('i-bf2e20b7')
Get-EC2Tag -Filters $filter

# 3.2.3 Search for the tag Student Email

#aws ec2 describe-tags --filters "Name=key,Values=Student Email"
$filter = New-Object Amazon.EC2.Model.Filter
$filter.Name = "key"
$filter.Value.Add('Student Email')
Get-EC2Tag -Filters $filter

# 3.2.4 Change the value of Cost Center on the same EC2 instance

#aws ec2 create-tags --resources [edited-instance-id] --tags "Key=Cost Center,Value=2001"
$tag = New-Object Amazon.EC2.Model.Tag -Property @{Key="Cost Center";Value=2001}
New-EC2Tag -ResourceID 'i-bf2e20b7' -Tag $tag -Region $localRegion

# 3.2.5 Delete the custom tag Student Email 

#aws ec2 delete-tags --resources [edited-instance-id] --tags "Key=Student Email"
$tag = New-Object Amazon.EC2.Model.Tag -Property @{Key="Student Email"}
Remove-EC2Tag  -ResourceID 'i-bf2e20b7' -Tag $tag -Region $localRegion


# ++++4. Perform a Bulk Update of Tag Values++++

<#
==================================================================================================================
4.1 Find and Change All Instances of a Tag
==================================================================================================================
#>

# 4.1.1 Find all EC2 instances where the value of the Cost Center tag is 1000

(Get-EC2Instance -Region $localRegion) | Select  -ExpandProperty RunningInstance  |  ?  {$_.Tag.Key -eq "Cost Center"  -and  $_.Tag.Value -eq "1000"} | % {"$($_.InstanceId)"}

# 4.1.2 Use the output of the previous command to change all Cost Centers with a value of 1000 to a value of 1001

$instances = (Get-EC2Instance -Region $localRegion)| Select  -ExpandProperty RunningInstance  |  ?  {$_.Tag.Key -eq "Cost Center"  -and  $_.Tag.Value -eq "1000"} | % {"$($_.InstanceId)"}
New-EC2Tag -Region us-west-2 -ResourceId $instances -Tag @{Key='Cost Center'; Value='1001'}

<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved. #>