#!/bin/bash

USERNAME=mysql_user
NODES=("10.128.1.52" "10.128.1.73" "10.128.1.90")
PROJECT_ID="salesmate-io"

# Configuration
today=$(date +%Y-%m-%d)
time=$(date +%H-%M)

echo "***************************************"
echo "*****set the project $PROJECT_ID*****"
echo "***************************************"
gcloud config set project $PROJECT_ID --quiet

check_mysql_service() {
    local node=$1
    echo "Checking MySQL service status on $node"

    # Login to Myserver server with SSH and check MySQL service status
    status=$(ssh -o StrictHostKeyChecking=no -i /mnt/mysql_user ${USERNAME}@$node 'systemctl is-active mysql')

    # Check if the service status is not active
    if [[ "$status" != "active" ]]; then
        echo "MySQL service is not active on $node. Triggering Zenduty alert."

        # Trigger Zenduty alert
        curl -X POST https://www.zenduty.com/api/events/f12ee444-3dc2-4f76-bd43-705512b88d6d/ \
             -H 'Content-Type: application/json' \
             -d "{\"alert_type\":\"critical\", \"message\":\"CRITICAL MySQL Service is not active for $node.\", \"summary\":\"Please check the issue.\", \"entity_id\":\"$today-$time\"}"
    else
        echo "MySQL service is active on $node."
    fi
}

# Loop through each node and check MySQL service
for node in "${NODES[@]}"; do
    check_mysql_service $node
done
