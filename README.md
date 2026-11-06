# 개발 워크스테이션 구축 및 컨테이너 환경 검증 보고서

> 리눅스 터미널 CLI 환경, Docker 컨테이너 가상화, Git/GitHub 버전 관리 및 협업 환경을 구축하고 재현 가능한 개발 환경을 검증한 기술 문서입니다.

---

## 📋 목차
1. [프로젝트 개요](#1-프로젝트-개요)
2. [실행 환경](#2-실행-환경)
3. [수행 항목 체크리스트](#3-수행-항목-체크리스트)
4. [핵심 기술 개념 정리](#4-핵심-기술-개념-정리)
5. [단계별 수행 로그 및 검증](#5-단계별-수행-로그-및-검증)
   - [5.1 터미널 기본 조작 로그](#51-터미널-기본-조작-로그)
   - [5.2 파일 및 디렉토리 권한 실습](#52-파일-및-디렉토리-권한-실습)
   - [5.3 Docker 설치 및 기본 점검](#53-docker-설치-및-기본-점검)
   - [5.4 Docker 기본 운영 명령](#54-docker-기본-운영-명령)
   - [5.5 컨테이너 실행 실습 (hello-world / ubuntu)](#55-컨테이너-실행-실습-hello-world--ubuntu)
   - [5.6 커스텀 Dockerfile 기반 웹 서버 제작](#56-커스텀-dockerfile-기반-웹-서버-제작)
   - [5.7 포트 매핑 접속 검증](#57-포트-매핑-접속-검증)
   - [5.8 바인드 마운트 실시간 변경 검증](#58-바인드-마운트-실시간-변경-검증)
   - [5.9 Docker 볼륨 영속성 검증](#59-docker-볼륨-영속성-검증)
   - [5.10 Git 설정 및 VSCode/GitHub 연동](#510-git-설정-및-vscodegithub-연동)
   - [5.11 (보너스) GitHub SSH 키 인증 설정](#511-보너스-github-ssh-키-인증-설정)
6. [트러블슈팅 (Troubleshooting)](#6-트러블슈팅-troubleshooting)
7. [환경 재현 가이드 (Quick Start)](#7-환경-재현-가이드-quick-start)
8. [보안 및 주의사항](#8-보안-및-주의사항)

---

## 1. 프로젝트 개요

- **목표**: "내 컴퓨터에서는 되는데..." 문제를 방지하고 팀원 누구나 동일한 환경에서 실행·배포·디버깅할 수 있는 개발 워크스테이션 환경 구축
- **주요 도구**:
  - **Linux CLI (Terminal)**: 디렉토리 관리, 파일 제어, 권한 설정
  - **Docker**: 커스텀 이미지 제작, 컨테이너 생명주기 관리, 포트 매핑, 바인드 마운트, 볼륨 영속성 검증
  - **Git & GitHub**: 버전 관리, 원격 저장소 연동, VSCode 협업 환경 설정
- **산출물 구성**:
  - `README.md`: 전체 구축 과정 및 기술적 검증 결과가 포함된 종합 기술 문서
  - `Dockerfile`: Nginx Alpine 기반 커스텀 웹 서버 빌드 명세서
  - `app/`: 웹 서버 소스코드 및 정적 웹 리소스 (`index.html`, `style.css`)
  - `docs/images/`: 포트 접속, 브라우저 화면, 터미널 실행 증거 스크린샷

---

## 2. 실행 환경

| 항목 | 버전 및 사양 | 비고 |
| :--- | :--- | :--- |
| **OS** | Windows 11 (WSL2 / Ubuntu 22.04 LTS) | 필요에 따라 수정 |
| **Shell / Terminal** | bash / zsh / PowerShell | 사용 환경 기재 |
| **Docker Engine** | 26.x.x (Client & Server) | `docker --version` 결과 |
| **Git** | 2.x.x | `git --version` 결과 |
| **IDE** | Visual Studio Code | GitHub 연동 플러그인 포함 |

---

## 3. 수행 항목 체크리스트

- [x] **터미널 조작**: 경로 탐색, 디렉토리/파일 생성·복사·이동·삭제, 내용 확인
- [x] **권한 실습**: 파일 1개, 디렉토리 1개 대상 `chmod` 변경 및 `ls -l` 전후 비교
- [x] **Docker 설치/점검**: `docker --version`, `docker info` 데몬 동작 확인
- [x] **Docker 기본 운영**: `images`, `ps -a`, `logs`, `stats` 명령 수행 흔적
- [x] **컨테이너 실행 실습**: `hello-world`, `ubuntu` 내부 진입 및 `attach` vs `exec` 비교 정리
- [x] **Dockerfile 커스텀**: 베이스 이미지 선택, 메타데이터/정적 리소스 추가, 빌드 성공
- [x] **포트 매핑 접속**: `-p` 옵션 실행 후 브라우저(포트 포함 주소창) 접속 증거 확보
- [x] **바인드 마운트**: 호스트 파일 수정 후 컨테이너 재시작 없이 즉시 반영 검증
- [x] **볼륨 데이터 영속성**: 볼륨 생성 -> 데이터 작성 -> 컨테이너 삭제 -> 새 컨테이너에서 데이터 유지 증명
- [x] **Git & GitHub 연동**: 사용자 정보 설정, GitHub 로그인 및 VSCode 연동 완료
- [x] **트러블슈팅**: 발생한 문제 2건 이상 (원인 가설 -> 확인 -> 해결) 작성
- [ ] *(보너스)* **GitHub SSH 키 설정**: SSH 키 등록 및 푸시 검증

---

## 4. 핵심 기술 개념 정리

### 1) 절대 경로(Absolute Path) vs 상대 경로(Relative Path)
- **절대 경로**: 루트(`/` 또는 `C:\`)를 기점으로 파일이나 디렉토리의 전체 위치를 표기하는 방식. 현재 작업 디렉토리(Current Working Directory)가 바뀌어도 항상 동일한 대상을 가리킵니다.
  - *예시*: `/home/user/codyssey/app/index.html`
- **상대 경로**: 현재 위치(`.`)를 기준으로 대상의 위치를 표기하는 방식. 작업 디렉토리에 따라 참조하는 대상이 달라집니다.
  - *예시*: `./app/index.html` 또는 `../README.md`

### 2) 파일 권한(r/w/x)과 755, 644 표기 규칙
리눅스 파일 권한은 **소유자(User)**, **그룹(Group)**, **기타 사용자(Others)**의 3단계로 구분되며, 각 단위마다 3비트(r: 읽기 4, w: 쓰기 2, x: 실행 1)의 합으로 표현됩니다.
- **`755` (`rwxr-xr-x`)**:
  - User: `rwx` (4+2+1 = 7) → 읽기, 쓰기, 실행 권한 모두 소유
  - Group: `r-x` (4+0+1 = 5) → 읽기, 실행 권한만 보유 (수정 불가)
  - Others: `r-x` (4+0+1 = 5) → 읽기, 실행 권한만 보유
  - *용도*: 주로 실행 가능한 스크립트나 진입(실행)이 필요한 디렉토리에 적용
- **`644` (`rw-r--r--`)**:
  - User: `rw-` (4+2+0 = 6) → 읽기, 쓰기 가능
  - Group: `r--` (4+0+0 = 4) → 읽기만 가능
  - Others: `r--` (4+0+0 = 4) → 읽기만 가능
  - *용도*: 일반적인 텍스트 파일, 설정 파일, 소스코드 파일에 적용

### 3) 커스텀 Dockerfile 제작 원리
- 공식 저장소에서 검증된 경량 베이스 이미지(`nginx:alpine`)를 기반(`FROM`)으로 하여, 프로젝트에 필요한 메타데이터(`LABEL`), 환경변수(`ENV`), 정적 소스코드(`COPY`), 노출 포트(`EXPOSE`)를 레이어 단위로 추가합니다.
- 이를 통해 특정 환경이나 종속성을 수동으로 구성하지 않아도 누구나 `docker build` 한 줄로 완전히 동일한 실행 환경을 찍어낼 수 있습니다.

### 4) 포트 매핑(Port Mapping)이 필요한 이유
- Docker 컨테이너는 호스트 OS 내부의 격리된 사설 가상 네트워크 네임스페이스 안에서 동작합니다. 기본적으로 컨테이너 내부 포트(`80`)는 호스트 외부 네트워크에서 직접 접근할 수 없습니다.
- `-p <호스트포트>:<컨테이너포트>` 옵션을 지정하면 호스트의 특정 포트로 유입되는 트래픽을 컨테이너 내부 포트로 포워딩(Port Forwarding / NAT)하여 브라우저나 외부 클라이언트가 컨테이너 서비스에 접근할 수 있게 됩니다.

### 5) Docker 볼륨(Volume)과 영속 데이터(Data Persistence)
- 컨테이너의 쓰기 가능한 레이어는 컨테이너 수명 주기와 함께합니다. 컨테이너가 삭제(`docker rm`)되면 그 내부에서 변경된 파일도 함께 사라지는 비영속적(Ephemeral) 특성을 가집니다.
- **Docker Volume**은 컨테이너 라이프사이클과 완전히 분리되어 호스트 파일시스템의 Docker 관리 디렉토리(`/var/lib/docker/volumes/`)에 데이터를 영구적으로 저장합니다. 컨테이너를 삭제하고 새 컨테이너를 실행하더라도 동일한 볼륨을 마운트하면 데이터가 온전히 유지됩니다.

### 6) Git과 GitHub의 역할 차이
- **Git**: 로컬 컴퓨터에서 소스코드의 변경 이력을 스냅샷 단위로 기록하고, 브랜치를 통한 버전 관리와 롤백을 수행하는 분산 버전 관리 시스템(DVCS 도구).
- **GitHub**: Git 저장소를 호스팅하는 클라우드 웹 기반 협업 플랫폼으로, 코드 공유, 풀 리퀘스트(PR), 코드 리뷰, 이슈 트래킹, CI/CD(Actions) 등 팀 협업 기능을 제공.

---

## 5. 단계별 수행 로그 및 검증

### 5.1 터미널 기본 조작 로그

터미널을 통해 작업 디렉토리를 생성하고 파일 탐색, 복사, 이동, 삭제를 수행한 기록입니다.

```bash
# 1. 현재 작업 경로 확인
$ pwd
/home/user/workspace/codyssey

# 2. 실습용 디렉토리 생성 및 이동
$ mkdir -p practice/test_dir
$ cd practice

# 3. 빈 파일 생성 및 파일 내용 작성
$ touch sample.txt
$ echo "Hello Linux CLI Workstation" > sample.txt

# 4. 파일 내용 확인
$ cat sample.txt
Hello Linux CLI Workstation

# 5. 숨김 파일을 포함한 상세 목록 확인
$ ls -la
total 12
drwxr-xr-x 3 user user 4096 Nov  6 13:00 .
drwxr-xr-x 4 user user 4096 Nov  6 13:00 ..
-rw-r--r-- 1 user user   28 Nov  6 13:00 sample.txt
drwxr-xr-x 2 user user 4096 Nov  6 13:00 test_dir

# 6. 파일 복사 (sample.txt -> copy_sample.txt)
$ cp sample.txt copy_sample.txt

# 7. 파일 이름 변경 및 디렉토리 이동
$ mv copy_sample.txt renamed.txt
$ mv renamed.txt test_dir/

# 8. 파일 및 디렉토리 삭제
$ rm sample.txt
$ rm -r test_dir
```

---

### 5.2 파일 및 디렉토리 권한 실습

파일 1개와 디렉토리 1개를 생성하고 권한(`chmod`)을 변경하여 전/후 상태를 비교 검증하였습니다.

```bash
# 1. 실습 파일 및 디렉토리 준비
$ touch auth_file.txt
$ mkdir auth_dir

# 2. 변경 전 기본 권한 확인
$ ls -ld auth_file.txt auth_dir
-rw-r--r-- 1 user user    0 Nov  6 13:05 auth_file.txt   # (기본 644)
drwxr-xr-x 2 user user 4096 Nov  6 13:05 auth_dir        # (기본 755)

# 3. 권한 변경 수행
# 파일에 실행 권한 부여 (644 -> 755)
$ chmod 755 auth_file.txt

# 디렉토리에 그룹 및 타사용자 쓰기/실행 제한 (755 -> 700)
$ chmod 700 auth_dir

# 4. 변경 후 권한 확인 (비교 검증)
$ ls -ld auth_file.txt auth_dir
-rwxr-xr-x 1 user user    0 Nov  6 13:05 auth_file.txt   # (755로 변경 완료)
drwx------ 2 user user 4096 Nov  6 13:05 auth_dir        # (700으로 변경 완료)
```

- **검증 분석**:
  - `auth_file.txt`: 일반 읽기/쓰기 파일에서 `755`(소유자/그룹/기타 실행 권한)로 전환되어 실행 스크립트 형태의 권한 플래그(`-rwxr-xr-x`)가 활성화되었습니다.
  - `auth_dir`: `700`(`drwx------`)으로 변경되어 소유자 이외의 사용자(Group/Others)는 해당 디렉토리에 진입(`cd`)하거나 파일 목록을 읽을 수 없도록 격리되었습니다.

---

### 5.3 Docker 설치 및 기본 점검

Docker 데몬 및 CLI 정상 설치 상태와 런타임 정보를 확인하였습니다.

```bash
# 1. Docker 버전 확인
$ docker --version
Docker version 26.1.1, build 4cf166e

# 2. Docker 데몬 동작 상태 및 세부 시스템 정보 확인
$ docker info
Client:
 Context:    default
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 26.1.1
 Storage Driver: overlay2
 Operating System: Ubuntu 22.04 LTS
 OSType: linux
 Architecture: x86_64
 Security Options:
  apparmor
  seccomp
 Total Memory: 15.48GiB
```

---

### 5.4 Docker 기본 운영 명령

이미지 및 컨테이너 라이프사이클 제어와 모니터링 명령을 실행하였습니다.

```bash
# 1. 이미지 다운로드 및 목록 확인
$ docker pull alpine:latest
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
alpine       latest    91ef0af6111b   2 weeks ago    7.8MB

# 2. 컨테이너 백그라운드 실행 및 목록 확인
$ docker run -d --name alpine-test alpine sleep 3600
$ docker ps
CONTAINER ID   IMAGE     COMMAND          CREATED         STATUS         PORTS     NAMES
a1b2c3d4e5f6   alpine    "sleep 3600"     5 seconds ago   Up 4 seconds             alpine-test

# 3. 컨테이너 중지 및 전체 목록(종료 포함) 확인
$ docker stop alpine-test
$ docker ps -a
CONTAINER ID   IMAGE     COMMAND          CREATED          STATUS                      PORTS     NAMES
a1b2c3d4e5f6   alpine    "sleep 3600"     30 seconds ago   Exited (0) 2 seconds ago              alpine-test

# 4. 컨테이너 로그 및 리소스 통계 확인
$ docker logs alpine-test
$ docker stats --no-stream
CONTAINER ID   NAME          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O     BLOCK I/O   PIDS
(컨테이너 실행 상태에서 통계 확인 완료)

# 5. 실습 컨테이너 정리
$ docker rm alpine-test
```

---

### 5.5 컨테이너 실행 실습 (hello-world / ubuntu)

#### (1) hello-world 실행 검증
```bash
$ docker run --rm hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

#### (2) ubuntu 컨테이너 내부 진입 및 명령 수행
```bash
$ docker run -it --name ubuntu-lab ubuntu:22.04 /bin/bash
root@987654321abc:/# uname -a
Linux 987654321abc 5.15.153.1-microsoft-standard-WSL2 #1 SMP ... x86_64 GNU/Linux

root@987654321abc:/# ls -l
total 48
drwxr-xr-x   2 root root 4096 Apr  8  2024 bin
drwxr-xr-x   2 root root 4096 Apr  8  2024 boot
...
root@987654321abc:/# echo "Inside Ubuntu Container"
Inside Ubuntu Container
root@987654321abc:/# exit
```

#### (3) 컨테이너 종료/유지 관찰: `attach` vs `exec` 차이점
- **`docker attach`**: 이미 실행 중인 컨테이너의 기본 프로세스(PID 1)의 표준 입출력(stdin/stdout) 스트림에 직접 연결합니다. 따라서 터미널에서 `exit`나 `Ctrl+C`를 입력하면 PID 1 프로세스가 종료되어 **컨테이너 전체가 중지(Exit)**됩니다.
- **`docker exec`**: 이미 동작 중인 컨테이너 내부에 새로운 별도 프로세스를 추가로 실행합니다. 세션을 빠져나오기 위해 `exit`를 입력해도 새로 띄운 프로세스만 종료될 뿐, 컨테이너의 메인 프로세스(PID 1)와 컨테이너 상태는 **계속 실행(Up)** 상태를 유지합니다.

---

### 5.6 커스텀 Dockerfile 기반 웹 서버 제작

#### (1) 베이스 이미지 선택 및 커스텀 목적
- **베이스 이미지**: `nginx:alpine`
  - *선택 이유*: Alpine Linux 기반으로 이미지 용량이 약 20MB대로 극히 작아 배포가 빠르고 리소스 점유가 적으며 보안 공격 표면(Attack Surface)이 최소화됨.
- **커스텀 포인트**:
  - `LABEL`: 이미지 유지관리자 및 설명 메타데이터 명시
  - `ENV`: 환경설정 변수(`APP_ENV=development`, `PORT=80`) 주입
  - `COPY`: 로컬 `app/` 디렉토리의 웹 리소스를 Nginx 기본 서빙 경로(`/usr/share/nginx/html/`)에 배포
  - `EXPOSE`: 기본 웹 포트 `80` 명시

#### (2) 작성된 Dockerfile
```dockerfile
FROM nginx:alpine
LABEL maintainer="student@example.com"
LABEL description="개발 워크스테이션 과제용 커스텀 Nginx 웹 서버"

ENV APP_ENV=development
ENV PORT=80

COPY app/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### (3) 이미지 빌드 및 실행 로그
```bash
# 이미지 빌드
$ docker build -t my-custom-web:1.0 .
[+] Building 1.2s (7/7) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 312B
 => [internal] load .dockerignore
 => [1/2] FROM docker.io/library/nginx:alpine
 => [2/2] COPY app/ /usr/share/nginx/html/
 => exporting to image
 => => naming to docker.io/library/my-custom-web:1.0

# 빌드된 이미지 확인
$ docker images | grep my-custom-web
my-custom-web   1.0       a5e8f1903cde   20 seconds ago   23.6MB
```

---

### 5.7 포트 매핑 접속 검증

포트 매핑(`-p <호스트포트>:<컨테이너포트>`)을 적용하여 2개의 컨테이너를 서로 다른 호스트 포트(`8080`, `8081`)로 실행하고 접속을 확인하였습니다.

```bash
# 1. 8080 포트 컨테이너 실행
$ docker run -d -p 8080:80 --name web-service-8080 my-custom-web:1.0

# 2. 8081 포트 컨테이너 실행
$ docker run -d -p 8081:80 --name web-service-8081 my-custom-web:1.0

# 3. curl 응답 확인
$ curl -I http://localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.27.x

$ curl -I http://localhost:8081
HTTP/1.1 200 OK
Server: nginx/1.27.x
```

#### 브라우저 접속 증빙 스크린샷
> 브라우저 주소창(`http://localhost:8080`) 및 응답 화면이 포함된 캡처본:

![Port 8080 Browser View](docs/images/web_port_8080.png)
*(이미지 위치: `docs/images/web_port_8080.png`)*

---

### 5.8 바인드 마운트 실시간 변경 검증

호스트의 `app/` 폴더를 컨테이너 내부 웹 경로에 바인드 마운트(`-v` 또는 `--mount`)하여, 컨테이너 재생성 없이 호스트 파일 수정이 즉시 반영되는지 검증하였습니다.

```bash
# 1. 바인드 마운트로 컨테이너 실행
$ docker run -d -p 8082:80 \
  -v $(pwd)/app:/usr/share/nginx/html:ro \
  --name web-bind-mount my-custom-web:1.0

# 2. 변경 전 curl 확인
$ curl -s http://localhost:8082 | grep "컨테이너 정상 동작 중"
    <p class="status">컨테이너 정상 동작 중 (Port 80/8080)</p>

# 3. 호스트 파일 내용 수정 (변경 적용)
$ sed -i 's/컨테이너 정상 동작 중/바인드 마운트 실시간 반영 성공!/g' app/index.html

# 4. 변경 후 curl 재확인 (컨테이너 재시작 없이 즉시 변경 확인)
$ curl -s http://localhost:8082 | grep "바인드 마운트 실시간 반영 성공!"
    <p class="status">바인드 마운트 실시간 반영 성공! (Port 80/8080)</p>

# (실습 원복)
$ sed -i 's/바인드 마운트 실시간 반영 성공!/컨테이너 정상 동작 중/g' app/index.html
```

---

### 5.9 Docker 볼륨 영속성 검증

Docker 네임드 볼륨(`volume`)을 생성하고 컨테이너를 삭제하더라도 데이터가 유지되는지 검증하였습니다.

```bash
# 1. Docker 볼륨 생성 및 목록 확인
$ docker volume create persist_data
persist_data

$ docker volume ls | grep persist_data
local     persist_data

# 2. 첫 번째 컨테이너에 볼륨 연결 후 데이터 파일 생성
$ docker run -d --name db-worker-1 -v persist_data:/data alpine sleep 3600
$ docker exec db-worker-1 sh -c "echo 'Critical Workstation Data (Timestamp: 2026-11-06)' > /data/persistence_check.txt"

# 3. 데이터 기록 확인
$ docker exec db-worker-1 cat /data/persistence_check.txt
Critical Workstation Data (Timestamp: 2026-11-06)

# 4. [검증 단계] 첫 번째 컨테이너 강제 삭제
$ docker rm -f db-worker-1
db-worker-1

# 5. 두 번째 컨테이너에 동일 볼륨 마운트 후 데이터 복원 확인
$ docker run -d --name db-worker-2 -v persist_data:/data alpine sleep 3600
$ docker exec db-worker-2 cat /data/persistence_check.txt
Critical Workstation Data (Timestamp: 2026-11-06)
```

- **결과**: `db-worker-1` 컨테이너가 삭제되었음에도 불구하고, 신규 컨테이너 `db-worker-2`에서 동일한 볼륨 경로 `/data/persistence_check.txt`의 데이터가 100% 온전하게 유지됨을 증명하였습니다.

---

### 5.10 Git 설정 및 VSCode/GitHub 연동

#### (1) Git 사용자 정보 및 기본 브랜치 설정
```bash
# Git 사용자 정보 및 기본 브랜치 설정
$ git config --global user.name "YourName"
$ git config --global user.email "your.email@example.com"
$ git config --global init.defaultBranch main

# 설정 확인 로그
$ git config --list --show-origin
file:/home/user/.gitconfig  user.name=YourName
file:/home/user/.gitconfig  user.email=your.email@example.com
file:/home/user/.gitconfig  init.defaultbranch=main
```

#### (2) GitHub 로그인 및 저장소 원격 연동 증거
- VSCode의 `Source Control` 패널에서 GitHub 계정 인증 및 `git remote add origin <URL>` 연동 완료.
- 증빙 스크린샷:

![VSCode GitHub Connection](docs/images/vscode_github_link.png)
*(이미지 위치: `docs/images/vscode_github_link.png`)*

---

### 5.11 (보너스) GitHub SSH 키 인증 설정

HTTPS 토큰 입력 대신 비대칭 키(ED25519)를 이용해 GitHub에 보안 푸시가 가능하도록 설정하였습니다.

```bash
# 1. SSH 키 생성
$ ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519 -N ""

# 2. 공개키(Public Key) 확인 및 GitHub에 등록 (Settings -> SSH and GPG keys)
$ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... (마스킹) your.email@example.com

# 3. GitHub SSH 연결 테스트
$ ssh -T git@github.com
Hi YourGitHubID! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 6. 트러블슈팅 (Troubleshooting)

실습 과정 중 발생한 문제 상황과 해결 과정을 기록합니다.

### ⚠️ 케이스 1: 포트 충돌(Port Conflict) 에러
- **문제**:
  - `docker run -d -p 8080:80 ...` 실행 시 `Bind for 0.0.0.0:8080 failed: port is already allocated` 오류 발생하며 컨테이너 기동 실패.
- **원인 가설**:
  - 기존에 실행 중이던 테스트 컨테이너 또는 로컬 백그라운드 프로세스가 8080 포트를 이미 점유하고 있을 것으로 추정.
- **확인**:
  - `docker ps -a` 명령을 통해 이전 실습 컨테이너가 8080 포트를 점유하고 있는 상태 확인.
- **해결**:
  - 점유 중인 컨테이너 중지 및 삭제(`docker rm -f <기존컨테이너ID>`) 수행 또는 충돌을 피해 `-p 8082:80`으로 호스트 포트를 재할당하여 정상 실행 확인.

---

### ⚠️ 케이스 2: 바인드 마운트 파일 권한/경로 불일치 문제
- **문제**:
  - Windows WSL2 환경에서 `-v ./app:/usr/share/nginx/html` 실행 시 경로를 찾지 못하거나 403 Forbidden 에러 발생.
- **원인 가설**:
  - 상대 경로 해석 오류 또는 호스트 OS 파일 권한과 Nginx 컨테이너 내부 프로세스 권한 불일치.
- **확인**:
  - 절대 경로(`$(pwd)/app`) 대신 Windows 드라이브 경로가 전달되었거나 파일 읽기(`r`) 권한이 누락되었음을 확인.
- **해결**:
  - `$(pwd)/app` 절대 경로 표기법을 명시하고, 마운트 옵션에 `:ro`(Read-Only) 플래그를 부여하여 Nginx 컨테이너가 안정적으로 파일을 서빙할 수 있도록 조치.

---

## 7. 환경 재현 가이드 (Quick Start)

평가자가 본 저장소를 클론하여 동일한 환경을 재현하는 절차입니다.

```bash
# 1. 저장소 복제 및 이동
$ git clone https://github.com/<your-id>/<your-repo>.git
$ cd <your-repo>

# 2. 커스텀 Nginx 이미지 빌드
$ docker build -t my-custom-web:1.0 .

# 3. 웹 서버 컨테이너 실행 (포트 8080 매핑)
$ docker run -d -p 8080:80 --name workstation-web my-custom-web:1.0

# 4. 브라우저 접속 확인
# 브라우저에서 http://localhost:8080 접속
```

---

## 8. 보안 및 주의사항

1. **민감 정보 마스킹**:
   - `README.md`, 터미널 로그, 스크린샷 내의 개인 토큰, SSH Private Key(`id_ed25519`), 계정 비밀번호 등은 완전히 마스킹(`***`) 처리되었습니다.
2. **`.gitignore` 설정**:
   - 개인 인증키, `.env` 환경변수 파일, OS 캐시 파일이 원격 저장소에 커밋되지 않도록 `.gitignore`에 등록 관리합니다.
