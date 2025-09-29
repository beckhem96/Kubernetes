# =======================================================
# STAGE 1: Gradle을 사용하여 애플리케이션을 빌드하는 단계
# =======================================================
FROM openjdk:17-jdk-slim AS build

WORKDIR /workspace/app

# Gradle 관련 파일들을 먼저 복사하여 종속성 캐싱 활용
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# 소스 코드 복사
COPY src src

# 프로젝트 빌드 실행 (이 단계에서 .jar 파일이 생성됨)
RUN ./gradlew build --no-daemon


# =======================================================
# STAGE 2: 빌드된 결과물로 최종 실행 이미지를 만드는 단계
# =======================================================
FROM openjdk:17-jre-slim

WORKDIR /app

# STAGE 1(build 단계)에서 생성된 .jar 파일을 복사해옴
COPY --from=build /workspace/app/build/libs/*.jar app.jar

# 8080 포트 개방
EXPOSE 8081

# 컨테이너 시작 시 애플리케이션 실행
ENTRYPOINT ["java","-jar","app.jar"]