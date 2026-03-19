# Day 51 – Kubernetes Manifests and Your First Pods

## The Four Required Fields of a Kubernetes Manifest

| Field | Purpose | Example |
|-------|---------|---------|
| `apiVersion` | Which Kubernetes API version to use for this resource | `v1` for Pods |
| `kind` | The type of resource being created | `Pod`, `Deployment`, `Service` |
| `metadata` | Identity of the resource — name, labels, namespace | `name: nginx-pod`, `labels: {app: nginx}` |
| `spec` | The desired state — what containers to run, images, ports, commands | `containers: [{name: nginx, image: nginx}]` |

---

## Running Pods Output

```
$ kubectl get pods -o wide
NAME          READY   STATUS    RESTARTS   AGE   IP            NODE                           NOMINATED NODE   READINESS GATES
busybox-pod   1/1     Running   0          15s   10.244.0.10   devops-cluster-control-plane   <none>           <none>
devops-app    1/1     Running   0          15s   10.244.0.11   devops-cluster-control-plane   <none>           <none>
nginx-pod     1/1     Running   0          15s   10.244.0.9    devops-cluster-control-plane   <none>           <none>
```

```
$ kubectl get pods --show-labels
NAME          READY   STATUS    RESTARTS   AGE    LABELS
busybox-pod   1/1     Running   0          106s   app=busybox,environment=dev
devops-app    1/1     Running   0          106s   app=devops-tool,environment=staging,team=platform
nginx-pod     1/1     Running   0          106s   app=nginx
```

---

## Pod Manifests

### 1. nginx-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

**Applied and verified:**
```
$ kubectl get pods -o wide
NAME        READY   STATUS    AGE   IP           NODE
nginx-pod   1/1     Running   43s   10.244.0.5   devops-cluster-control-plane
```

**Curled from inside the pod:**
```bash
kubectl exec nginx-pod -- curl -s localhost:80
# Returns: <!DOCTYPE html>... Welcome to nginx! ...
```

**Describe output (key fields):**
```
Name:         nginx-pod
Namespace:    default
Node:         devops-cluster-control-plane/172.19.0.2
IP:           10.244.0.5
Container:    nginx (containerd://d9cf0de4...)
Image:        nginx:latest
Port:         80/TCP
State:        Running
Ready:        True
Restart Count: 0
```

---

### 2. busybox-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

```
$ kubectl logs busybox-pod
Hello from BusyBox
```

**Why the `command` field?** BusyBox doesn't run a long-lived process by default. Without `sleep 3600`, the container exits immediately and the pod enters `CrashLoopBackOff`. The command keeps it alive for 1 hour.

---

### 3. multi-label-pod.yaml (3+ labels)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: devops-app
  labels:
    app: devops-tool
    environment: staging
    team: platform
spec:
  containers:
  - name: alpine
    image: alpine:latest
    command: ["sh", "-c", "echo DevOps multi-label pod running && sleep 3600"]
```

```
$ kubectl logs devops-app
DevOps multi-label pod running
```

---

## Imperative vs Declarative

### Imperative (quick, no YAML file)
```bash
kubectl run redis-pod --image=redis:latest
```

### Declarative (YAML file, version-controllable)
```bash
kubectl apply -f nginx-pod.yaml
```

### Dry-run to scaffold YAML
```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

**Output:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: test-pod
  name: test-pod
spec:
  containers:
  - image: nginx
    name: test-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
```

### Differences from hand-written manifest
- Dry-run adds `resources: {}`, `dnsPolicy`, `restartPolicy`, `status: {}`
- Label uses `run: test-pod` (auto-generated) vs our explicit `app: nginx`
- Hand-written is cleaner; dry-run is faster to scaffold

**When to use which:**
- **Imperative** — quick testing, one-off debugging
- **Declarative** — production, GitOps, repeatable deployments (always prefer this)

---

## Validation with --dry-run

```bash
# Client-side validation (checks YAML structure locally)
kubectl apply -f nginx-pod.yaml --dry-run=client

# Server-side validation (checks against cluster API)
kubectl apply -f nginx-pod.yaml --dry-run=server
# pod/nginx-pod unchanged (server dry run)
```

**When image field is missing:** Kubernetes returns:
```
error: error validating data: ValidationError(Pod.spec.containers[0]):
missing required field "image"
```

---

## Labels and Filtering

**All pods with labels:**
```
$ kubectl get pods --show-labels
NAME          READY   STATUS    LABELS
busybox-pod   1/1     Running   app=busybox,environment=dev
devops-app    1/1     Running   app=devops-tool,environment=staging,team=platform
nginx-pod     1/1     Running   app=nginx
redis-pod     1/1     Running   run=redis-pod
```

**Filter by label:**
```bash
kubectl get pods -l app=nginx           # only nginx-pod
kubectl get pods -l environment=dev     # only busybox-pod
kubectl get pods -l team=platform       # only devops-app
```

**Add a label to existing pod:**
```bash
kubectl label pod nginx-pod environment=production
# nginx-pod now has: app=nginx,environment=production
```

**Remove a label:**
```bash
kubectl label pod nginx-pod environment-
```

---

## Cleanup

```bash
kubectl delete pod nginx-pod busybox-pod devops-app redis-pod
kubectl get pods
# No resources found in default namespace.
```

**What happens when you delete a standalone Pod?** It's gone forever. No controller recreates it. This is why production workloads use **Deployments** (Day 52) — they ensure the desired number of pod replicas always exist.

---

## What I Learned

1. **Every K8s manifest has 4 required fields** — `apiVersion`, `kind`, `metadata`, `spec`. Memorize this structure and you can write any resource from scratch.
2. **`--dry-run=client -o yaml` is a shortcut** — instead of writing YAML from memory, scaffold it with dry-run, then customize. Faster and fewer typos.
3. **Labels are the glue of Kubernetes** — they have no meaning to K8s itself, but Services, Deployments, and selectors all use labels to find and manage pods. Well-labeled resources are well-organized resources.
