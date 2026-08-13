#!/usr/bin/env bash

set -e

SOURCE_JAR="$HOME/projects/spring-petclinic/target/spring-petclinic-4.0.0-SNAPSHOT.jar"
DEPLOY_JAR="/opt/petclinic/petclinic.jar"
BACKUP_JAR="/opt/petclinic/petclinic.jar.bak"
EXPECTED_TEXT="Welcome to my automated deployment"

echo "1. Creating backup"

sudo cp "$DEPLOY_JAR" "$BACKUP_JAR"

echo "2. Stopping System"

sudo systemctl stop petclinic

echo "3. Deploying new jar"

sudo cp "$SOURCE_JAR" "$DEPLOY_JAR"
sudo chown petclinic:petclinic "$DEPLOY_JAR"

echo "4. Start system"

sudo systemctl start petclinic

echo "5. waiting for app start"

for i in {1..30}; do
if curl -fsS http://localhost:8080 > /dev/null; then
echo "Application is ready"
break
fi
echo "Still waiting..."
sleep 2
done

echo "6. Running health check"

curl -fsS http://localhost:8080 > /dev/null

echo "7. Running smoke test"

curl -fsS http://localhost:8080 | grep -F "Welcome to my automated deployment" > /dev/null

echo "Deployment successful."

