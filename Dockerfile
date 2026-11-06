# 1. 경량 웹 서버 베이스 이미지 선택 (Nginx Alpine)
FROM nginx:alpine

# 2. 메타데이터 라벨 정의
LABEL maintainer="student@example.com"
LABEL description="개발 워크스테이션 과제용 커스텀 Nginx 웹 서버"

# 3. 환경 변수 설정
ENV APP_ENV=development
ENV PORT=80

# 4. 정적 웹 사이트 리소스 복사
COPY app/ /usr/share/nginx/html/

# 5. 노출 포트 명시
EXPOSE 80

# 6. 기본 실행 명령 (컨테이너 포그라운드 실행 유지)
CMD ["nginx", "-g", "daemon off;"]
