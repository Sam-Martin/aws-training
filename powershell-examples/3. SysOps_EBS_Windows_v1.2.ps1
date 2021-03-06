<#System Operations - Lab 3: Amazon Elastic Block Store (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

1. Locate the section you need. Each section in this file matches a section in the lab instructions.


2. Replace items in square brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.



++++1. Resizing the Boot Volume++++  #>

# ==================================================================================================================
# 1.2 Create Snapshot of Existing Volume
# ==================================================================================================================


#### Get Values
#Set-DefaultAWSRegion (Read-Host "AWS Region (e.g. us-west-2)");
$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content
# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);

# Set default region
Set-DefaultAWSRegion $localRegion


# 1.2.1 Obtain the value of the storage server's instance ID
# Also availability zone for use later

$filter = New-Object Amazon.EC2.Model.Filter
$filter.Name = "tag:Name"
$filter.Value.Add('STORAGE')
$StorageServer = (Get-EC2Instance -Filter $filter)
$StorageServerID = $StorageServer.instances.instanceID
$StorageServerAvailabilityZone = $StorageServer.instances.placement.availabilityzone

<#
set command="aws ec2 describe-instances --filter Name=tag:Name,Values=STORAGE --query "Reservations[*].Instances[*].InstanceId" --output text"
for /f "delims=" %A in ('%command%') do @set STORAGE_SERVER_ID=%A

# 1.2.2 Describe your instance #>

#aws ec2 describe-instances --instance-ids %STORAGE_SERVER_ID%
(Get-EC2Instance -Filter $filter).instances

#1.2.4 See that the volume is already attached

#aws ec2 describe-volumes --volume-ids [existing-volume-id]
(Get-EC2Instance -Filter $filter).instances.blockdevicemappings.ebs


#1.2.5 Initiate a snapshot of this existing volume

#aws ec2 create-snapshot --volume-id [existing-volume-id]
$volumeSnapshot = New-EC2Snapshot -VolumeID 'vol-c5fe4dc4'
$volumeSnapshot

#1.2.7 Monitor the progress of your snapshot

#aws ec2 describe-snapshots --snapshot-ids [new-snapshot-id]
Get-EC2Snapshot -SnapshotIds $volumeSnapshot.snapShotID

<#
while((Get-EC2Snapshot -SnapshotIds $volumeSnapshot.snapShotID).state -eq "Pending"){
    Write-Host "Still pending...";
    start-sleep -s 5
} write-host "Complete" #>

<#
==================================================================================================================
1.3 Create a New Volume
================================================================================================================== #>


# 1.3.1 Create a new 120GB volume

#aws ec2 create-volume --snapshot-id [new-snapshot-id] --size 120 --availability-zone [availability-zone]
$BiggerVolume = New-EC2Volume -AvailabilityZone $StorageServerAvailabilityZone -size 120 -snapshotID $volumeSnapshot.snapShotID
$BiggerVolume

# 1.3.3 View the state of the volume

#aws ec2 describe-volumes --volume-ids [new-volume-id]
Get-EC2Volume -volumeID $BiggerVolume.VolumeID


<#
==================================================================================================================
1.4 Detach and Attach Volumes
==================================================================================================================
#>

# 1.4.1 Stop the storage server instance

#aws ec2 stop-instances --instance-id %STORAGE_SERVER_ID%
Stop-EC2Instance -Instance $StorageServerID

# 1.4.2 Detach the old volume

# aws ec2 detach-volume --volume-id [existing-volume-id]
Dismount-EC2Volume -VolumeId 'vol-c5fe4dc4'

# 1.4.3 Monitor the state of the volume until it has finished detaching

Get-EC2Volume -VolumeIds 'vol-c5fe4dc4'

# 1.4.5 Attach the new volume

#aws ec2 attach-volume --volume-id [new-volume-id] --instance-id %STORAGE_SERVER_ID% --device /dev/sda1
Add-EC2Volume  -VolumeID $BiggerVolume.VolumeID -InstanceId $StorageServerID -Device '/dev/sda1'

# 1.4.6 Monitor the attach request

Get-EC2Volume -volumeID $BiggerVolume.VolumeID

<#
==================================================================================================================
1.5 Restart Server and Verify Volume
==================================================================================================================
#>

# 1.5.1 Restart the storage server instance

# aws ec2 start-instances --instance-id %STORAGE_SERVER_ID%
Start-EC2Instance -InstanceIds $StorageServerID

# 1.5.2 Monitor this instance until its state changes to running

# aws ec2 describe-instances --instance-ids %STORAGE_SERVER_ID% --query "Reservations[*].Instances[*].State.Name"
Get-EC2Instance -Instance $StorageServerID


<#
==================================================================================================================
1.6 Initialize the New Volume
==================================================================================================================

#>

# 1.6.7 Delete the snapshot that you took earlier

# aws ec2 delete-snapshot --snapshot-id [new-snapshot-id]
Remove-EC2Snapshot -SnapshotId 'snap-862eeb72'


<#
++++2. Striping Amazon EBS Volumes++++



==================================================================================================================
2.1 Create and Mount Amazon EBS Volumes
==================================================================================================================
#>

# 2.1.1 Run the aws ec2 create-volume command TWICE
#aws ec2 create-volume --availability-zone [availability-zone] --size 100
#aws ec2 create-volume --availability-zone [availability-zone] --size 100
$volumes = @(1..2) | %{New-EC2Volume -AvailabilityZone $StorageServerAvailabilityZone -size 100}


# 2.1.2 Watch the state of these drives until they become available
#aws ec2 describe-volumes --volume-ids [new-volume-1] [new-volume-2]
Get-EC2Volume -VolumeIds $volumes.volumeid


# 2.1.3 Mount the first drive

# aws ec2 attach-volume --volume-id [new-volume-1] --instance-id %STORAGE_SERVER_ID% --device /dev/xvdc 
Add-EC2Volume -volumeID $volumes[0].volumeID -InstanceID $StorageServerID -device '/dev/xvdc' 

# 2.1.4 Mount the second drive

#aws ec2 attach-volume --volume-id [new-volume-2] --instance-id %STORAGE_SERVER_ID% --device /dev/xvdd
Add-EC2Volume -volumeID $volumes[1].volumeID -InstanceID $StorageServerID -device '/dev/xvdd' 



<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.

#>