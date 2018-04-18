```
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.5.0/manifests/test-bgp-router.yaml
```

```
kubectl -n metallb-system get pods
```

kubectl -n metallb-system get svc | grep test-bgp-router-ui

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.5.0/manifests/metallb.yaml

```
kubectl -n metallb-system get pods
```



