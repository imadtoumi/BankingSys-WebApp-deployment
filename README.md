### Took this project from : https://github.com/SandipPalit/Online-Banking-System-with-Flask.git

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

jenkins pipeline : </br>
```python
pipeline {
    agent {label 'slave-1'}

    tools{
        jdk 'jdk17'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Clean workspace') {
            steps {
                cleanWs()
            }
        }

        stage('git chekout') {
            steps {
                git branch: 'main', url: 'https://github.com/imadtoumi/Online-Banking-System-with-Flask-master.git'
            }
        }

        stage('Sonar-qube analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Online-banking \
                    -Dsonar.projectKey=Online-banking'''
                }
            }
        }

        stage('Docker build image') {
            steps {
                script{
                    sh 'docker build -t online-banking:latest .'
                }
            }
        }
        stage('Trivy scan image') {
            steps {
                script{
                    sh 'trivy image --no-progress --scanners vuln --severity HIGH,CRITICAL --format table -o scan.txt online-banking:latest'
                }
            }
        }
        stage('Docker run') {
            steps {
                script{
                    sh 'docker run -d online-banking:latest'
                }
            }
        }
    }

     post {
        // always {
            //cleanWs() // Clean up workspace after each run
        // }
        success {
            echo 'Pipeline completed successfully!'
            // Additional steps on success, like sending notifications
        }
        failure {
            echo 'Pipeline failed!'
            // Additional steps on failure, like sending notifications
        }
        unstable {
            echo 'Pipeline completed with warnings!'
            // Additional steps on instability, like sending notifications
        }
        aborted {
            echo 'Pipeline was aborted!'
            // Additional steps on abort, like sending notifications
        }
    }
}
```
![onlline-jenkins](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/3e500cb8-540c-4c57-b053-775ac90ed0d2) </br>

![consoleoutpt](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/bb772187-cc54-42b2-b7dd-2e0a88ad300e) </br>

![onlinebanking](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/f7e7202c-ea40-4aa9-b4bc-02dd1cba4f96) </br>

![issues-sonar](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/bb0e79f9-a16c-44e8-bb31-d0b755eb7b07) </br>

![dockercont](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/d4fd5f4f-2fb1-4b7f-91fd-f518dc1a86e5)


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
