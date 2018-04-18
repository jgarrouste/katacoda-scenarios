## Create a load-balanced service

[`manifests/tutorial-2.yaml`](https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-2.yaml) contains a trivial service: an nginx pod,
and a load-balancer service pointing at nginx. Deploy it to the cluster now:

```kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-2.yaml```{{execute T1}}

Again, wait for nginx to start by monitoring ```kubectl get pods```{{execute T1}}, until
you see a running nginx pod. It should look something like this:

```
NAME                         READY     STATUS    RESTARTS   AGE
nginx-558d677d68-j9x9x       1/1       Running   0          47s
```

Once it's running, take a look at the `nginx` service with ```kubectl get service nginx```{{execute T1}}:

We have an external IP! Because the service is of type LoadBalancer,
MetalLB took `198.51.100.0` from the address pool we configured, and
assigned it to the nginx service. You can see this even more clearly
by looking at the event history for the service, with 
```kubectl describe service nginx```{{execute T1}} :

```
  Type    Reason          Age   From                Message
  ----    ------          ----  ----                -------
  Normal  IPAllocated     24m   metallb-controller  Assigned IP "198.51.100.0"
```

Refresh your test-bgp-router-ui page, and see what our routers thinks:

Success! MetalLB told our routers that 198.51.100.0 exists on our
Minikube VM, and that the routers should forward any traffic for that
IP to us.
