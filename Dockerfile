# =======================================================
# STAGE 1: 전체 JDK가 포함된 이미지로 애플리케이션 빌드
# =======================================================
FROM eclipse-temurin:17-jdk-jammy AS build

WORKDIR /workspace/app

# Gradle 관련 파일들을 먼저 복사하여 종속성 캐싱 활용
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# 소스 코드 복사
COPY src src

# 프로젝트 빌드 실행
RUN ./gradlew build --no-daemon


# =======================================================
# STAGE 2: 더 가벼운 JRE만 포함된 이미지로 최종 실행 환경 구성
# =======================================================
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# STAGE 1(build 단계)에서 생성된 .jar 파일을 복사해옴
COPY --from=build /workspace/app/build/libs/*.jar app.jar

# 8080 포트 개방
EXPOSE 8080

# 컨테이너 시작 시 애플리케이션 실행
ENTRYPOINT ["java","-jar","app.jar"]