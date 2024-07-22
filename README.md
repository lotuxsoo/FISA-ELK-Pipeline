# 우리FISA ELK 스택 구축 프로젝트 🔨
### 개발 팀원
- 이승언, 이정욱, 손대현, 최수연
<br/>

## 방법 1. Docker 사용해서 ELK 스택 구축하기
### 1. Docker 및 Docker Compose 설치
```
# Docker 설치
sudo apt-get update
sudo apt-get install -y docker.io

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker 및 Docker Compose 버전 확인
docker --version
docker-compose --version
```
<br/>

### 2. Docker Compose 파일 작성
- ```\ELK\docker-compose.yml```에 작성
- Docker Compose를 사용하여 ELK 스택 (Elasticsearch, Logstash, Kibana, Filebeat) 환경을 설정하는 스크립트입니다.

![image](https://github.com/user-attachments/assets/ef498b55-15e3-44c7-bdf4-44c03a442434)
<br/>

### 3. Logstash 구성 파일 작성
- ```\ELK\logstash\pipeline\logstash.conf```에 작성
-  Filebeat에서 데이터를 수신하고, CSV 형식의 데이터를 파싱 및 변환하여 Elasticsearch에 전송하는 파이프라인을 설정합니다.
<br/>

### 4. Filebeat 설정 파일 작성
- ```\ELK\filebeat\filebeat.yml```에 작성
- Filebeat가 CSV 파일을 읽고 Logstash에 전송하도록 설정하는 구성입니다.
<br/>

### 5. Docker Compose 실행
```
sudo docker-compose up
```
<br/>

## 결과물
### Elasticsearch Head 화면
![화면 캡처 2024-07-19 161052](https://github.com/user-attachments/assets/7a71cc81-e0cf-486f-b53a-c011f34a265f)
<br/>


### 우분투 logstash 부분 로그
![화면 캡처 2024-07-19 161201](https://github.com/user-attachments/assets/beda40d4-a476-4041-9bf5-04576bea7209)
<br/>

## 방법 2. 우분투 리눅스에서 ELK 스택 구축하기
### [노션링크](https://mirage-rosemary-e9d.notion.site/07-19-D-10-Pipe-13c5ed9ed2464108b8fde0675bb5346f)


<br/>

### 쉘 스크립트를 이용한 설치 방법
<hr>

#### ELK stack 전체를 한번에 설치하는 경우


-  ELK-Install.sh
```
# ElasticSearch - Logstash - Filebeat 순으로 패키지 설치를 진행합니다.
# - 기존의 설치, 실행중인 서비스가 있을 경우
# - 서비스 종료 - 설정 파일 ,패키지 삭제 후 설치를 시작합니다.

cd /{path to ELK-Install.sh}
ELK-Install.sh
```

<br>

### ELK Stack 요소 별로 설치

- ES-Install.sh

```
# ElasticSearch 패키지 파일을 설치합니다.
# - 기존에 실행 , 실행중인 서비스가 있을 경우
# - 서비스 종료 - 설정 파일 ,패키지 삭제 후 설치를 시작합니다.

cd /{path to ELK-Install.sh}
bash ES-Install.sh
```
<br>

- Logstash-Install.sh
```
# Logstash 패키지 파일을 설치합니다.
# - 기존에 실행 , 실행중인 서비스가 있을 경우
# - 서비스 종료 - 설정 파일 ,패키지 삭제 후 설치를 시작합니다.

cd /{path to Logstash-Install.sh}
bash Logstash-Install.sh

# - .yml 파일 , 혹은 filtering 파일을 지정할 경우
bash Logstash-Install.sh -c /path/to/*.yml -f /path/to/bankfisa3.conf

bash Logstash-Install.sh -c /path/to/*.yml

bash Logstash-Install.sh -f /path/to/bankfisa3.conf
```
<br>

- Filebeat-Install.sh
```
# Logstash 패키지 파일을 설치합니다.
# - 기존에 실행 , 실행중인 서비스가 있을 경우
# - 서비스 종료 - 설정 파일 ,패키지 삭제 후 설치를 시작합니다.

cd /{path to Logstash-Install.sh}
bash Filebeat-Install.sh

# - *.yml 파일을 추가하는 경우
# - yml파일에 지정한 위치에 파일이 존재 해야 합니다.
bash Filebeat-Install.sh -c /path/to/{*.yml}


```

<br>


### 추후 해볼 것
```
- python 코드로 shell script 대체
- curl 명령어를 사용해 확장성 높이기
- 다양한 옵션 수용 가능한 스크립트 작성
- 키바나 추가 후 윈도우 에서 확인
- 도커 swamp 사용하여 전개
```
