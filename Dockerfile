FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY app.jar app.jar

# 컨테이너가 외부와 통신하기우해 포트설정 
EXPOSE 8081

# 컨테이너가 시작될 대 자동으로 java - jar app.jar 명령을 실행하도록 설정 
ENTRYPOINT [ "java", "-jar", "app.jar" ]
