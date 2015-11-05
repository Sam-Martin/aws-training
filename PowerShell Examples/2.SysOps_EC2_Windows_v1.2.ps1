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



++++Receive AWS Command Line Help++++


==================================================================================================================
Receive AWS Command Line Help
==================================================================================================================


1. Receive general command-line help

aws help

2. Obtain help on the EC2 service

aws ec2 help

3. Obtain help in the RunInstances API of the EC2 service

aws ec2 run-instances help

==================================================================================================================


++++1. Configure the Bastion Host++++
 
<#
==================================================================================================================
 1.1. Setup AWS in PowerShell (incorporates 1.2.3)                                                NEW!!!!
==================================================================================================================
#>

$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content


# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);
$localInstanceID = (invoke-webrequest "http://169.254.169.254/latest/meta-data/instance-id/").content

# Set default region
Set-DefaultAWSRegion $localRegion

<#
==================================================================================================================
1.2 Inspect the Instance Metadata
==================================================================================================================
#>

# 1.2.1 Obtain a list of the available versions of the metadata 

#curl -s '\n' http://169.254.169.254/



#1.2.2 Obtain a list of the available categories of information for the latest version of the metadata service 

#curl -s http://169.254.169.254/latest/
$localInstance = Get-EC2Instance -Instance $localInstanceID 
$localInstance = $localInstance.Instances | select -First 1
$localInstance


# 1.2.3 Retrieve the instance's availability zone (covered in 1.1)

# curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone

<#
==================================================================================================================
1.3 Retrieve the VPC ID
==================================================================================================================
 (not required as we can just do $localInstance.VpcId)

1.3.1 List the instance's elastic network interfaces

curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/

1.3.2 Save the MAC address to an environment variable called BASTION_MAC

set command=curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/

for /f "delims=" %A in ('%command%') do @set BASTION_MAC=%A

1.3.3 Verify the variable BASTION_MAC

set BASTION_MAC

1.3.4 Set the variable BASTION_VPC

set command=curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/%BASTION_MAC%vpc-id

for /f "delims=" %A in ('%command%') do @set BASTION_VPC=%A

1.3.5 Verify the variable BASTION_VPC

set BASTION_VPC

==================================================================================================================
1.4 Retrieve the Security Group Name
==================================================================================================================

#>


# 1.4.1 View the name of the Bastion host’s security group 

# curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/%BASTION_MAC%/security-group-ids
$localInstance.SecurityGroups

<# 1.4.2 Save the name of the Bastion Host's security group to an environment vaiable called BASTION_SG

set command=curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/%BASTION_MAC%security-group-ids
for /f "delims=" %A in ('%command%') do @set BASTION_SG=%A
#>

$localInstanceSecurityGroupID = ($localInstance.SecurityGroups | select -First 1).groupid

#1.4.3 Verify that the environment variable has been correctly initialized

#set BASTION_SG
localInstanceSecurityGroupID


<#
==================================================================================================================
1.5 Retrieve the AMI ID of the Bastion Host
==================================================================================================================

(Not required as we can just do $localinstance.ImageId)


1.5.1 Store the ID of the AMI in the environment variable AMI_ID

set command=curl -s http://169.254.169.254/latest/meta-data/ami-id

for /f "delims=" %A in ('%command%') do @set AMI_ID=%A

1.5.2 Verify that the environment variable AMI_ID has been set

set AMI_ID



==================================================================================================================
1.6 Configure the AWS CLI
==================================================================================================================
 (Not required for obvious reasons.)

1.6.1 Run the following command: 

aws configure


==================================================================================================================



++++2. Creating the EC2 Server++++


==================================================================================================================
2.1 Create a New Security Group
==================================================================================================================
#>

# 2.1.1 Create the security group by running the following command, and save its ID to an environment variable called INTERNAL_SG
 

<# 2.1.1 Create the security group by running the following command, and save its ID to an environment variable called INTERNAL_SG

set command=aws ec2 create-security-group --group-name internal-sg --vpc-id %BASTION_VPC% --description internal-security-group --query GroupId
for /f "delims=" %A in ('%command%') do @set INTERNAL_SG=%A

#>

$newSecurityGroupID = New-EC2SecurityGroup -GroupName 'internal-sg4' -VpcId $localInstance.VpcId -Description 'internal-security-group'


# 2.1.2 Authorize ingress SSH from the Bastion Host security group

# aws ec2 authorize-security-group-ingress --group-id %INTERNAL_SG% --protocol tcp --port 3389 --source-group %BASTION_SG%


# Build RDP Permissions Object
$RDPPermissions = New-Object Amazon.EC2.Model.IpPermission -Property @{
    IpProtocol = 'tcp';
    FromPort = 3389;
    ToPort = 3389;
}
$LocalSecurityGroupPair = New-Object Amazon.EC2.Model.UserIdGroupPair -Property @{GroupID=$localInstanceSecurityGroupID}
$RDPPermissions.UserIdGroupPair.Add($groupPair);
Grant-EC2SecurityGroupIngress -GroupId $newSecurityGroupID -IpPermissions $RDPPermissions

<#
==================================================================================================================
2.2 Create a New Key Pair
==================================================================================================================

2.2.1 Change directories

cd \aws
#>


# 2.2.2 Create a new key pair

#aws ec2 create-key-pair --key-name InternalKeyPair --query KeyMaterial > InternalKeyPair.pem
New-EC2KeyPair -KeyName 'InternalKeyPair12' | select -ExpandProperty KeyMaterial | Set-Content C:\aws\InternalKeyPair.pem

<#
==================================================================================================================
2.3 Create the EC2 Server
==================================================================================================================


2.3.1 Set the name of your private subnet to an environment variable

set command= aws ec2 describe-subnets --filters "Name=tag:Network,Values=Private" --query "Subnets[*].SubnetId"
for /f "delims=" %A in ('%command%') do @set PRIV_SUBNET=%A


# 2.3.2 Create the new EC2 instance

set command=aws ec2 run-instances --image-id %AMI_ID% --key-name InternalKeyPair --security-group-ids %INTERNAL_SG% --instance-type m1.small --subnet-id %PRIV_SUBNET% --query Instances[*].InstanceId
for /f "delims=" %A in ('%command%') do @set INTERNAL_INSTANCE_ID=%A
#>

$newInstance = New-EC2Instance -ImageId $localinstance.ImageId -KeyName 'InternalKeyPair12' -SecurityGroupIds $newSecurityGroupID -InstanceType 'm1.small' -SubnetId $localinstance.SubnetId  -MinCount 1 -maxcount 1

# 2.3.3 Assign a name to the instance

#aws ec2 create-tags --resources %INTERNAL_INSTANCE_ID% --tags Key=Name,Value=InternalServer


## !!!!! Commands beyond this point have not been tested but should be at least approximately correct.
$Tag = New-Object Amazon.EC2.Model.Tag -Property @{Key='Name';Value='InternalServer'} 
New-EC2Tag -ResourceID $newInstance.InstanceID -Tag $Tag -Region $localRegion

<#
==================================================================================================================
2.4 Connect to the New Instance
==================================================================================================================
#>

# 2.4.1 Obtain the Administrator password of your new instance

#aws ec2 get-password-data --instance-id %INTERNAL_INSTANCE_ID% --priv-launch-key InternalKeyPair.pem
Get-EC2PasswordData -InstanceID $newInstance.InstanceID -PemFile 'C:\AWS\InternalKeyPair.pem'

# 2.4.2 Obtain the private IP address of the new instance

#aws ec2 describe-instances --instance-ids %INTERNAL_INSTANCE_ID% --query Reservations[*].Instances[*].PrivateIpAddress
$NewInstanceNetworkInterface = $newInstance.NetworkInterfaces | select -First 1
Get-EC2NetworkInterface $NewInstanceNetworkInterface.localInstanceNetworkInterface


<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.
#>