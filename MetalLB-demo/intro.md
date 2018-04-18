---
title: BGP on Minikube
weight: 10
---

In this scenarios, we'll set up some BGP routers, configure MetalLB to use them, and create some load-balanced services. We'll be
able to inspect the state of the BGP routers, and see that they
reflect the intent that we expressed in Kubernetes.

Because this will be a simulated environment inside Minikube, this
setup only lets you inspect the routers's state and see what it
_would_ do in a real deployment. Once you've experimented in this
setting and are ready to set up MetalLB on a real cluster, refer to
the [installation guide](https://metallb.universe.tf/installation/) for instructions.

Here is the outline of what we're going to do:

1. Set up a Minikube cluster,
2. Set up test BGP routers that we can inspect in subsequent steps,
3. Install MetalLB on the cluster,
4. Configure MetalLB to peer with our test BGP routers, and give it
   some IP addresses to manage,
5. Create a load-balanced service, and observe how MetalLB sets it up,
6. Change MetalLB's configuration, and fix a bad configuration,
7. Tear down the playground.

{{% notice note %}}
This tutorial currently only works on amd64 (aka x86_64) systems,
because the test BGP router container image doesn't work on other
platforms yet.
{{% /notice %}}
