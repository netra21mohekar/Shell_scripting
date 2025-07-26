#!/bin/bash

check_awscli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Installing now..." >&2
        return 1  # Return failure so install_awscli runs
    else
        echo "AWS CLI is already installed"
        return 0  # Return success
    fi
}

install_awscli() {
    echo "Installing AWS CLI v2 on Linux..."
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt-get install -y unzip &> /dev/null
    unzip -q awscliv2.zip
    sudo ./aws/install
    aws --version
    rm -rf awscliv2.zip ./aws
    echo "AWS CLI installation completed!"
}

wait_for_instance() {
    local instance_id="$1"
    echo "Waiting for instance $instance_id to be in running state..."
    while true; do
        state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
        if [[ "$state" == "running" ]]; then
            echo "Instance $instance_id is now running."
            break
        fi
        sleep 10
    done
}

create_ec2_instance() {
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"
    
    echo "Launching EC2 instance with parameters:"
    echo "  AMI ID: $ami_id"
    echo "  Instance Type: $instance_type"
    echo "  Key Name: $key_name"
    echo "  Subnet ID: $subnet_id"
    echo "  Security Group: $security_group_ids"
    
    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids "$security_group_ids" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )
    
    if [[ -z "$instance_id" ]]; then
        echo "Failed to create EC2 instance." >&2
        exit 1
    fi
    
    echo "Instance $instance_id created successfully."
    wait_for_instance "$instance_id"
}

main() {
    echo "=== AWS EC2 Instance Creation Script ==="
    
    # Check and install AWS CLI if needed
    if ! check_awscli; then
        install_awscli
    fi
    
    echo "Creating EC2 instance..."
    
    # Instance parameters
    AMI_ID="ami-0f918f7e67a3323f0"
    INSTANCE_TYPE="t3.micro"
    KEY_NAME="Shell_scripting_key"
    SUBNET_ID="subnet-0e928acf4490a214b"
    SECURITY_GROUP_IDS="sg-08c1f0ad11c8e0a99"
    INSTANCE_NAME="Shell-Script-EC2-Demo"
    
    # Create the instance
    create_ec2_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"
    
    echo "EC2 instance creation completed."
}

main "$@"
