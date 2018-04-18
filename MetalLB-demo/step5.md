## Edit MetalLB's configuration

In the previous step, MetalLB assigned the address 198.51.100.0, the
first address in the pool we gave it. That IP address is perfectly
valid, but some old and buggy wifi routers mistakenly think it isn't,
because it ends in `.0`.

As it turns out, one of our customers called and complained of this
exact problem. Fortunately, MetalLB has a configuration option to
address this. Take a look at the configuration in
[`manifests/tutorial-3.yaml`](https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-3.yaml):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
    - my-asn: 64500
      peer-asn: 64500
      peer-address: 10.96.0.100
    - my-asn: 64500
      peer-asn: 64500
      peer-address: 10.96.0.101
    address-pools:
    - name: my-ip-space
      protocol: bgp
      avoid-buggy-ips: true
      addresses:
      - 198.51.100.0/24
```

There's just one change compared to our previous configuration: in the
address pool configuration, we added `avoid-buggy-ips: true`. This
tells MetalLB that IP addresses ending in `.0` or `.255` should not be
assigned.

Sounds easy enough, let's apply that configuration:

```kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-3.yaml```{{execute T1}}

Refresh the test-bgp-router-ui page and... Hmm, strange, our routers
are still being told to use `198.51.100.0`, even though we just told
MetalLB that this address should not be used. What happened?

To answer that, let's inspect the running configuration in Kubernetes,
by running : 

```kubectl describe configmap -n metallb-system config```{{execute T1}}

At the bottom of the output, you should see an event
log that looks like this:

```
Events:
  Type     Reason         Age   From                 Message
  ----     ------         ----  ----                 -------
  Warning  InvalidConfig  29s   metallb-controller   configuration rejected: new config not compatible with assigned IPs: service "default/nginx" cannot own "198.51.100.0" under new config
  Warning  InvalidConfig  29s   metallb-speaker      configuration rejected: new config not compatible with assigned IPs: service "default/nginx" cannot own "198.51.100.0" under new config
```

Oops! Both the controller and the BGP speaker rejected our new
configuration, because it would break an already existing
service. This illustrates an important policy that MetalLB tries to
follow: applying new configurations should not break existing
services.

_(You might ask why we were able to apply an invalid configuration at
all. Good question! This is a missing feature of MetalLB. In future,
MetalLB will validate new configurations when they are submitted by
kubectl, and make Kubernetes refuse unsafe configurations. But for
now, it will merely complain after the fact, and ignore the new
configuration.)_

At this point, MetalLB is still running on the previous configuration,
the one that allows nginx to use the IP it currently has. If this were
a production cluster with Prometheus monitoring, we would be getting
an alert now, warning us that the configmap written to the cluster is
not compatible with the cluster's running state.

Okay, so how do we fix this? We need to _explicitly_ change the
configuration of the nginx service to be compatible with the new
configuration. To do this, run `kubectl edit service nginx`, and in
the `spec` section add: `loadBalancerIP: 198.51.100.1`.

Save the change, and run `kubectl describe service nginx` again. You
should see an `IPAllocated` event showing that MetalLB changed the
service's assigned address as instructed.

Now, the new configuration that we tried to apply is valid, because
nothing is using the `.0` address any more. Let's reapply it, so that
MetalLB reloads again:

```kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-4.yaml```{{execute T1}}

_You may have noticed that we applied tutorial-4.yaml, not the
tutorial-3.yaml from before. This is another rough edge in the current
version of MetalLB: when we submitted the configuration in
tutorial-3.yaml, MetalLB looked at it and rejected it, but will not
look at it again to see if it has become valid. To make MetalLB
examine the configuration again, we need to make some cosmetic change
to the config, so that Kubernetes notifies MetalLB that there is a new
configuration to load. tutorial-4.yaml just adds a no-op comment to
the configuration to make Kubernetes signal MetalLB._

_This piece of clunkiness will also go away when MetalLB learns to
validate new configurations before accepting the submission from
kubectl._

This time, MetalLB accepts the new configuration, and everything is
happy once again. And, refreshing test-bgp-router-ui, we see that the
routers did indeed see the change from `.0` to `.1`.

_One final bit of clunkiness: right now, you need to inspect metallb's
logs to see that a new configuration was successfully loaded. Once
MetalLB only allows valid configurations to be submitted, this
clunkiness will also go away._
