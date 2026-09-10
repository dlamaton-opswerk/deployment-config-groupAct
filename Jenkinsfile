pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko-build
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - 99d
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-cred
      items:
      - key: .dockerconfigjson
        path: config.json
'''
        }
    }
    stages {
        stage('Build and Push Image') {
            steps {
                // We execute the step inside the 'kaniko' container defined above
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --context=dir://${WORKSPACE} \
                      --dockerfile=${WORKSPACE}/Dockerfile \
                      --destination=dockerlamatz/smoketest:${BUILD_NUMBER} \
                      --destination=dockerlamatz/smoketest:latest \
                      --cache=true
                    '''
                }
            }
        }
    }
}
