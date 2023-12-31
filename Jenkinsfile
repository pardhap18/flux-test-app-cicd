pipeline {
    agent any
    // options {
    //     // Timeout counter starts AFTER agent is allocated
    //     timeout(time: 1, unit: 'SECONDS')
    // }
    environment {
        GIT_COMMIT_SHORT = sh(
                script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
                returnStdout: true
        )
        HELM_CHART_FILE = sh(
            script: 'find . -name "Chart.yaml" -type f', 
            returnStdout: true
        )
        BUILD_NUM_ENV = currentBuild.getNumber()
    }
    stages {
        stage('Checkout external proj') {
            steps {
                git branch: 'main',
                credentialsId: 'github-id',
                url: 'https://github.com/pardhap18/flux-test-app-psp.git'
            }
        }
        stage('Build') {
            steps {
                sh "mvn install"
            }
        }
        stage('Image creation') {
            steps {
                sh '''
                    docker build -t flux-test-app:${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT} .
                    docker tag flux-test-app:${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT} localhost:5000/flux-test-app:${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT}
                    docker push localhost:5000/flux-test-app:${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT}
                '''
            }
        }
        stage('Update Chart Info') {
            steps {
                script {
                    datas = readYaml (file: './charts/flux-test-app/Chart.yaml')
                    new_chart_version = nextVersion('major', datas.version)
                    echo "Got version as ${datas.version} and New Version is ${new_chart_version}"
                    datas.version = new_chart_version
                    datas.appVersion = "${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT}"
                }
                sh "rm -rf ./charts/flux-test-app/Chart.yaml"
                script {
                    writeYaml (file: './charts/flux-test-app/Chart.yaml', data: datas)
                }

            }
        }
        stage('Dev Promotion') {
            steps {
                script {
                    tag_data = readYaml (file: './charts/flux-test-app/values-dev.yaml')
                    echo "Got version as ${tag_data.image.tag}"
                    tag_data.image.tag = "${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT}" 
                }
                sh "rm -rf ./charts/flux-test-app/values-dev.yaml"
                script {
                    writeYaml (file: './charts/flux-test-app/values-dev.yaml', data: tag_data)
                }

            }
        }
        stage('Staging Promotion') {
            steps {
                script {
                    tag_data = readYaml (file: './charts/flux-test-app/values-staging.yaml')
                    echo "Got version as ${tag_data.image.tag}"
                    tag_data.image.tag = "${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT}"  
                }
                sh "rm -rf ./charts/flux-test-app/values-staging.yaml"
                script {
                    writeYaml (file: './charts/flux-test-app/values-staging.yaml', data: tag_data)
                }

            }
        }
        stage('Git Push') {
            steps {
                withCredentials([
                    gitUsernamePassword(credentialsId: 'github-id', gitToolName: 'Default')
                ]) {
                    sh '''
                        git config --global user.email "pardhap18@gmail.com"
                        git config --global user.name "Pardha"
                        git add .
                        git commit -am "${BUILD_NUM_ENV}-${GIT_COMMIT_SHORT} deploy changes"
                        git push -u origin main
                    '''
                }
            }
        }
    }
}

def nextVersion(scope, latestVersion) {
    def major = (latestVersion.tokenize('.')[0]).toInteger()
    def minor = (latestVersion.tokenize('.')[1]).toInteger()
    def patch = (latestVersion.tokenize('.')[2]).toInteger()
    def nextVersion
    switch (scope) {
        case 'major':
            nextVersion = "${major + 1}.${minor}.${patch}"
            break
        case 'minor':
            nextVersion = "${major}.${minor + 1}.${patch}"
            break
        case 'patch':
            nextVersion = "${major}.${minor}.${patch + 1}"
            break
    }
    return nextVersion
}