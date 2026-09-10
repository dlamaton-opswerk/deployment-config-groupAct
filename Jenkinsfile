pipeline {
    agent any
    stages {
        stage('SCM Poll Test') {
            steps {
                echo "Triggered successfully via SCM polling!"
                sh "git rev-parse --short HEAD"
            }
        }
    }
}
