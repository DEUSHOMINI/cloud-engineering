#!/bin/bash
set -euo pipefail

validate_arguments() {
   [ "$#" -eq 1 ]
}

if ! validate_arguments "$@" ; then
    echo "Usage: $0 <region>"
    exit 1
fi

validate_region_format() {
    [[ "$1" =~ ^[a-z]+-[a-z]+-[0-9]+$ ]]
}
if ! validate_region_format "$1"; then 
    echo "Error: Invalid region format. Expected something like 'us-east-1'."
    exit 1
fi 

get_regions () {
aws ec2 describe-regions \
    --all-regions \
    --query 'Regions[].RegionName' \
    --output text
}

# get_available_regions() {
#     aws ec2 describe-regions --query 'Regions[].RegionName' --output text
# }

if ! regions="$(get_regions)" ; then 
    echo "Error: Failed to retrieve AWS regions." >&2 
    exit 1
fi 

read -ra available_regions <<< "$regions"

validate_region_exists() {
    local region
    for region in "${available_regions[@]}" ; do 
        if [[ "$1" == "$region" ]]; then 
        return 0 
        fi
    done
    return 1
}
if ! validate_region_exists "$1" ; then 
    echo "Error: Region does not exist." >&2
    exit 1
fi
describe_instances() {
    aws ec2 describe-instances --region "$1"
}

if ! describe_instances "$1" | jq -r --arg region "$1" '[.Reservations[].Instances[]] as $instances |
    if ($instances | length) == 0 
        then 
        "No instances found in \($region)." 
        else 
        $instances[] | "Instance:
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
    end'; 
then
    echo "Error: Failed to describe EC2 instances." >&2
    exit 1
fi 
