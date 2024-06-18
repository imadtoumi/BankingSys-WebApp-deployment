## Just took this frpm an other repo that i don't remember, i wanted to docker it and automate it's deployment

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
                    sh 'docker run -dp 5000:5000 online-banking:latest'
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

![issues-sonar](https://github.com/imadtoumi/Online-Banking-System-with-Flask-master/assets/41326066/bb0e79f9-a16c-44e8-bb31-d0b755eb7b07)


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
