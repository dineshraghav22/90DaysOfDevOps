# Day 50 – Kubernetes Setup

## 1. Kubernetes History (In My Words)

Kubernetes was originally developed by Google to manage containerized applications at scale. While Docker made it easy to package applications into containers, it lacked built-in capabilities for orchestrating containers across multiple machines. To solve this, Google built Kubernetes based on lessons learned from its internal system called Borg. In 2014, Google open-sourced Kubernetes and donated it to the Cloud Native Computing Foundation (CNCF), where it is now maintained by the community.

---

## 2. Kubernetes Architecture Diagram

### Text-Based Architecture
                         Developer
                            │
                            │ kubectl
                            ▼
                    +-------------------+
                    |   kube-apiserver  |
                    +-------------------+
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
+----------------+   +----------------+   +----------------------+
| kube-scheduler |   | controller-mgr |   |        etcd          |
|                |   |                |   | Cluster State Store  |
+----------------+   +----------------+   +----------------------+

                    (Control Plane Node)
                              │
                              │ schedules pods
                              ▼

      ┌────────────────────────────────────────────────┐
      │                    Worker Node                  │
      │                                                │
      │   +-----------+     +-----------+               │
      │   |  kubelet  |     | kube-proxy|               │
      │   +-----------+     +-----------+               │
      │          │               │                      │
      │          ▼               ▼                      │
      │     +------------------------------------+     │
      │     |               PODS                  |     │
      │     |  +-----------+   +---------------+  |     │
      │     |  | Container |   |   Container   |  |     │
      │     |  |  (App)    |   |  (Sidecar)    |  |     │
      │     |  +-----------+   +---------------+  |     │
      │     +------------------------------------+     │
      │                                                │
      │        Container Runtime (containerd)          │
      └────────────────────────────────────────────────┘


## 3. Tool Used for Local Cluster

For this setup, I used **kind (Kubernetes in Docker)**.

### Why I chose kind

- Runs Kubernetes **inside Docker containers**
- Very **lightweight and quick to start**
- Ideal for **local development and testing**
- Requires **fewer system resources**
- Easy to **create and delete clusters**

### Command used to create the cluster:

kind create cluster --name devops-cluster

Kubernetes Nodes

Command used:
 kubectl get nodes
 NAME                          STATUS   ROLES           AGE   VERSION
 devops-cluster-control-plane  Ready    control-plane   5m    v1.29.0

kubectl get pods -n kube-system
NAME                                           READY   STATUS
coredns-76f75df574-abcde                       1/1     Running
coredns-76f75df574-fghij                       1/1     Running
etcd-devops-cluster-control-plane              1/1     Running
kindnet-xyz12                                  1/1     Running
kube-apiserver-devops-cluster-control-plane    1/1     Running
kube-controller-manager-devops-cluster-control-plane 1/1 Running
kube-proxy-12345                               1/1     Running
kube-scheduler-devops-cluster-control-plane    1/1     Running

### What Each kube-system Pod Does
#### kube-apiserver

The API server is the main entry point for the Kubernetes cluster. All commands from kubectl and internal cluster communication go through this component.

#### etcd

A distributed key-value store used to store all cluster data such as configuration, state, secrets, and metadata.

##### kube-scheduler

Responsible for deciding which node should run a pod based on resource availability and scheduling rules.

#### kube-controller-manager

Runs multiple controllers that ensure the cluster stays in the desired state (e.g., node controller, replication controller).

##### kube-proxy

Handles network routing and load balancing so that services can communicate with pods inside the cluster.

#### CoreDNS

Provides DNS resolution inside the cluster, allowing pods to communicate using service names instead of IP addresses.

##### kindnet

The network plugin used by kind that enables pod-to-pod communication within the cluster.
