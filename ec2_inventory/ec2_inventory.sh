#!/bin/bash
set -euo pipefail
if [ $# -ne 1 ]; then 
    echo "Usage: $0 <region>"
    exit 1
fi 
if [[ ! "$1" =~ ^[a-z]+-[a-z]+-[0-9]+$ ]]; then 
    echo "Usage: Invalid region format. Expected something similar to 'us-east-1'"
    exit 1
fi

aws_region="$1"
region_found=false
read -ra available_regions <<< "$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)"
for region in "${available_regions[@]}" ; do 
        if [[ "$region" == "$aws_region" ]]; then 
        region_found=true
        fi
done 
if [[ "$region_found" == false ]]; then 
    echo "Entered region doesn't exist"
    exit 1
fi

aws ec2 describe-instances --region "$aws_region" | jq -r '.Reservations[].Instances[] | 
"Instance:
    ID: \(.InstanceId)
    Name: \((.Tags[]? | select(.Key == "Name") | .Value) // "N/A")
    State: \(.State.Name // "N/A")
    Type: \(.InstanceType)
    AvailabilityZone: \(.Placement.AvailabilityZone)
    NetworkInterfaces: 
    \(
        [
        .NetworkInterfaces[] |
        "   - PrivateIP: \(.PrivateIpAddress // "N/A")
         PublicIP: \(.Association.PublicIp // "N/A")"
        ] | join("\n")
    )
---"
'
