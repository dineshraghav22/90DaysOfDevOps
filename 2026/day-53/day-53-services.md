# Day 53 – Kubernetes Services

## Why Services?

Pods get random IPs that change on every restart. A Deployment runs multiple pods — which IP do you connect to? Services solve this by providing a **stable IP and DNS name** with **load balancing** across all matching pods.

```
[Client] → [Service (stable IP)] → Pod 1
                                  → Pod 2
                                  → Pod 3
```

---

## Deployment (web-app with 3 replicas)

```
$ kubectl get pods -o wide
NAME                       READY   STATUS    IP
web-app-6d948cd9f8-5gzt2   1/1     Running   10.244.0.25
web-app-6d948cd9f8-rpqjq   1/1     Running   10.244.0.26
web-app-6d948cd9f8-wrv8w   1/1     Running   10.244.0.27
```

---

## Services Created

```
$ kubectl get services -o wide
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        SELECTOR
kubernetes             ClusterIP      10.96.0.1       <none>        443/TCP        <none>
web-app-clusterip      ClusterIP      10.96.52.168    <none>        80/TCP         app=web-app
web-app-nodeport       NodePort       10.96.200.68    <none>        80:30080/TCP   app=web-app
web-app-loadbalancer   LoadBalancer   10.96.121.142   <pending>     80:31037/TCP   app=web-app
```

---

## 1. ClusterIP (Internal Only)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

**Test from inside cluster:**
```
$ kubectl run test-client --image=busybox:latest --rm -it --restart=Never -- wget -qO- http://web-app-clusterip

<!DOCTYPE html>
<html>
<head><title>Welcome to nginx!</title></head>
<body><h1>Welcome to nginx!</h1>...</body>
</html>
```

**Endpoints (pod IPs the service routes to):**
```
$ kubectl get endpoints web-app-clusterip
NAME                ENDPOINTS
web-app-clusterip   10.244.0.25:80,10.244.0.26:80,10.244.0.27:80
```

---

## 2. DNS Discovery

Every service gets a DNS entry: `<service-name>.<namespace>.svc.cluster.local`

```
$ nslookup web-app-clusterip (from inside a pod)
Name:   web-app-clusterip.default.svc.cluster.local
Address: 10.96.52.168
```

- Short name `web-app-clusterip` works within the same namespace
- Full name `web-app-clusterip.default.svc.cluster.local` works across namespaces
- DNS resolves to the ClusterIP (`10.96.52.168`), which matches `kubectl get services`

---

## 3. NodePort (External via Node Port)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Traffic flow: `<NodeIP>:30080` → Service → Pod:80

- `nodePort: 30080` — port opened on every node (range: 30000-32767)
- Accessible from outside the cluster via node IP

---

## 4. LoadBalancer (Cloud External Access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

```
$ kubectl describe service web-app-loadbalancer
Type:         LoadBalancer
ClusterIP:    10.96.121.142
NodePort:     31037/TCP
Endpoints:    10.244.0.27:80,10.244.0.26:80,10.244.0.25:80
External-IP:  <pending>
```

EXTERNAL-IP shows `<pending>` because kind has no cloud provider to provision a real load balancer. In AWS/GCP/Azure, this would get a public IP automatically.

**LoadBalancer builds on the others:** it also has a ClusterIP (10.96.121.142) and a NodePort (31037).

---

## Service Types Comparison

| Type | Accessible From | Use Case |
|------|----------------|----------|
| ClusterIP | Inside cluster only | Internal service-to-service communication |
| NodePort | Outside via `<NodeIP>:<30000-32767>` | Dev/testing, direct node access |
| LoadBalancer | Outside via cloud LB | Production traffic in cloud environments |

Each type builds on the previous: LoadBalancer → creates NodePort → creates ClusterIP.

---

## What I Learned

1. **Services decouple clients from pods** — clients connect to the Service's stable IP/DNS, never directly to pod IPs. When pods restart and get new IPs, the Service automatically updates its endpoints.
2. **`selector` is the glue** — the Service finds its pods using label selectors. If `selector: app: web-app` doesn't match any pod labels, the endpoints list is empty and the service routes to nothing.
3. **DNS makes services discoverable** — instead of hardcoding IPs, services reference each other by name (`http://web-app-clusterip`). This is how microservices communicate in Kubernetes.
