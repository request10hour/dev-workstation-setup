# AI/SW 개발 워크스테이션 구축

2026-04-02 기준으로 macOS + OrbStack 환경에서 터미널, Docker, Git 기본 흐름을 직접 검증한 결과를 정리한 저장소입니다. 목표는 "내 컴퓨터에서만 되는 실행"이 아니라, 같은 명령으로 다시 만들 수 있는 개발 워크스테이션을 구성하는 것입니다.

현재 저장소 기준으로 자동 수행 가능한 항목은 대부분 정리했습니다. `Git 사용자 정보 설정`은 완료했고, `VSCode GitHub 로그인 증거`도 첨부했습니다. 남은 항목은 최종 `원격 저장소 push` 확인입니다.

## 1. 프로젝트 개요

- 터미널 기본 조작과 파일 권한 실습을 통해 CLI 기반 작업 흐름을 익힌다.
- OrbStack 기반 Docker 엔진이 정상 동작하는지 점검하고, 이미지/컨테이너 운영 명령을 확인한다.
- `nginx:1.29-alpine` 기반 커스텀 이미지를 빌드해 정적 웹 서버를 띄운다.
- 포트 매핑, 바인드 마운트, Docker 볼륨 영속성을 실제 로그와 접속 결과로 검증한다.
- Git과 GitHub/VSCode 연동 위치를 구분하고, 수동 확인이 필요한 항목을 분리한다.

## 2. 저장소 구조

```text
.
├── Dockerfile
├── .dockerignore
├── app/
│   └── index.html
├── docs/
│   ├── assets/
│   │   ├── port-8088.png
│   │   ├── port-8089-bind.png
│   │   └── vscode-github-login.png
│   └── logs/
│       ├── docker-attach.txt
│       ├── docker-basics.txt
│       ├── docker-volume.txt
│       ├── docker-web.txt
│       ├── git-config.txt
│       ├── github-visibility.txt
│       ├── permissions.txt
│       ├── system-info.txt
│       └── terminal-basics.txt
└── practice/
    ├── permissions/
    └── terminal/
```

## 3. 실행 환경

- OS: macOS 15.7.4
- Shell: `/bin/zsh`
- Docker Engine: 28.5.2
- Docker Context: `orbstack`
- Git: 2.53.0
- VSCode CLI: 1.112.0

전체 로그:
- [system-info.txt](docs/logs/system-info.txt)
- [docker-basics.txt](docs/logs/docker-basics.txt)
- [git-config.txt](docs/logs/git-config.txt)
- [github-visibility.txt](docs/logs/github-visibility.txt)

핵심 확인:

```bash
$ sw_vers
ProductName:        macOS
ProductVersion:     15.7.4
BuildVersion:       24G517

$ echo $SHELL
/bin/zsh

$ docker --version
Docker version 28.5.2, build ecc6942

$ git --version
git version 2.53.0
```

## 4. 수행 체크리스트

- [x] 터미널 기본 조작 및 디렉터리 구성
- [x] 파일 1개, 디렉터리 1개 권한 변경 실습
- [x] Docker 설치/기본 점검
- [x] `hello-world` 실행
- [x] `ubuntu` 컨테이너 실행 및 내부 명령 확인
- [x] `attach` / `exec` 차이 관찰
- [x] Dockerfile 기반 커스텀 이미지 빌드
- [x] 포트 매핑 접속 검증
- [x] 바인드 마운트 반영 검증
- [x] Docker 볼륨 영속성 검증
- [x] Git 사용자 정보 설정
- [x] Git 기본 브랜치 설정
- [x] VSCode GitHub 로그인 증거 첨부
- [ ] 원격 저장소에 push 후 제출 링크 최종 확인

## 5. 터미널 기본 조작

전체 로그:
- [terminal-basics.txt](docs/logs/terminal-basics.txt)

실행 요약:

```bash
$ pwd
/Users/10hour0574/dev-workstation-setup

$ ls -la
drwxr-xr-x   9 c10hour0574  c10hour0574  288 Apr  2 19:35 .
drwxr-x---+ 21 c10hour0574  c10hour0574  672 Apr  2 19:37 ..
...

$ cd practice/terminal
$ printf "mission-log\n" > note.txt
$ touch empty.txt
$ cat note.txt
mission-log

$ cp note.txt note-copy.txt
$ mv note-copy.txt renamed-note.txt
$ mkdir archive
$ mv renamed-note.txt archive/renamed-note.txt

$ ls -la archive
-rw-r--r--  1 c10hour0574  c10hour0574   12 Apr  2 19:39 renamed-note.txt

$ rm empty.txt
$ rm -rf workspace-a
```

절대 경로와 상대 경로:

- 절대 경로는 루트(`/`)부터 전체 위치를 적는 방식이다. 예: `/Users/10hour0574/dev-workstation-setup/app/index.html`
- 상대 경로는 현재 위치를 기준으로 적는 방식이다. 저장소 루트에서 같은 파일은 `app/index.html` 이다.
- 과제 재현 문서에서는 평가자가 어느 위치에서 시작하는지 알 수 없기 때문에, 중요한 안내는 절대 경로와 상대 경로를 함께 적는 것이 안전하다.

## 6. 권한 실습

전체 로그:
- [permissions.txt](docs/logs/permissions.txt)

실행 요약:

```bash
$ ls -l note.txt
-rw-r--r--  1 c10hour0574  c10hour0574  15 Apr  2 19:39 note.txt

$ ls -ld scripts-dir
drwxr-xr-x  2 c10hour0574  c10hour0574  64 Apr  2 19:39 scripts-dir

$ chmod 600 note.txt
$ chmod 700 scripts-dir

$ ls -l note.txt
-rw-------  1 c10hour0574  c10hour0574  15 Apr  2 19:39 note.txt

$ ls -ld scripts-dir
drwx------  2 c10hour0574  c10hour0574  64 Apr  2 19:39 scripts-dir

$ chmod 644 note.txt
$ chmod 755 scripts-dir
```

권한 표기 해석:

- `r` 는 읽기, `w` 는 쓰기, `x` 는 실행 또는 디렉터리 진입 권한이다.
- 세 자리 숫자는 `소유자/그룹/기타 사용자` 순서다.
- `755` 는 `7(rwx) / 5(r-x) / 5(r-x)` 이므로, 디렉터리는 소유자만 쓰기 가능하고 나머지는 읽기/진입만 가능하다.
- `644` 는 `6(rw-) / 4(r--) / 4(r--)` 이므로, 일반 파일은 소유자만 수정하고 나머지는 읽기만 가능하다.

## 7. Docker 설치 및 기본 점검

전체 로그:
- [docker-basics.txt](docs/logs/docker-basics.txt)

핵심 확인:

```bash
$ docker --version
Docker version 28.5.2, build ecc6942

$ docker info
Client:
 Version:    28.5.2
 Context:    orbstack
...
Server:
 Server Version: 28.5.2
 Operating System: OrbStack
 OSType: linux
 Architecture: x86_64
```

의미 정리:

- Docker CLI 는 macOS 터미널에서 실행되지만, 실제 컨테이너 엔진은 OrbStack 내부 Linux 환경에서 동작한다.
- 그래서 호스트 OS 는 macOS, `docker info` 의 서버 OS 는 `OrbStack/Linux` 로 보이는 것이 정상이다.

## 8. 컨테이너 실행 실습

전체 로그:
- [docker-basics.txt](docs/logs/docker-basics.txt)
- [docker-attach.txt](docs/logs/docker-attach.txt)

### 8-1. `hello-world`

```bash
$ docker run --name mission-hello hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### 8-2. `ubuntu` 컨테이너 진입 대신 `exec` 로 내부 명령 실행

```bash
$ docker run -dit --name mission-ubuntu ubuntu:24.04 bash

$ docker exec mission-ubuntu bash -lc "ls / | sed -n '1,8p'; echo hello-from-ubuntu"
bin
boot
dev
etc
home
lib
lib64
media
hello-from-ubuntu
```

### 8-3. `attach` 와 `exec` 차이 관찰

```bash
$ docker attach mission-attach
root@ca7456c0e62b:/# echo inside-attach
inside-attach
root@ca7456c0e62b:/# exit
exit

$ docker ps -a --filter name=mission-attach
ca7456c0e62b   ubuntu:24.04   "bash"   Exited (0) ...

$ docker start mission-attach
$ docker exec mission-attach bash -lc 'echo inside-exec && pwd'
inside-exec
/

$ docker ps --filter name=mission-attach
ca7456c0e62b   ubuntu:24.04   "bash"   Up ...
```

관찰 정리:

- `attach` 는 컨테이너의 메인 프로세스에 직접 붙는다. 메인 `bash` 에서 `exit` 하면 컨테이너도 종료된다.
- `exec` 는 실행 중인 컨테이너 안에 새 프로세스를 추가로 띄운다. `exec` 로 실행한 셸을 종료해도 메인 프로세스가 살아 있으면 컨테이너는 계속 실행된다.

## 9. Dockerfile 기반 커스텀 이미지

선택한 베이스:

- 베이스 이미지: `nginx:1.29-alpine`
- 선택 이유: 웹 서버 설정이 간단하고, 정적 파일 교체만으로 포트 매핑/바인드 마운트 검증을 빠르게 진행할 수 있다.

내가 적용한 커스텀 포인트:

- `LABEL`: 이미지 목적을 식별하기 쉽게 메타데이터 추가
- `ENV APP_ENV=mission`: 환경값 예시 추가
- `COPY app/ /usr/share/nginx/html/`: 기본 정적 파일을 내 콘텐츠로 교체
- `.dockerignore`: 불필요한 문서/실습 디렉터리가 빌드 컨텍스트에 들어가지 않도록 정리

`Dockerfile`:

```dockerfile
FROM nginx:1.29-alpine

LABEL org.opencontainers.image.title="workstation-nginx-demo"
LABEL org.opencontainers.image.description="Static web server for the AI/SW workstation mission"

ENV APP_ENV=mission

COPY app/ /usr/share/nginx/html/
```

빌드/실행 로그:
- [docker-web.txt](docs/logs/docker-web.txt)

핵심 명령:

```bash
$ docker build -t workstation-web:1.0 .
...
#7 naming to docker.io/library/workstation-web:1.0

$ docker run -d --name mission-web -p 8088:80 workstation-web:1.0
18fa2fd00cdc8a5d922cdd5f25b95ddd4545e5bebe05acccb00d27e39a5e5bdb
```

## 10. 포트 매핑 및 접속 증거

포트 매핑이 필요한 이유:

- 컨테이너 안의 `80` 포트는 컨테이너 네트워크 안에만 존재한다.
- 브라우저나 `curl` 이 호스트(macOS)에서 접근하려면 `-p <host_port>:<container_port>` 로 통로를 열어야 한다.
- 이번 실습에서는 `8088 -> 80`, `8089 -> 80` 두 방식으로 접근을 확인했다.

실행 로그:
- [docker-web.txt](docs/logs/docker-web.txt)

`curl` 검증:

```bash
$ curl -s http://localhost:8088 | grep -o "<title>AI/SW 개발 워크스테이션 구축</title>"
<title>AI/SW 개발 워크스테이션 구축</title>

$ docker ps
18fa2fd00cdc   workstation-web:1.0   ...   0.0.0.0:8088->80/tcp   mission-web
ad1112da544c   nginx:1.29-alpine     ...   0.0.0.0:8089->80/tcp   mission-bind
```

브라우저 접속 스크린샷:

![포트 8088 접속](docs/assets/port-8088.png)

![포트 8089 바인드 마운트 접속](docs/assets/port-8089-bind.png)

## 11. 바인드 마운트 반영 검증

실행 로그:
- [docker-web.txt](docs/logs/docker-web.txt)

검증 절차:

```bash
$ cp -R app practice/bind-site
$ docker run -d --name mission-bind -p 8089:80 \
  -v "$PWD/practice/bind-site:/usr/share/nginx/html" nginx:1.29-alpine

$ curl -s http://localhost:8089 | grep -F "Dockerfile + NGINX Demo"
<span class="eyebrow">Dockerfile + NGINX Demo</span>

$ perl -0pi -e "s/Dockerfile \+ NGINX Demo/Bind Mount Updated/g" practice/bind-site/index.html
$ grep -F "Bind Mount Updated" practice/bind-site/index.html
<span class="eyebrow">Bind Mount Updated</span>

$ curl -s http://localhost:8089 | grep -F "Bind Mount Updated"
<span class="eyebrow">Bind Mount Updated</span>
```

해석:

- 바인드 마운트는 호스트 디렉터리와 컨테이너 경로를 직접 연결한다.
- 그래서 호스트 파일을 수정하면 이미 실행 중인 컨테이너도 새 파일 내용을 즉시 읽는다.
- 개발 중 "코드를 고치고 바로 반영 보기" 에 특히 유용하다.

## 12. Docker 볼륨 영속성 검증

실행 로그:
- [docker-volume.txt](docs/logs/docker-volume.txt)

검증 절차:

```bash
$ docker volume create mission-data
mission-data

$ docker run -d --name mission-volume-1 -v mission-data:/data ubuntu:24.04 sleep infinity

$ docker exec mission-volume-1 bash -lc "echo persisted-from-volume > /data/hello.txt && cat /data/hello.txt"
persisted-from-volume

$ docker rm -f mission-volume-1

$ docker run -d --name mission-volume-2 -v mission-data:/data ubuntu:24.04 sleep infinity

$ docker exec mission-volume-2 bash -lc "cat /data/hello.txt"
persisted-from-volume
```

해석:

- 볼륨은 컨테이너 생명주기와 분리된 Docker 관리 스토리지다.
- 컨테이너를 삭제해도 볼륨은 남기 때문에, 다시 연결했을 때 파일이 유지된다.
- 데이터베이스, 업로드 파일, 캐시처럼 "지워지면 안 되는 데이터" 에 적합하다.

## 13. 운영 명령 검증

실행 로그:
- [docker-basics.txt](docs/logs/docker-basics.txt)
- [docker-web.txt](docs/logs/docker-web.txt)

사용한 운영 명령:

```bash
$ docker images
REPOSITORY        TAG           IMAGE ID       SIZE
workstation-web   1.0           df9a8c567528   62.2MB
nginx             1.29-alpine   d5030d429039   62.2MB
hello-world       latest        e2ac70e7319a   10.1kB
ubuntu            24.04         f794f40ddfff   78.1MB

$ docker ps -a
CONTAINER ID   IMAGE                 STATUS
01432fa817a9   ubuntu:24.04          Up ...
ad1112da544c   nginx:1.29-alpine     Up ...
18fa2fd00cdc   workstation-web:1.0   Up ...
00b33fc23a41   ubuntu:24.04          Exited ...
487cf27e590a   hello-world           Exited ...

$ docker logs mission-web
192.168.215.1 - - [02/Apr/2026:10:37:28 +0000] "GET / HTTP/1.1" 200 ...

$ docker stats --no-stream mission-web
CONTAINER ID   NAME          CPU %   MEM USAGE / LIMIT
18fa2fd00cdc   mission-web   0.00%   6.191MiB / 15.67GiB
```

## 14. Git / GitHub / VSCode 연동

현재 자동 확인 결과:

- 원격 저장소는 이미 연결되어 있다: `https://github.com/request10hour/dev-workstation-setup.git`
- GitHub API 기준으로 저장소 visibility 는 `public` 이다.
- VSCode CLI(`code`)는 설치되어 있다.
- `git config --global user.name`, `user.email`, `init.defaultBranch` 값은 모두 설정했다.
- `gh` CLI 는 설치되어 있지 않아서, GitHub 인증 여부는 VSCode 또는 브라우저 기준으로 확인해야 한다.
- VSCode GitHub 로그인 및 저장소 연동 화면은 스크린샷으로 저장했다: [vscode-github-login.png](docs/assets/vscode-github-login.png)

현재 로그:
- [git-config.txt](docs/logs/git-config.txt)
- [github-visibility.txt](docs/logs/github-visibility.txt)

확인 결과:

```bash
$ git config --global --get user.name
request10hour

$ git config --global --get user.email
request10hour@gmail.com

$ git config --global --get init.defaultBranch
main

$ curl -s https://api.github.com/repos/request10hour/dev-workstation-setup | rg '"private"|"visibility"|"default_branch"'
"private": false,
"visibility": "public",
"default_branch": "main"

$ code --version
1.112.0
07ff9d6178ede9a1bd12ad3399074d726ebe6e43
x64
```

다음 단계:

1. 원격 저장소에 마지막 커밋을 push 한다.
2. push 성공 후 제출 링크를 최종 확인한다.

예시 명령:

```bash
git config --list --show-origin
git push -u origin main
```

## 15. 검증 방법 요약

- 시스템/버전 확인: [system-info.txt](docs/logs/system-info.txt)
- 터미널 조작 로그: [terminal-basics.txt](docs/logs/terminal-basics.txt)
- 권한 변경 로그: [permissions.txt](docs/logs/permissions.txt)
- Docker 설치/기본 운영: [docker-basics.txt](docs/logs/docker-basics.txt)
- 커스텀 이미지/포트/마운트: [docker-web.txt](docs/logs/docker-web.txt)
- 볼륨 영속성: [docker-volume.txt](docs/logs/docker-volume.txt)
- `attach` vs `exec`: [docker-attach.txt](docs/logs/docker-attach.txt)
- Git 상태 확인: [git-config.txt](docs/logs/git-config.txt)
- GitHub 공개 저장소 확인: [github-visibility.txt](docs/logs/github-visibility.txt)
- VSCode GitHub 로그인 증거: [vscode-github-login.png](docs/assets/vscode-github-login.png)

## 16. 트러블슈팅

### 사례 1. `zsh: no matches found` 로 빈 디렉터리 정리가 실패함

- 문제: `rm -rf practice/terminal/*` 를 처음 실행했을 때 대상 파일이 없어서 `zsh: no matches found` 가 발생했다.
- 원인 가설: `zsh` 는 기본적으로 글롭 결과가 없으면 에러를 낼 수 있다.
- 확인: 동일한 명령이 빈 디렉터리에서만 실패하고, 파일이 있는 경우에는 정상 실행되었다.
- 해결: 로그 수집 스크립트에 `setopt null_glob` 를 추가해 매치가 없어도 에러 없이 넘어가도록 수정했다.

### 사례 2. `docker attach` 입력 파이프 방식이 실패함

- 문제: `printf 'echo ...' | docker attach mission-attach` 방식으로 붙으려 했더니 `the input device is not a TTY` 메시지가 나왔다.
- 원인 가설: `attach` 는 메인 프로세스의 터미널에 직접 붙기 때문에, 단순 파이프 대신 TTY 가 필요하다.
- 확인: 실제 TTY 세션으로 `docker attach mission-attach` 를 실행한 뒤에는 입력과 종료가 정상 동작했다.
- 해결: 인터랙티브 TTY 세션으로 `attach` 를 수행했고, 이후 `exit` 시 컨테이너가 종료되는 것을 확인했다.

### 사례 3. 브라우저 증거 이미지는 너무 커서 저장소에 부담이 됨

- 문제: 전체 화면 캡처 원본이 각각 약 25MB 수준으로 생성되었다.
- 원인 가설: 5K 해상도 전체 화면 PNG 가 그대로 저장되었기 때문이다.
- 확인: `ls -lh docs/assets` 로 파일 크기를 확인했다.
- 해결: `sips -Z 1600 ...` 으로 리사이즈해 제출용 크기(약 2.9MB)로 줄였다.

## 17. 핵심 개념 정리

### 기존 Dockerfile/이미지 기반 커스텀 이미지란?

- 이미 검증된 베이스 이미지 위에 필요한 파일, 설정, 환경 변수를 추가해 "우리 팀에 맞는 실행 환경" 을 만드는 것이다.
- 이번 실습에서는 `nginx:1.29-alpine` 위에 정적 HTML 을 복사해 `workstation-web:1.0` 을 만들었다.

### 포트 매핑이 필요한 이유

- 컨테이너는 격리된 네트워크를 사용하므로, 호스트 브라우저가 바로 내부 포트를 볼 수 없다.
- `-p 8088:80` 처럼 호스트 포트와 컨테이너 포트를 연결해야 외부에서 접근할 수 있다.

### Docker 볼륨이 필요한 이유

- 컨테이너는 삭제되면 내부 파일도 함께 사라질 수 있다.
- 볼륨은 데이터를 컨테이너 밖에 보관하므로 재시작이나 재생성 이후에도 데이터를 유지할 수 있다.

### Git 과 GitHub 의 역할 차이

- Git: 로컬에서 파일 변경 이력을 저장하고 브랜치/커밋을 관리하는 버전 관리 도구
- GitHub: Git 저장소를 원격으로 공유하고 협업, 리뷰, 이슈, PR 을 진행하는 플랫폼

## 18. 재현 절차

```bash
# 1) 커스텀 이미지 빌드
docker build -t workstation-web:1.0 .

# 2) 포트 매핑 실행
docker run -d --name mission-web -p 8088:80 workstation-web:1.0
curl http://localhost:8088

# 3) 바인드 마운트 실행
cp -R app practice/bind-site
docker run -d --name mission-bind -p 8089:80 \
  -v "$PWD/practice/bind-site:/usr/share/nginx/html" nginx:1.29-alpine

# 4) 볼륨 영속성 확인
docker volume create mission-data
docker run -d --name mission-volume-1 -v mission-data:/data ubuntu:24.04 sleep infinity
docker exec mission-volume-1 bash -lc "echo persisted-from-volume > /data/hello.txt"
docker rm -f mission-volume-1
docker run -d --name mission-volume-2 -v mission-data:/data ubuntu:24.04 sleep infinity
docker exec mission-volume-2 bash -lc "cat /data/hello.txt"
```

## 19. 남은 수동 완료 항목

자동으로 확정할 수 없는 항목만 남아 있다.

1. VSCode GitHub 로그인 완료
2. 원격 저장소 push 확인
3. 필요 시 추가 커밋 및 `git push origin main`

VSCode 증거가 준비되면 다음 턴에서 아래를 이어서 마무리할 수 있다.

```bash
git add .
git commit -m "docs: add VSCode GitHub evidence"
git push origin main
```
