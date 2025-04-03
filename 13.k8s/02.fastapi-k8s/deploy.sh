#!/bin/bash

set -e # Stop on error

# kubectl delete all --all # Delete all the pods and services running

# Remove the Docker images
docker rmi fastapi-image-test-k8 || true # || true means if error comes, skip onto next process
docker rmi doohwancho/fastapi-image-test-k8 || true

# Delete all the Kubernetes deployments
# kubectl delete deployment fastapi-deployment || true
# kubectl delete deployment mongo-express-deployment || true
# kubectl delete deployment kibana-deployment || true
# kubectl delete deployment logstash-deployment || true
# kubectl delete deployment elasticsearch-deployment || true
kubectl delete deployments --all

# Delete the Services
kubectl delete services fastapi-app-service || true
kubectl delete services mongo-express-service || true
kubectl delete services mongodb-service || true
kubectl delete services kibana-service || true
kubectl delete services logstash-service || true
kubectl delete services elasticsearch-service || true

# Delete all StatefulSets
# kubectl delete  statefulset mongodb-stateful || true
kubectl delete  statefulsets --all


# Build the Docker image
docker build --no-cache -t fastapi-image-test-k8 ./fastapi_code/.

# Tag and push the Docker image
docker tag fastapi-image-test-k8 doohwancho/fastapi-image-test-k8
docker push doohwancho/fastapi-image-test-k8

# Apply all the files in stepwise manner
# kubectl apply -f ./k8_configs/storage-class.yaml
kubectl apply -f ./k8_configs/mongo_secrets.yaml # secrets
kubectl apply -f ./k8_configs/mongo_configmap.yaml # Configs
kubectl apply -f ./k8_configs/mongo_depl_serv.yaml # DB should be run first. One files has deployment and service

# Wait for MongoDB StatefulSet to create the pod
echo "Waiting for MongoDB pod to be created..."
sleep 10  # Give Kubernetes some time to create the pod

# Check if the pod exists before waiting for it to be ready
POD_EXISTS=false
for i in {1..10}; do
  if kubectl get pod mongodb-stateful-0 >/dev/null 2>&1; then
    POD_EXISTS=true
    break
  fi
  echo "Waiting for MongoDB pod to be created... attempt $i/10"
  sleep 5
done

if [ "$POD_EXISTS" = true ]; then
  echo "MongoDB pod created, waiting for it to be ready..."
  kubectl wait --for=condition=Ready pod/mongodb-stateful-0 --timeout=180s
else
  echo "ERROR: MongoDB pod was not created within the timeout period."
  kubectl get pods
  exit 1
fi

# Then deploy the next service (e.g., Mongo Express)
kubectl apply -f ./k8_configs/mongo_express_depl_serv.yaml # One file for both deployment and service

# run the rest
kubectl apply -f ./k8_configs/fastapi_deployment_file.yaml # FastAPI Deployment pod
kubectl apply -f ./k8_configs/fastapi_service_file.yaml # FastAPI service

# ELK
kubectl apply -f ./k8_configs/elastic_depl_serv.yaml # Elastic Search
kubectl apply -f ./k8_configs/logstash_depl_serv.yaml  # Logstash
kubectl apply -f ./k8_configs/kibana_depl_serv.yaml  # kibana dashboard
kubectl apply -f ./k8_configs/ingress.yaml # Enable ingress for routing

echo "All deployments completed. Checking pod status:"
kubectl get pods