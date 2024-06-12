#!/bin/bash

cd "/mnt/c/Users/user/Desktop/terraform/test-repo/vpc"
terraform apply -auto-approve
cd "/mnt/c/Users/user/Desktop/terraform/test-repo/eks"
terraform apply -auto-approve

cd "/mnt/c/Users/user/Desktop/terraform/test-repo/grafana/kube-prometheus/manifests"
kubectl create -f manifests/setup

until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

kubectl create -f manifests/

cd "/mnt/c/Users/user/Desktop/terraform/test-repo/grafana/kube-prometheus"




# create for loop 5 folders

# Path: creation_script.sh

#!/bin/bash

for i in {1..5}
do
   mkdir "folder$i"
done
