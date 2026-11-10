# 1. Linux 베이스 이미지 선택 (공식 Ubuntu LTS 이미지)
FROM ubuntu:24.04

# 2. 환경 변수 설정
ENV codyssey="hello"

# 3. NGINX 및 curl 설치
RUN apt-get update && apt-get install nginx -y && apt-get install curl -y

# 4. 정적 웹 콘텐츠(HTML) 복사 교체 (Ubuntu NGINX의 기본 웹 루트: /var/www/html)
COPY html/ /var/www/html/

# 5. 서비스 노출 포트 지정
EXPOSE 8080

# 6. 컨테이너 헬스체크 지시어 (10초 주기로 자체 웹 서버 응답 확인)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# 7. NGINX 포그라운드(데몬 모드 끔) 실행
CMD ["nginx", "-g", "daemon off;"]
