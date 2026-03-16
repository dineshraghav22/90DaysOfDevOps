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

```bash
kind create cluster --name devops-cluster --image kindest/node:v1.31.2
```

### Kubernetes Nodes

```
$ kubectl get nodes -o wide
NAME                           STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                       CONTAINER-RUNTIME
devops-cluster-control-plane   Ready    control-plane   84s   v1.31.2   172.19.0.2    <none>        Debian GNU/Linux 12 (bookworm)   5.4.17-2136.344.4.3.el8uek.x86_64   containerd://1.7.18
```

### kube-system Pods

```
$ kubectl get pods -n kube-system
NAME                                                   READY   STATUS    RESTARTS   AGE
coredns-7c65d6cfc9-knvd6                               1/1     Running   0          87s
coredns-7c65d6cfc9-zbwdl                               1/1     Running   0          87s
etcd-devops-cluster-control-plane                      1/1     Running   0          94s
kindnet-8stpx                                          1/1     Running   0          88s
kube-apiserver-devops-cluster-control-plane            1/1     Running   0          94s
kube-controller-manager-devops-cluster-control-plane   1/1     Running   0          95s
kube-proxy-56jb2                                       1/1     Running   0          88s
kube-scheduler-devops-cluster-control-plane            1/1     Running   0          94s
```

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

---

## 4. Issue Faced: kind Cluster Creation Failed

### The Problem

When running `kind create cluster --name devops-cluster`, the cluster creation failed with:

```
✗ Starting control-plane 🕹️
ERROR: failed to create cluster: failed to init node with kubeadm
```

The kubelet inside the kind container could not start:

```
[kubelet-check] The kubelet is not healthy after 4m0s
- The kubelet is not running
- The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)
```

### Investigation

1. **First suspicion — Docker cgroup driver**: We initially thought the issue was related to the Docker cgroup driver (`cgroupfs` vs `systemd`). We tried switching Docker to `systemd` cgroup driver and back, but the error persisted with both drivers.

2. **Checked the system cgroup version**:
   ```bash
   stat -fc %T /sys/fs/cgroup/
   # Output: tmpfs  → This means cgroup v1
   ```

3. **Found the real cause — version mismatch**:
   - kind version: `v0.32.0-alpha` (alpha/pre-release)
   - Default node image: `kindest/node:v1.35.1` (Kubernetes 1.35 — bleeding-edge alpha)
   - Host kernel: `5.4.17-2136.344.4.3.el8uek.x86_64` (Oracle Linux UEK)

   Kubernetes v1.35.1 is an alpha release that requires newer kernel features not available on kernel 5.4.17. The kubelet could not start inside the kind container because of this incompatibility.

### The Fix

Used a stable, compatible Kubernetes node image instead of the default alpha one:

```bash
kind create cluster --name devops-cluster --image kindest/node:v1.31.2
```

This worked immediately — all control plane components started without any issues.

### Key Takeaways

- **Always check version compatibility** between kind, the node image, and your host kernel
- **Avoid alpha/pre-release versions** of kind and Kubernetes for learning and development
- When kind fails with kubelet errors, the problem may not be cgroup-related — check the **Kubernetes version** first
- Use `--image kindest/node:v1.x.x` to pin a specific stable Kubernetes version
- Docker's `cgroupfs` driver works fine with kind on cgroup v1 systems — no need to switch to `systemd`

### Docker Cgroup Driver: cgroupfs vs systemd

| Scenario | Recommended Driver |
|---|---|
| kind (Kubernetes in Docker) on cgroup v1 | `cgroupfs` |
| kubeadm cluster on bare-metal/VM | `systemd` |
| cgroup v2 systems | `systemd` |

On our system (cgroup v1), `cgroupfs` is the correct choice for Docker when using kind.
