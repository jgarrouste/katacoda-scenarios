## Install MetalLB

MetalLB runs in two parts: a cluster-wide controller, and a
per-machine BGP speaker. Since Minikube is a Kubernetes cluster with a
single VM, we'll end up with the controller and one BGP speaker.

Install MetalLB by applying the manifest:

`kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/metallb.yaml`

This manifest creates a bunch of resources. Most of them are related
to access control, so that MetalLB can read and write the Kubernetes
objects it needs to do its job.

Ignore those bits for now, the two pieces of interest are the
"controller" deployment, and the "speaker" daemonset. Wait for
these to start by monitoring `kubectl get pods -n
metallb-system`. Eventually, you should see two running pods, in
addition to the BGP router from the previous step (again, the pod name
suffixes will be different on your cluster).

```
NAME                               READY     STATUS    RESTARTS   AGE
speaker-5x8rf                      1/1       Running   0          2m
controller-65c85447-8tngv          1/1       Running   0          3m
test-bgp-router-57fb7c798f-xccv8   1/1       Running   0          3m
```

Refresh the test-bgp-router-ui tab from earlier, and... It's the same!
MetalLB is still not connected, and our routers still know nothing
about cluster services.

That's because the MetalLB installation manifest doesn't come with a
configuration, so both the controller and BGP speaker are sitting
idle, waiting to be told what they should do. Let's fix that!
