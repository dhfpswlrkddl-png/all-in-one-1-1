```bash
# 경로 확인
$ pwd
/d/미션 1-1/git 사용

# 파일 만들기
$ touch a

# 폴더 파일 속 파일들 확인
$ ls
a

# 모든 파일의 경로까지 확인
$ ls -a
./  ../  a

# 파일들의 권한을 확인
$ ls -l
total 0
-rw-r--r-- 1 dhfpswlrkddl8378 1049089 0 Nov 10 18:00 a

# 모든 하위 파일의 경로, 권한 확인
$ ls -al
total 4
drwxr-xr-x 1 dhfpswlrkddl8378 1049089 0 Nov 10 18:00 ./
drwxr-xr-x 1 dhfpswlrkddl8378 1049089 0 Nov 10 17:58 ../
-rw-r--r-- 1 dhfpswlrkddl8378 1049089 0 Nov 10 18:00 a

# 경로 이동
dhfpswlrkddl8378@GNIA-C202-G02 UCRT64 /d/미션 1-1/git 사용
$ cd
dhfpswlrkddl8378@GNIA-C202-G02 UCRT64 ~ (경로가 바뀌었음)

# 폴더가 아닌 파일로 이동 시도
$ cd a
bash: cd: a: Not a directory

# 존재하지 않는 경로로 이동 시도
$ cd b
bash: cd: b: No such file or directory

# 파일 만들기
$ touch b

# 폴더 만들기
$ mkdir c

# 카피
$ cp a c (c 폴더에 a 파일이 생긴것을 확인 할 수 있음)

# 이동
$ mv b c (b 파일이 사라지고 c 폴더 안에 b가 생긴것을 확인 할 수 있음)

# 삭제
$ rm a (a 파일이 사라짐)

# 폴더 삭제
$ rm -r c (c 폴더가 사라짐)

# 내용 쓰기
$ touch a
$ printf 'hello world!' > a (메모장으로 실행하면 hello world!가 적혀있음)

# 내용 읽기
$ cat a
hello world!

# 권한 변경
$ ls -l
total 0
-rw-r--r-- 1 root root 0 Nov 12 07:32 a
$ chmod 777 a
$ ls -l
total 0
-rwxrwxrwx 1 root root 0 Nov 12 07:32 a
```
