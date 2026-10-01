# EC2 Inventory

A Bash script that retrieves and displays EC2 instance information for a specified AWS region.

The script validates the region, queries AWS for EC2 instances, and formats the result using `jq`.

## Features

- Validates the number of command-line arguments.
- Validates the AWS region format.
- Checks whether the specified region exists.
- Retrieves EC2 instance information using the AWS CLI.
- Displays:
  - Instance ID
  - Name
  - State
  - Instance type
  - Availability Zone
  - Private IP address
  - Public IP address
- Reports when a region contains no EC2 instances.
- Preserves AWS API error messages.
- Uses Bash exit statuses to distinguish successful and failed operations.

## Requirements

The following tools must be installed and configured:

- Bash
- AWS CLI
- `jq`
- Valid AWS credentials with permission to call:
  - `ec2:DescribeRegions`
  - `ec2:DescribeInstances`

Verify your AWS credentials with:

```bash
aws sts get-caller-identity
```

## Installation

Clone or download the repository and enter the project directory:

```bash
cd ec2_inventory
```

Make the script executable:

```bash
chmod +x ec2_inventory.sh
```

## Usage

```bash
./ec2_inventory.sh <region>
```

Example:

```bash
./ec2_inventory.sh us-east-1
```

## Example: Instances Found

```text
Instance:
    ID: i-0ac48cf07c94a569b
    Name: test_aws_linux
    State: running
    Type: t3.micro
    AvailabilityZone: us-east-1b
    NetworkInterfaces:
       - PrivateIP: 172.31.24.82
         PublicIP: 54.210.39.26
    ---
```

## Example: No Instances

If the region exists and the AWS API request succeeds, but there are no EC2 instances:

```text
No instances found in us-west-2.
```

This is considered a successful operation and returns exit status `0`.

## Error Handling

### Missing argument

```bash
./ec2_inventory.sh
```

Output:

```text
Usage: ./ec2_inventory.sh <region>
```

### Invalid or nonexistent region

```bash
./ec2_inventory.sh us-post-2
```

Output:

```text
Error: Region does not exist.
```

The script exits with a non-zero status.

### AWS API errors

If AWS cannot execute the `DescribeInstances` request, the AWS CLI error is displayed and the script reports:

```text
Error: Failed to describe EC2 instances.
```

The script exits with a non-zero status.

AWS errors are not replaced or interpreted by the script; the original AWS error is preserved.

## Exit Status

| Exit status | Meaning |
|---:|---|
| `0` | Successful operation |
| `1` | Validation or AWS API error |

A region containing no EC2 instances is still considered a successful operation and returns `0`.

## Implementation

The script uses:

```bash
set -euo pipefail
```

It separates the main tasks into Bash functions:

- `validate_arguments`
- `validate_region_format`
- `get_regions`
- `validate_region_exists`
- `describe_instances`

AWS JSON output is processed with `jq`.

The script uses:

```bash
aws ec2 describe-regions --all-regions
```

to obtain the list of AWS regions. It does not separately evaluate `OptInStatus`; if a region exists but the account cannot perform the EC2 operation there, the AWS API error is allowed to reach the user.