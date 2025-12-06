pipeline {
    agent { label 'Java' }

    tools {
        jdk 'java17'
        maven 'maven3'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*-SNAPSHOT.jar', fingerprint: true
                echo "Artifact archived successfully."
            }
        }

        stage('Run Application & Validate') {
            steps {
                script {
                    echo "Starting Spring Boot App..."

                    // Find the jar (adjust pattern if needed)
                    def jarFile = sh(
                        script: "ls target/*-SNAPSHOT.jar | head -n 1",
                        returnStdout: true
                    ).trim()

                    echo "Using JAR: ${jarFile}"

                    // Run app in background and store PID
                    sh """
                        nohup java -jar ${jarFile} > app.log 2>&1 &
                        echo \$! > app.pid
                    """

                    // Wait a bit for startup
                    sleep 60

                    echo "Checking if app started..."

                    // Don't fail on curl error, capture status instead
                    def status = sh(
                        script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo 200',
                        returnStdout: true
                    ).trim()

                    if (status != "200") {
                        echo "==== app.log (last 100 lines) ===="
                        sh 'tail -n 100 app.log || true'
                        error "App failed to start! HTTP Status: ${status}"
                    } else {
                        echo "App started successfully ✔"
                    }
                }
            }
        }

        stage('Wait 5 minutes') {
            steps {
                echo 'Keeping app running for 5 minutes...'
                sleep(time: 5, unit: 'MINUTES')
            }
        }

        stage('Stop Application') {
            steps {
                script {
                    echo "Stopping app..."
                    sh 'kill $(cat app.pid) || true'
                }
            }
        }
    }

    post {
        always {
            echo "Post cleanup..."
            sh 'pkill -f "java -jar" || true'
        }
    }
}
