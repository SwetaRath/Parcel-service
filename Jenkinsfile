pipeline {
    agent { label 'Java' }
    // agent any

    tools {
        jdk 'JDK17'
        maven 'maven3'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'feature-2', url: 'ttps://github.com/SwetaRath/Parcel-service.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests=false'
            }
        } 
       // simple-parcel-service-app-1.0-SNAPSHOT.jar
        stage('Push the artifacts into JFrog Artifactory') {
            steps {
                script {
                    // Define WAR file path
                    def WAR_FILE = "${env.WORKSPACE}/target/simple-parcel-service-app-1.0-SNAPSHOT.jar"

                    // Current timestamp
                    def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd_HH-mm").format(new Date())

                    // Path inside Artifactory
                    def targetPath = "newsapp_snapshots/${currentDate}/"

                    rtUpload(
                        serverId: "jfrog",
                        spec: """{
                            "files": [
                                {
                                    "pattern": "${WAR_FILE}",
                                    "target": "${targetPath}"
                                }
                            ]
                        }"""
                    )
                }
            }
        }
        

        //stage('Archive Artifact') {
          //  steps {
        //        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
          //  }
        //}

        stage('Run Application') {
            steps {
                sh 'mvn spring-boot:run'

                dir('/var/lib/jenkins/workspace/Parcel_service_feature-2/target') {
                    sh """
                        // nohup java -jar simple-parcel-service-app-1.0-SNAPSHOT.jar > app.log 2>&1 &
                        // echo "Application started"
                    """
                }
            }

        }

    }
}
