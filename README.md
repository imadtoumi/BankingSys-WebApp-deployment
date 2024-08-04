### Took this project from : https://github.com/SandipPalit/Online-Banking-System-with-Flask.git

## AWS
#### aws ec2 instances creation
- 3 ec2 instances are needed (in the closest), one for jenkins and sonarqube, one to be the master node in k8s and one to be a worker node </br>
- Instances type: </br>
    1- t2 Large: jenkins+sonar. </br>
    2- t2 medium: k8s master. </br>
    3- t2 small: k8s worker node. </br>
![ec2s](https://github.com/user-attachments/assets/a0077bc1-e3ba-48e8-b938-788735e7159f) </br>
Setup the instances: </br>
- For k8s we will setup the cluster using kubeadm and containerd as the CRI here the complete guide link : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ </br>
- For jenkins and sonarqube server, i chose to run jenkins as a service (installation guide: https://www.jenkins.io/doc/book/installing/linux/ ), for sonarqube i chose to run it as a docker conatiner (install docker): </br>
```python
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```
- In order for our pipeline to work correctly, we need jenkins to be able to interact with our k8s cluster, we will create a service account, a role, role binding and a token (token used to authenticate jenkins in our cluster) for it :
```python
kubectl create serviceaccount jenkins --namespace=bank-app
kubectl create -f jenkinsrole.yaml
kubectl create -f rolebinding.yaml
kubectl create -f sec.yaml
# after this retrieve the token from the secret created
```



## Nginx and HTTPS part
### I made the app accesible only thre nginx , used nginx as reverse proxy that uses https. </br>
##### First, the docker conatiner shouldn't be maped to a port on the host, else it will be accessible from the oustide. </br>

To run docker container we will run it as simple as this :
```python
docker run -d --name <name_The_container> <image_name>
```

##### Now we will change something in nginx directory in /etc/nginx/
- Create private key and cert to configure https. </br>
```python
cd /etc/nginx/
mkdir ssl
cd ssl
sudo openssl genrsa -des3 -out mypc.key 2048
sudo openssl req -new -key ssl/mypc.key -out ssl/mypc.csr
sudo cp mypc.key mypc.key.pw # copy it so we can overwrite the existing file with now password, why ? bc if we use key with password whenever nginx restart it will keep asking us the password
sudo openssl rsa -in mypc.key.pw -out mypc.key
sudo openssl x509 -req -in mypc.csr -signkey mypc.key -out mypc.crt # self signing
```

- Access the default file in the directory /etc/nginx/sites-available/ and configgure the ssl
```python
listen 443 ssl default_server;
listen [::]:443 ssl default_server;

ssl_certificate /etc/nginx/ssl/mypc.crt;
ssl_certificate_key /etc/nginx/ssl/mypc.key;
```

- Configure proxy pass
```python
location / {
# First attempt to serve request as file, then
# as directory, then fall back to displaying a 404.
#try_files $uri $uri/ =404;
proxy_pass http://172.17.0.2:5000;
}
```
- Now we will have to configure iptables for our docker container so we can make it accesible via our nginx server
```python
# Allow traffic from Nginx server to Docker container on port 5000
sudo iptables -A DOCKER-USER -s <nginx_server_ip> -d <docker_container_ip> -p tcp --dport 5000 -j ACCEPT

# Drop all other traffic to Docker container on port 5000
sudo iptables -A DOCKER-USER -d <docker_container_ip> -p tcp --dport 5000 -j DROP
```
![nosecure](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/77ae08f9-4fe3-4eb5-95d3-6b8326066d0f) </br>
- It will be shown as "Not secure" because the cert is self signed and we didn't sign it using a CA (certificate authority / third party).<br>

# Online Banking System, with python Flask

[![Project Demo](https://img.youtube.com/vi/E0A_Z9ybDeo/0.jpg)](https://www.youtube.com/watch?v=E0A_Z9ybDeo)

This is a simplified version of an online banking system, entirely with python Flask for the driver code and Html and css for the webpage design.
This includes features like:
* New Employee registration
* Existing Employee Login
* New Customer registration
* Existing Customer Login
* Money Withdraw & Deposit

<br>
For saving the employee and customer details, I have used json, instead of sql.

<br>
<br>
To run this flask app, open a linux terminal here and execute 

`export FLASK_APP=app.py` <br> `flask run`
