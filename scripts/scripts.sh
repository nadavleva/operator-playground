# Create cluster
kind create cluster

# Cluster info
kubectl cluster-info

# Get all namespaces
kubectl get namespaces

# Get all pods
kubectl get pods --all-namespaces




# Delete cluster
kind delete cluster


# Check kubebuilder version
kubebuilder version

# For AMD64 / x86_64
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)

# For ARM64
# curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/linux/arm64

# Move kubebuilder to /usr/local/bin
chmod +x kubebuilder
sudo mv kubebuilder /usr/local/bin/


# verify kubebuilder installation
kubebuilder version
#Version: cmd.version{KubeBuilderVersion:"4.8.0", KubernetesVendor:"1.33.0", GitCommit:"a069bf1a12785fa210409c558ae668565296c675", BuildDate:"2025-08-27T11:08:55Z", GoOs:"linux", GoArch:"amd64"}
nlevanon@nlevanon-thinkpadp1gen7:~/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles$ which kubebuilder 
#/usr/local/bin/kubebuilder


## Chapter 2
# Create cniinf project for cloud native infrastructure operator
## Ch 02_02 Begin
mkdir cninf
cd cninf

kubebuilder init --domain nadavleva.github.io --repo github.com/nadavleva/operator

## Ch 02_04 Begin 
# This is the command in the course - you need to execute all the command from the chaper 02_02 until here
kubebuilder create api --group cninf --version v1alpha1 --kind ObjStore

## Ch 02_05 Build A Custom Resource (RC)
# Generate manifests for the ObjStore custom resource
make manifests

# Install the ObjStore custom resource
make install

# Get the ObjStore custom resource
kubectl get crds 
NAME                                  CREATED AT
objstores.cninf.nadavleva.github.io   2025-08-31T18:20:06Z

# Get the ObjStore custom resource explain
kubectl explain objstore
NAME                         TYPE      DATA   AGE
objstore                     Object    true   12s
objstore.cninf.nadavleva.github.io/v1alpha1/ObjStore/Spec     Object   false   12s
objstore.cninf.nadavleva.github.io/v1alpha1/ObjStore/Status   Object   false   12s

# Get the ObjStore custom resource spec
kubectl explain objstore.spec

# Get the ObjStore custom resource definition
kubectl get crds objstores.cninf.nadavleva.github.io -o yaml | less



# Create ns for applying the sample
kubectl create namespace obstra1

# Apply the sample on the namespace
kubectl apply -n obstra1 -f config/samples/cninf_v1alpha1_objstore.yaml 

# Create a ObjStore custom resource
kubectl apply -f config/samples/cninf_v1alpha1_objstore.yaml
# Get the ObjStore custom resource
kubectl get crd -n obstra1 objstores.cninf.nadavleva.github.io -o yaml

# Get the ObjStore custom resource
kubectl get ObjStore -n obstra1

# Get the ObjStore custom resource definition
kubectl get ObjStore -n obstra1 -o yaml

# Getgthe ObjStore custom resource description using the describe command
kubectl describe ObjStore objstore-sample-a1 -n obstra1 

# Delete the ObjStore custom resource
kubectl delete ObjStore objstore-sample-a1 -n obstra1 
objstore.cninf.nadavleva.github.io "objstore-sample-a1" deleted

# delete the crd   
kubectl delete crd objstores.cninf.nadavleva.github.io -n obstra1


# implement the controller and then run the operator
make 



# Run the operator
make run




# make commands

make
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
go build -o bin/manager cmd/main.go
nlevanon@nlevanon-thinkpadp1gen7:~/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf$ make manifests 
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
nlevanon@nlevanon-thinkpadp1gen7:~/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf$ make generate 
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
nlevanon@nlevanon-thinkpadp1gen7:~/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf$ make install 
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/kustomize build config/crd | kubectl apply -f -
customresourcedefinition.apiextensions.k8s.io/objstores.cninf.nadavleva.github.io created
nlevanon@nlevanon-thinkpadp1gen7:~/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf$ make run
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
/home/nlevanon/Learning/extending-kubernetes-with-operator/Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
go run ./cmd/main.go



















## 02_05 Development Scripts
# Created helpful development scripts in the 02_05 project directory:
# ./dev-restart.sh     - Stop, rebuild, and restart controller (full development cycle)
# ./stop-controller.sh - Stop running controller cleanly
# ./rebuild.sh         - Rebuild controller binary only

# Full documentation available in: Ex_Files_Extending_Kubernetes_Operator_Patterns/ExerciseFiles/Chapter2/02_05/cninf/README.md

# Fixed context switching with validation - use switch-context.sh script
