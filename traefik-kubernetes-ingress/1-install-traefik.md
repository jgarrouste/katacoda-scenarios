Install traefik :
`kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-ds.yaml`{{execute}}

`kubectl --namespace=kube-system get pods`{{execute}}

`kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/cheese-deployments.yaml`{{execute}}

`kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/cheese-services.yaml`{{execute}}

`kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/cheese-ingress.yaml`{{execute}}



