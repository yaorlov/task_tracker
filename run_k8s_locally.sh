#!/bin/sh
set -e

echo "Step 1. Start minikube"
minikube start
# Set docker-env to create docker images inside minikube
eval $(minikube -p minikube docker-env)

echo "Step 2. Building Docker images..."

echo "1/4 Build auth service image..."
cd ./auth
docker build . -t auth # removed :v1 tag here. not needed in Tilt?
cd ..

echo "2/4 Build analytics service image..."
cd ./analytics
docker build . -t analytics
cd ..

echo "3/4 Build billing service image..."
cd ./billing
docker build . -t billing
cd ..

echo "4/4 Build task_tracking service image..."
cd ./task_tracking
docker build . -t task_tracking
cd ..

echo "Step 3. Create k8s Deployments and Services..."

echo "Create Kafka and Zookeeper..."
kubectl create -f ./.k8s/namespace.yaml --dry-run=client -o yaml | kubectl apply -f -
# Note:
# create commany output is piped to apply command to avoid errors when a resource already exists
# Note:
# if minikube fails to pull the docker image, use `minikube ssh docker pull image_name`
# more info about the issue: https://github.com/kubernetes/minikube/issues/14806
kubectl create -f ./.k8s/kafka/zookeeper_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/kafka/zookeeper_service.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/kafka/kafka_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/kafka/kafka_service.yaml --dry-run=client -o yaml | kubectl apply -f -
# Note:
# To ensure that Zookeeper and Kafka can communicate by using this hostname (kafka-broker),
# we need to add the following entry to the /etc/hosts file on our local machine:
# 127.0.0.1 kafka-broker

# eval $(minikube docker-env) # place here?

echo "Create Postgres..."
kubectl create -f ./.k8s/pg/pg_config.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/pg/pg.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/pg/pg_pv.yaml --dry-run=client -o yaml | kubectl apply -f -

echo "Create services..."
kubectl create -f ./.k8s/services/auth_config.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/auth_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/auth_db_setup.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/auth_service.yaml --dry-run=client -o yaml | kubectl apply -f -

kubectl create -f ./.k8s/services/analytics_config.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/analytics_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/analytics_db_setup.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/analytics_service.yaml --dry-run=client -o yaml | kubectl apply -f -

kubectl create -f ./.k8s/services/billing_config.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/billing_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/billing_db_setup.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/billing_service.yaml --dry-run=client -o yaml | kubectl apply -f -

kubectl create -f ./.k8s/services/task_tracker_config.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/task_tracker_deployment.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/task_tracker_db_setup.yaml --dry-run=client -o yaml | kubectl apply -f -
kubectl create -f ./.k8s/services/task_tracker_service.yaml --dry-run=client -o yaml | kubectl apply -f -
echo "Services are created!"

echo "Step 4. Open services URLs in browser"
minikube service auth-svc -n task-tracker
minikube service analytics-svc -n task-tracker
minikube service billing-service -n task-tracker
minikube service task-tracking-service -n task-tracker
