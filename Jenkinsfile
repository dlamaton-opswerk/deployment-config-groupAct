pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    role: jenkins-ci-agent
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
  - name: git-tools
    image: alpine/git:v2.40.1
    command:
    - sleep
    args:
    - 99d
  volumes:
  - name: docker-config
    secret:
      secretName: kaniko-docker-cfg
'''
        }
    }
    environment {
        // CONFIGURE THESE FOUR VARIABLES:
        DOCKER_USER      = 'dockerlamatz'
        IMAGE_NAME       = 'python-flaskapp'
        DEPLOY_REPO_HOST = 'github.com/dlamaton-opswerk/deployment-config.git'
        GIT_CRED_ID      = 'c5918c98-9c4d-4309-b141-8f39d1316b50'
    }
    stages {
        stage('Generate Version Tag') {
            steps {
                script {
                    // Extract 7-character Git commit hash
                    SHORT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    // Create monotonic, non-latest unique tag
                    IMAGE_TAG = "v${BUILD_NUMBER}-${SHORT_SHA}"
                    FULL_IMAGE = "${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "Target build image tag: ${FULL_IMAGE}"
                }
            }
        }

        stage('Build & Push to Docker Hub') {
            steps {
                container('kaniko') {
                    // Fail if Dockerfile is missing
                    sh """
                    if [ ! -f "${WORKSPACE}/Dockerfile" ]; then
                        echo "Error: Dockerfile not found in workspace!"
                        exit 1
                    fi
                    """
                    // Kaniko executes daemonless build and pushes immediately
                    sh """
                    /kaniko/executor \
                      --context=dir://${WORKSPACE} \
                      --dockerfile=${WORKSPACE}/Dockerfile \
                      --destination=${FULL_IMAGE} \
                      --cache=false
                    """
                }
            }
        }

        stage('Update Deployment Config') {
            steps {
                container('git-tools') {
                    withCredentials([usernamePassword(
                        credentialsId: env.GIT_CRED_ID, 
                        usernameVariable: 'GIT_USER', 
                        passwordVariable: 'GIT_PASS'
                    )]) {
                        sh """
                        # Configure local committer identity
                        git config --global user.email "jenkins-ci@bot.local"
                        git config --global user.name "Jenkins CI Bot"

                        # Clean previous runs and clone
                        rm -rf deployment-config
                        git clone https://${GIT_USER}:${GIT_PASS}@${DEPLOY_REPO_HOST} deployment-config
                        cd deployment-config

                        TARGET_FILE="apps/python-flaskapp/deployment.yaml"

                        # Trap 1: Fail loudly if manifest file path is incorrect
                        if [ ! -f "\$TARGET_FILE" ]; then
                            echo "ERROR: Target manifest \$TARGET_FILE does not exist!"
                            exit 1
                        fi

                        # Trap 2: Fail loudly if the target pattern does not exist in the file
                        if ! grep -q "${DOCKER_USER}/${IMAGE_NAME}:" "\$TARGET_FILE"; then
                            echo "ERROR: Target pattern '${DOCKER_USER}/${IMAGE_NAME}:' not found in \$TARGET_FILE"
                            exit 1
                        fi

                        # Execute replacement
                        sed -i -E "s|(${DOCKER_USER}/${IMAGE_NAME}):[a-zA-Z0-9_.-]+|\\1:${IMAGE_TAG}|g" "\$TARGET_FILE"

                        # Trap 3: Prevent silent no-ops; fail if diff is empty
                        if git diff --quiet "\$TARGET_FILE"; then
                            echo "ERROR: sed executed but no changes were made to \$TARGET_FILE"
                            exit 1
                        fi

                        # Stage, commit, and push
                        git add "\$TARGET_FILE"
                        git commit -m "ci(release): update ${IMAGE_NAME} to ${IMAGE_TAG} [skip ci]"
                        git push origin main
                        """
                    }
                }
            }
        }
    }
    post {
        failure {
            echo "CI Pipeline failed. No changes were committed to deployment-config."
        }
        success {
            echo "Successfully built ${FULL_IMAGE} and bumped deployment-config."
        }
    }
}
