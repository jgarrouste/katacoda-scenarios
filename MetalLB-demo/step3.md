## Configure MetalLB

We have a sample MetalLB configuration in
[`manifests/tutorial-1.yaml`](https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-1.yaml). Let's take a look at it before applying
it:

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
      addresses:
      - 198.51.100.0/24
```

MetalLB's configuration is a standard Kubernetes ConfigMap,
`config` under the `metallb-system` namespace. It contains two
pieces of information: who MetalLB should talk to, and what IP
addresses it's allowed to hand out.

In this configuration, we're setting up a BGP peering with
`10.96.0.100`, `10.96.0.101`, `10.96.0.102`, which are the addresses
of the `test-bgp-router-bird`, and `test-bgp-router-quagga` services
respectively. And we're giving MetalLB 256 IP addresses to use, from
198.51.100.0 to 198.51.100.255. The final section gives MetalLB some
BGP attributes that it should use when announcing IP addresses to our
router.

Apply this configuration now:

```kubectl apply -f https://raw.githubusercontent.com/google/metallb/master/manifests/tutorial-1.yaml```{{execute T1}}

The configuration should take effect within a few seconds. Refresh the
test-bgp-router-ui browser page again. If all went well, you should
see happier routers.

Success! The MetalLB BGP speaker connected to our routers. You can
verify this by looking at the logs for the BGP speaker. 
```
POD=$(kubectl -n metallb-system get pods | grep speaker | awk '{print $1}')
kubectl -n metallb-system logs pods/$POD | grep established
```{{execute T1}}


However, as the BGP routers pointed out, MetalLB is connected, but
isn't telling them about any services yet. That's because all the
services we've defined so far are internal to the cluster. Let's
change that!
