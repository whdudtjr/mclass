pipeline{
    agent any // 어떤 에이전트에서든 실행 
    
    tools{
        maven 'maven 3.9.11' // Jenkins에 등록된 Maven 사용
    }
    environment{
        //배포에 필요한 변수 설정
        DOCKER_IMAGE = "demo-app"   // 도커 이미지 이름
        CONTAINER_NAME = "springboot-container" // 도커 컨테이너 이름
        JAR_FILE_NAME = "app.jar" // 복사할 JAR 파일 이름
        PORT = "8081" // 컨테이너와 연결할 포트

        REMOTE_USER = "ec2-user" // 원격(spring) 서버 사용자
        REMOTE_HOST = "52.79.135.231" // 원격(Spring) 서버 IP(public IP)

        REMOTE_DIR = "/home/ec2-user/deploy" // 원격 서버에 파일 복사할 경로 
        SSH_CREDENTIALS_ID = "2abea1eb-b4a0-40cb-9571-7da88f251433" // Jenkins SSH 자격 증명 ID
    }

    stages{
        stage('Git Checkout'){
            steps{ //stage 안에서 실행할 실제 명령어
                // Jenkins가 연결된 Git 저장소에서 최신 코드 체크아웃
                // SCM(Source Code Management)
                checkout scm
            }
        }

        stage('Maven Build'){
            steps{
                // TEST는 건너뛰고 Maven 빌드
                sh "mvn clean package -DskipTests"
                // sh 'echo Hello' : 리눅스 명령어 실행 
            }
        }
        stage('Prepare Jar'){
            steps{
                // 빌드 결과물인 JAR 파일을 지정한 이름(app.jar)
                sh 'cp target/demo-0.0.1-SNAPSHOT.jar ${JAR_FILE_NAME}'
            }
        }

        stage('Copy to Remote Server'){
            steps{
                // Jenkins가 원격 서버에 SSH 접속할 수 있도록 sshagent 사용
                sshagent(credentials:[env.SSH_CREDENTIALS_ID]){
                    // 원격 서버에 배포 디렉토리 만듬(없으면 새로만듬)
                    sh "ssh -i /var/lib/jenkins/.ssh/jenkins_rsa_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} \"mkdir -p ${REMOTE_DIR}\""
                    // JAR 파일과 Dockerfile을 원격 서버에 복사
                    sh "scp -i /var/lib/jenkins/.ssh/jenkins_rsa_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${JAR_FILE_NAME} Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
                }
            }
        }

        stage('Remote Docker Build & Deploy'){
            steps{
                sshagent(credentials:[env.SSH_CREDENTIALS_ID]){
                    // 원격 서버에서 도커 컨테이너를 제거하고 새로 빌드 및 실행이요
                    sh """
ssh -i /var/lib/jenkins/.ssh/jenkins_rsa_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST}<<EoF
cd ${REMOTE_DIR} || exit 1
docker rm -f ${CONTAINER_NAME} || true
docker build -t ${DOCKER_IMAGE} .
docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${DOCKER_IMAGE}
EoF
"""
                }
            }
        } 
    }

}