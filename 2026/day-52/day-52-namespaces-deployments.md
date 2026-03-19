# Day 52 – Kubernetes Namespaces and Deployments

## Namespaces

Namespaces are virtual clusters inside a physical cluster. They isolate resources — pods in `dev` don't see pods in `staging`.

### Default Namespaces
```
$ kubectl get namespaces
NAME                 STATUS   AGE
default              Active   3d1h
kube-node-lease      Active   3d1h
kube-public          Active   3d1h
kube-system          Active   3d1h
local-path-storage   Active   3d1h
```

- `default` — where resources go if no namespace is specified
- `kube-system` — K8s internal components (8 pods running: apiserver, etcd, scheduler, controller-manager, coredns x2, kube-proxy, kindnet)

### Custom Namespaces Created
```bash
kubectl create namespace dev
kubectl create namespace staging
kubectl apply -f namespace.yaml   # creates 'production' namespace
```

---

## Deployment Manifest — nginx-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
        ports:
        - containerPort: 80
```

**Key sections:**
- `replicas: 3` — maintain 3 pods at all times
- `selector.matchLabels` — must match `template.metadata.labels`
- `template` — the pod blueprint the Deployment uses to create pods

### Running Output

```
$ kubectl get deployments -n dev
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           15s

$ kubectl get pods -n dev -o wide
NAME                                READY   STATUS    IP            NODE
nginx-deployment-64dd99d679-c44bc   1/1     Running   10.244.0.13   devops-cluster-control-plane
nginx-deployment-64dd99d679-cvp4k   1/1     Running   10.244.0.14   devops-cluster-control-plane
nginx-deployment-64dd99d679-p59zw   1/1     Running   10.244.0.15   devops-cluster-control-plane
nginx-dev                           1/1     Running   10.244.0.16   devops-cluster-control-plane
```

---

## Self-Healing

Deleted pod `nginx-deployment-64dd99d679-c44bc`:
```
$ kubectl delete pod nginx-deployment-64dd99d679-c44bc -n dev
$ kubectl get pods -n dev -l app=nginx
NAME                                READY   STATUS    AGE
nginx-deployment-64dd99d679-cvp4k   1/1     Running   32s
nginx-deployment-64dd99d679-k2h49   1/1     Running   6s    ← NEW replacement
nginx-deployment-64dd99d679-p59zw   1/1     Running   32s
```

- Replacement pod has a **different name** — it's a new pod, not the old one restarted
- Standalone pod (Day 51) deleted = gone forever. Deployment pod deleted = replaced in seconds.

---

## Scaling

```
$ kubectl scale deployment nginx-deployment --replicas=5 -n dev
NAME                                READY   STATUS    AGE
nginx-deployment-64dd99d679-cvp4k   1/1     Running   4m44s
nginx-deployment-64dd99d679-ddwb4   1/1     Running   11s    ← new
nginx-deployment-64dd99d679-k2h49   1/1     Running   4m18s
nginx-deployment-64dd99d679-p59zw   1/1     Running   4m44s
nginx-deployment-64dd99d679-v2xqt   1/1     Running   11s    ← new

$ kubectl scale deployment nginx-deployment --replicas=2 -n dev
NAME                                READY   STATUS    AGE
nginx-deployment-64dd99d679-cvp4k   1/1     Running   4m49s
nginx-deployment-64dd99d679-p59zw   1/1     Running   4m49s
```

When scaling down, K8s terminates the extra pods. When scaling up, it creates new ones from the template.

---

## Rolling Update & Rollback

**Update nginx:1.24 → nginx:1.25:**
```
$ kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
$ kubectl rollout status deployment/nginx-deployment -n dev
Waiting for deployment rollout to finish: 1 out of 2 new replicas have been updated...
deployment "nginx-deployment" successfully rolled out

Image: nginx:1.25
```

**Rollback to previous version:**
```
$ kubectl rollout undo deployment/nginx-deployment -n dev
deployment "nginx-deployment" successfully rolled out

Image after rollback: nginx:1.24
```

**Rollout history:**
```
REVISION  CHANGE-CAUSE
1         <none>        ← nginx:1.24 (original)
2         <none>        ← nginx:1.25 (update)
3         <none>        ← nginx:1.24 (rollback)
```

Rolling updates replace pods one by one — zero downtime. Rollback reverses to the previous revision instantly.

---

## What I Learned

1. **Deployments are the right way to run apps** — standalone pods are for testing only. Deployments give you self-healing, scaling, and rolling updates out of the box.
2. **Namespaces isolate resources** — `kubectl get pods` without `-n` only shows `default`. Always use `-n <namespace>` or `-A` to see everything.
3. **Rolling updates = zero downtime** — K8s replaces pods one at a time, only killing old ones after new ones are healthy. `rollout undo` reverts instantly.
