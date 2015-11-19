#
(Get-IAMUser | select -first 1 | select -ExpandProperty arn) -match ':\d+:'
[int64]$accountID = $matches[0] -replace ':',''

if($accountID -ne $(read-host "Confirm the ID of the account of which you wish to delete the contents")){
    throw "STOP OH GOD ITS THE WRONG ACCOUNT, it's $accountID"
}

foreach($region in Get-AWSRegion){

    Write-Host "Running through $($region.region)";
    Set-DefaultAWSRegion $region.Region


    Write-Host "Terminating EC2 Instances"
    (Get-EC2Instance).Instances | ?{$_.instanceid} | %{ Edit-EC2InstanceAttribute -Attribute DisableApiTermination -Value $false -InstanceId $_.InstanceId}
    Get-EC2Instance | Stop-EC2Instance -Terminate -Force

    $filter = New-Object Amazon.EC2.Model.Filter -Property @{Name = "platform"; Values = $platform_values}



    Write-Host "Removing RDS instances"
    Get-RDSDBInstance | Remove-RDSDBInstance -Force -SkipFinalSnapshot:$True

    Write-Host "Removing RDS Snapshots"
    Get-RDSDBSnapshot | %{$_ | Remove-RDSDBSnapshot -Force -ErrorAction Continue}

    Write-Host "Removing Internet Gateways"
    Get-EC2InternetGateway | %{$igwid = $_.InternetGatewayId;$_.attachments | %{Dismount-EC2InternetGateway -VpcId $_.vpcid -InternetGatewayId $igwid}}
    Get-EC2InternetGateway | Remove-EC2InternetGateway -ErrorAction Continue -Force

    Write-Host "Deleting security groups"
    Get-EC2SecurityGroup | %{$_ | Remove-EC2SecurityGroup -force}


    Write-Host "Removing routes"
    Get-EC2RouteTable | %{
        $routetableid = $_.routetableid
        $_.routes | %{Remove-EC2Route -DestinationCidrBlock $_.DestinationCidrBlock -RouteTableId $routetableid -Force}
    }

    Write-Host "Removing route tables"
    Get-EC2RouteTable | %{$_ | Remove-EC2RouteTable -Force}

    Write-Host "Removing Subnets"
    Get-EC2Subnet | %{$_ | Remove-EC2Subnet -Force}


    Write-Host "Removing VPCs"
    Get-EC2Vpc | %{$_ | Remove-EC2Vpc -Force}

    Write-Host "Removing CFN Stacks"
    Get-CFNStack | Remove-CFNStack -Force

    Write-Host "Deleting Snapshots"
    Get-EC2Snapshot | Remove-EC2Snapshot -Force

    Write-Host "Deleting volumes"
    Get-EC2Volume | Remove-EC2Volume -Force

    Write-Host "Deleting ELBs"
    Get-ELBLoadBalancer | %{$_ | Remove-ELBLoadBalancer -force}

    Write-Host "Deleting Auto Scaling Groups"
    Get-ASAutoScalingGroup | %{$_ | Remove-ASAutoScalingGroup -Force}

    Write-Host "Deleting Launch Configurations"
    Get-ASLaunchConfiguration | %{$_ | Remove-ASLaunchConfiguration -Force}

    Write-Host "Delete S3 Buckets"
    Get-S3Bucket -Region $region.Region | %{$_ | Remove-S3Bucket -Force}
}
    