<#
System Operations - Lab 5: Monitoring with CloudWatch (Windows) - 1.2
==================================================================================================================

Using this command reference. 

==================================================================================================================

1. Locate the section you need. Each section in this file matches a section in the lab instructions.


2. Replace items in square brackets - [ ] - with appropriate values. For example, in this command you would replace the value - [JobFlowID] - (including the brackets) with the parameter indicated in the lab instructions: 

   elastic-mapreduce --list [JobFlowID]. 

   You can also use find and replace to change bracketed parameters in bulk.

3. Do NOT enable the Word Wrap feature in Windows Notepad or the text editor you use to view this file.


++++1. Monitor a Custom CloudWatch Metric ++++
#>


#### Get Values
#Set-DefaultAWSRegion (Read-Host "AWS Region (e.g. us-west-2)");
$localInstanceAvailabilityZone = (invoke-webrequest "http://169.254.169.254/latest/meta-data/placement/availability-zone").content
# Infer local region from availability zone by stripping out the availability zone designation from the end
$localRegion = $localInstanceAvailabilityZone.substring(0,$localInstanceAvailabilityZone.length-1);

# Set default region
Set-DefaultAWSRegion $localRegion

# Even though cmdlets were accessible, "New-Object : Cannot find type [Amazon.CloudWatch.Model.MetricDatum]" was received until the module was reloaded
Import-Module AWSPowerShell

<#
==================================================================================================================
1.2 Write Custom Metrics from the Instance
==================================================================================================================
#>

# 1.2.1 Set the environment variable AWS_DEFAULT_REGION

[Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "[current-aws-region]", "User")

# 1.2.2 Write a new metric called AttentionLevel

#aws cloudwatch put-metric-data --namespace Student --metric-name AttentionLevel --value 8 --debug
$datum = New-Object Amazon.CloudWatch.Model.MetricDatum
$datum.Timestamp = (Get-Date).ToUniversalTime() 
$datum.MetricName = "AttentionLevel"
$datum.Unit = "Count"
$datum.Value = "8"
Write-CWMetricData -Namespace "Student" -MetricData $datum

<#
==================================================================================================================
1.3 Monitor the Custom Metrics in CloudWatch
==================================================================================================================
#>

# 1.3.4 Define yesterday and today's dates as variables in Powershell

$yesterday=[DateTime]::Today.AddDays(-1).ToString("d")

$tomorrow=[DateTime]::Today.AddDays(1).ToString("d")

# 1.3.5 Read the metric using the CLI

#aws cloudwatch get-metric-statistics --metric-name "AttentionLevel" --namespace="Student" --start-time=$yesterday --end-time=$tomorrow --period=300 --statistics="Minimum"
Get-CWMetricStatistics -Metricname "AttentionLevel" -Namespace "student" -StartTime $yesterday -EndTime $tomorrow -Period 300 -Statistics "Minimum"

<#
==================================================================================================================
1.4 Create a Cloudwatch Alarm
==================================================================================================================
#>

# 1.4.8 Record a data point that will trigger the alarm
$datum = New-Object Amazon.CloudWatch.Model.MetricDatum
$datum.Timestamp = (Get-Date).ToUniversalTime() 
$datum.MetricName = "AttentionLevel"
$datum.Unit = "Count"
$datum.Value = "4"
Write-CWMetricData -Namespace "Student" -MetricData $datum



# ++++3. Create the Monitoring Server and Clients ++++

<#
==================================================================================================================
3.1 Prepare the environment
==================================================================================================================


3.1.2 Disable the Windows Firewall

netsh  advfirewall set allprofiles state off


==================================================================================================================
3.2 Install and Run the Monitoring Server
==================================================================================================================


3.2.1 Change directories to the Python 2.7 installation

cd \python27

3.2.2 Install Flask

Scripts\pip install flask

3.2.3 Start the monitoring server

.\python c:\aws\mon-server.py

3.2.5 List the clients of your monitoring server

curl http://localhost


==================================================================================================================
3.3 Create a Launch Configuration for Auto Scaling
==================================================================================================================


3.3.8 Enter the following into the UserData field (REMEMBER - change [monitoring-server-ip]!)

<powershell>
$InstanceId=(New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/latest/meta-data/instance-id")

Invoke-RestMethod -Uri http://[monitoring-server-ip] -Method PUT -Body instanceId=$InstanceId -ContentType application/x-www-form-urlencoded
</powershell>



==================================================================================================================
3.4 Create the Auto Scaling Group
==================================================================================================================
#>

#3.4.6 Verify your new clients are registered with the monitoring server

invoke-webrequest 'http://localhost' | select -ExpandProperty content

<#
==================================================================================================================
3.5 Configure Powershell
==================================================================================================================
#>

# 3.5.3 Set the AWS_DEFAULT_REGION environment variable

[Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "[current-aws-region]", "User")

# 3.5.4 Enable Powershell script execution on the system

Set-ExecutionPolicy unrestricted

# 3.5.5 Run the poll-instances.ps1 script

c:\aws\poll-instances.ps1

<#
++++4. Create and Consume Auto Scaling Notifications ++++


==================================================================================================================
4.4 Consume Auto Scaling Notifications
==================================================================================================================
#>

# 4.4.3 Run the script

c:\consume-events.ps1

<#
==================================================================================================================
4.5 Test and Verify the Configuration
==================================================================================================================
#>

# 4.5.5 Verify the number of registered instances

invoke-webrequest 'http://localhost' | select -ExpandProperty content

<#
============================================================================================================================================


© 2013, 2014 Amazon Web Services, Inc. or its affiliates. All rights reserved.
#>