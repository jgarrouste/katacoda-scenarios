ssh root@[[HOST_IP]] 'echo "Host *" >> /root/.ssh/config && echo "    StrictHostKeyChecking no" >> /root/.ssh/config && chmod 400 /root/.ssh/config'
#wget https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail && chmod +x kubetail
#kubectl create -f stork.yaml
#kubectl create -f stork-scheduler.yaml
