## Demo Application 
Application that runs on Java is set Up.( code :- src/, pom.xml) <br />
Jenkinsfile - run CICD through Jenkins. <br />
# Stages in Jenkins Pipeline
Checkout <br />
Build <br />
Docker Build and Push <br />
Update Chart Info - semantic Version (at charts/flux-test-app/Chart.yaml) will be bumped up using readYaml and writeYaml from  Pipeline Utilities Plugin. <br />
Dev Promotion - image.tag will be updated at charts/flux-test-app/values-dev.yaml using readYaml and writeYaml from  Pipeline Utilities Plugin <br />
Staging Promotion - image.tag will be updated at charts/flux-test-app/values-stging.yaml using readYaml and writeYaml from  Pipeline Utilities Plugin <br />
Git Push - Push all updates to Repository <br />

## FluxCD Installation
https://fluxcd.io/flux/installation/

## Instructions for Minikube Set UP
minikube delete && minikube start --driver=hyperkit --cpus=4 --memory=6g <br />
minikube addons enable ingress <br />
export INGRESS_HOST=$(minikube ip) <br />

# Set Git repository Credentials fo bootstrapping
# Git Creds
export GITHUB_USER=<Username> <br />
export GITHUB_TOKEN=<Token value> <br />

## Flux Bootsrap Command for k8 cluster infra

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=fleet-infra \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal

## In case, a local docker registry needs to be run on minikube
https://minikube.sigs.k8s.io/docs/handbook/registry/
# Cmds
 minikube addons enable registry <br />
 docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000" <br />


# Steps to set Up Helm Releases
1) Create secret with Git Authentication Credentials.

flux create secret git flux-test-app-secret \
--url=https://github.com/pardhap18/flux-test-app-cicd \
--username=<\Username/> \
--password=<\Token/>

2) Create HelmRepository/GitSource k8 object. Depends on the organization of helm charts.
Here, Helm Charts are placed along with the application code. Hence Git Source Object (fluxcd/repository.yaml) is created

3) Create HelmRelease k8 Object 
Created two HelmRelease Objects - (fluxcd/dev/release.yaml and fluxcd/staging/release.yaml) for namespaces - dev and staging.

# Handy Commands to check status on FluxCD Objects
flux get all -A --status-selector ready=false <br />
helm history <Helm release name> -n <namespace> <br />




