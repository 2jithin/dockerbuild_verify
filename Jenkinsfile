def dockerbuildversion = null
response = null
pipeline {
  agent any
//   tools {
//     git 'Default' //toolname and version that given as name in global tools
//       installations: [
//         'Default': '/usr/bin/git', // Path to Git executable
//         //'Other': '/usr/local/bin/git'
//       ]
//   }
  options {
    timeout(time: 20, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '10'))
    skipDefaultCheckout false
    //skipDefaultCheckout()
  }
  // Environment Variables
  environment {
    dockerImageName = "simpleapachehttp"
    dockerbuildversion = "$dockerImageName:v$BUILD_NUMBER"
    dockertag = "${env.BUILD_NUMBER}"
    containername = "apachehttpd"
  }
  stages {
    //parallel {
      stage('A_SystemMemory') {
        steps {
          script {
            echo "========= Memory Usage Percentage ============"
            sh 'git branch'
            //sh 'df -h'
            //sh 'lscpu'
          }
        }
      }
      stage ('whenCondition') {
        when {
          //expression { "${env.BRANCH_NAME}" ==~ /(main|staging)/ }
          changeRequest(target: 'main')
        }
        steps {
          script {
            echo "+++++++++  Checking When condition   +++++++++"
//             sh 'export -p'
          }
        }
      }
      stage('B_CleanupAndPrune') {
//         when {
//           allOf {
//             branch 'main'
//             // changeset "main" // When condiiton for main branch oly
//             // changeset "refs/heads/main"
//           }  
//         }
        //retry(2) { // Retry if failed the step
          steps {
            script {
              // Validate any container is running
              echo " Validating running container with names "
              def containerId = sh(returnStdout: true, script: "docker ps --filter name=$containername -q")
              echo "${containerId}"
              if (containerId) {
                // cleanup docker images and Containers
                echo "+++++++++++++++++++ Removing All Docker Container +++++++++++++++++++"

                sh 'docker container stop $(docker container ls -aq)' // Stop all
                sh 'docker container prune -f' // Remove all exited containers
                sh 'docker ps -a'
                sh 'bash ./scripts/cleanupimages.sh || exit 1' // exit 1 is used to exit with a non-zero exit code if the build or test fails. This is necessary to trigger the retry mechanism in the pipeline.
              } else {
                echo "Skipping the cleanup process in docker"
              }
            }
          }
        //}
      }
    // }
    stage('Build Docker Image') {
      steps {
        script {
          echo " = = = == = = = = = = Creating Docker Image = = = = = == = = = = ="

          echo "+++++ Version is $dockerbuildversion"
          echo "Building Number ${BUILD_NUMBER} and docker build version is ${dockerbuildversion}"

          // Building Docker Images
          sh 'docker build -t $dockerImageName/$BUILD_NUMBER -f Dockerfile .'
        }
      }
    }
    stage('Verify Docker Image') {
      steps {
        //                 environment {
        //                     cid = sh returnStdout: true, script: 'docker ps --quiet --filter name=${dockerImageName}'
        //                 }
        script {
          try {

            //echo "$cid"
            echo "Verifying Docker and Build Version"
            dockerbuildversion = "$dockerImageName:v$BUILD_NUMBER"
            echo "Docker build version : $dockerbuildversion"

            echo "container name is $containername"
            sh 'docker run -d --name $containername$BUILD_NUMBER -p 100:80 $dockerImageName/$BUILD_NUMBER'
            sh 'response=$(curl -s -w %{http_code} localhost:100)'
            sh 'httpcode=$(tail -n1 <<< "$response")'
            response = httpRequest ignoreSslErrors: true, url: 'http://localhost:100'
            echo "Request http status is ${response.status}"
            //sh docker logs <container-id> //
            def statuscode = "${response.status}"
            if (statuscode == "200") {
              echo "****************** Latest Docker Image is Valid Image ***********************"
            } else {
              sh 'echo "Invalid Docker Image and verification failed"'
            }
          } catch (Exception ex) {
            echo "Image Invalid Stopping pipeline"
            throw new Exception("stop pipeline")
          }
        }
      }
    }
  }
}
