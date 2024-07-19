# WOORI FISA ELK 스택 구축 프로젝트
## 개발 팀원
- 이승언, 이정욱, 손대현, 최수연

## Docker를 사용하여 ELK 스택 구축하기
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

### 2. Docker Compose 파일 작성
- ```\ELK\docker-compose.yml```에 작성
- Docker Compose를 사용하여 ELK 스택 (Elasticsearch, Logstash, Kibana, Filebeat) 환경을 설정하는 스크립트입니다.
<br/>

![image](https://github.com/user-attachments/assets/ef498b55-15e3-44c7-bdf4-44c03a442434)
<br/>

### 3. Logstash 구성 파일 작성
- ```\ELK\logstash\pipeline\logstash.conf```에 작성
-  Filebeat에서 데이터를 수신하고, CSV 형식의 데이터를 파싱 및 변환하여 Elasticsearch에 전송하는 파이프라인을 설정합니다.
<br/>
<br/>

### 4. Filebeat 설정 파일 작성
- ```\ELK\filebeat\filebeat.yml```에 작성
- Filebeat가 CSV 파일을 읽고 Logstash에 전송하도록 설정하는 구성입니다. 
<br/>
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