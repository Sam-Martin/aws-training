<#
System Operations - Lab 9: Using Auto Scaling in AWS (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

1. Locate the section you need. Each section in this file matches a section in the lab instructions.


2. Replace items in angle brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.



++++1. Create a New Amazon Machine Image++++


==================================================================================================================
1.2 Create New EC2 Instance
==================================================================================================================
#>


#### Get Values
#Set-DefaultAWSRegion (Read-Host "AWS Region (e.g. us-west-2)");
$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content
# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);

# Set default region
Set-DefaultAWSRegion $localRegion

# 1.2.3 Create the new EC2 instance

#aws ec2 run-instances --key-name [key-name] --instance-type m1.medium --image-id [ami-id] --user-data file://c:\aws\UserData.txt --security-group-ids [security-group-id] --associate-public-ip-address
$newInstance = New-EC2Instance -KeyName [key-name] -InstanceType m1.medium -ImageId [ami-id] -UserData $([string](get-content c:\aws\UserDataBase64.txt)).Trim() -SecurityGroupIDs [security-group-id] -AssociatePublicIP $true -MinCount 1 -MaxCount 1
$newInstance.instances.instanceid

# 1.2.5 Monitor this instance's status

#aws ec2 describe-instance-status --instance-id [new-instance-id]
(Get-EC2Instance -Instance i-e1d857ea).instances.state

# 1.2.6 Obtain the public DNS address of your instance

#aws ec2 describe-instances --instance-id [new-instance-id] --query "Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName"
(Get-EC2Instance -Instance i-e1d857ea).instances.publicDNSName

#1.2.7 Retrieve the home page of your Web server

#curl http://[public-dns-address]
(Invoke-WebRequest http://[public-dns-address]).content

<#
==================================================================================================================
1.4 Create a Custom AMI
==================================================================================================================
#>

# 1.4.1 Create a new AMI based on this image

#aws ec2 create-image --name WebServer --instance-id [new-instance-id]
New-EC2Image -name WebServer -instanceID [new-instance-id]

<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.
#>