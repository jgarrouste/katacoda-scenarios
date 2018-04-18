## Set up a BGP routers

MetalLB exposes load-balanced services using the BGP routing protocol,
so we need a BGP router to talk to. In a production cluster, this
would be set up as a dedicated hardware router (e.g. an Ubiquiti
EdgeRouter), or a soft router using open-source software (e.g. a Linux
machine running the [BIRD](http://bird.network.cz) routing suite).

For this tutorial, we'll deploy a pod inside minikube that runs both
the BIRD and [Quagga](http://www.nongnu.org/quagga/). They will be
configured to speak BGP, but won't configure Linux to forward traffic
based on the data they receive. Instead, we'll just inspect that data
to see what a real router _would_ do.

Deploy these test routers with `kubectl`:
```kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/test-bgp-router.yaml```{{execute T1}}

This will create a deployment for our BGP routers, as well as four
cluster-internal services. 

Wait for the router pod to start, by running the next command until you see the test-bgp-router pod in the `Running` state.
```kubectl get pods -n metallb-system```{{execute T1}}

In addition to the router pod, the `test-bgp-router.yaml` manifest
created four cluster-internal services:

- The `test-bgp-router-bird` service exposes the BIRD BGP router at
`10.96.0.100`, so that we have a stable IP address for MetalLB to talk
to.
- Similarly, the `test-bgp-router-quagga` service exposes the Quagga
router at `10.96.0.101`.
- Finally, the `test-bgp-router-ui` service is a little UI that shows
us what routers are thinking.

Get Services :
```kubectl -n metallb-system get svc```{{execute T1}}

Get the value of the Node port assigned :
```echo $(kubectl -n metallb-system get services/test-bgp-router-ui -o go-template='{{(index .spec.ports 0).nodePort}}')```{{execute T1}}

Open Katacoda Web Preview and enter this port : http://[[CLIENT_SUBDOMAIN]]-[[KATACODA_HOST]].environments.katacoda.com/
Open Katacoda Web Preview and enter this port : http://[[HOST_SUBDOMAIN]]-[[KATACODA_HOST]].environments.katacoda.com/

If you're comfortable with BGP and networking, the raw router status
may be interesting. If you're not, don't worry, the important part is
above: our routers are running, but know nothing about our Kubernetes
cluster, because MetalLB is not connected.

Obviously, MetalLB isn't connected to our routers, it's not installed
yet! Let's address that. Keep the test-bgp-router-ui tab open, we'll
come back to it shortly.
