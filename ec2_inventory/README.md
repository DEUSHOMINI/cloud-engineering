# EC2 Inventory Script

A Bash script that retrieves and displays an inventory of Amazon EC2 instances in a specified AWS Region.

The script combines **Bash**, **AWS CLI**, and **jq** to query AWS resources, validate the requested region, and transform the returned JSON into a human-readable report.

## Features

- Validates the number of command-line arguments
- Validates AWS Region format using Bash regular expressions
- Verifies that the specified Region is available
- Retrieves EC2 instances using the AWS CLI
- Extracts:
  - Instance ID
  - Name tag
  - Instance state
  - Instance type
  - Availability Zone
  - Private IP address
  - Public IP address
- Handles missing Name tags and public IP addresses
- Supports instances with multiple network interfaces
- Produces structured, human-readable output

## Requirements

- Linux or macOS
- Bash
- AWS CLI
- jq
- Configured AWS credentials with permission to call:
  - `ec2:DescribeRegions`
  - `ec2:DescribeInstances`

Verify the required tools:

```bash
aws --version
jq --version
```

Verify your AWS credentials:

```bash
aws sts get-caller-identity
```

## Usage

Make the script executable:

```bash
chmod +x lab13_ec2_inventory.sh
```

Run it by providing an AWS Region:

```bash
./lab13_ec2_inventory.sh us-east-1
```

Example:

```text
Instance:
   ID: i-0123456789abcdef0
   Name: aws_linux_1
   State: running
   Type: t3.micro
   AvailabilityZone: us-east-1d
   NetworkInterfaces:
      - PrivateIP: 172.31.3.239
        PublicIP: 3.85.211.208
---
```

## How It Works

The script performs the following steps:

1. Checks that exactly one argument was provided.
2. Validates the Region format using a Bash regular expression.
3. Retrieves the list of available AWS Regions.
4. Checks whether the requested Region exists in that list.
5. Calls `aws ec2 describe-instances` for the selected Region.
6. Pipes the JSON response to `jq`.
7. Extracts and formats the relevant EC2 instance information.
8. Displays the resulting inventory.

## Technologies

- **Bash** — scripting, argument handling, arrays, loops, conditionals, regular expressions
- **AWS CLI** — interaction with AWS EC2 APIs
- **jq** — JSON parsing, filtering, transformation, and formatting

## Example

```bash
./lab13_ec2_inventory.sh us-east-1
```

The script can also be used to check another Region:

```bash
./lab13_ec2_inventory.sh us-west-2
```

If the Region is syntactically valid but unavailable, the script exits with an error.

## Learning Objectives

This project was created as part of a practical Cloud Engineering learning path.

The main objectives are:

- Practice Bash scripting for cloud automation
- Work with command-line arguments
- Use Bash arrays and loops
- Validate user input with regular expressions
- Work with AWS CLI output
- Parse nested JSON using jq
- Handle missing AWS resource attributes safely
- Build readable command-line reports

## Security

The script does not contain AWS credentials or access keys.

AWS authentication is handled through the AWS CLI configuration/environment. Never commit credentials, private keys, or other secrets to the repository.
