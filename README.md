# 우리FISA ELK 스택 구축 프로젝트 🔨
> Window 환경에서 진행한 ELK 파이프라인(Elasticsearch, Logstash, Kibana, Filebeat) 스택 구축을 우분투 리눅스 환경으로도 진행해 보았습니다.

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

## 💥 트러블 슈팅
- ```filebeat.yml```: paths 경로를 호스트 경로가 아닌 도커 컨테이너 내부 경로로 변경하여 해결
    ```
    paths:
    - /usr/share/filebeat/data/bank-data.csv  # 컨테이너 내부 경로
    ```
    <br/>
- ```logstash.conf```: ```http://localhost:9200```대신 ```elasticsearch:9200```로 변경해서 도커 컨테이너 이름을 사용하도록 변경하여 해결
    ```
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        index => "bank-data"
    }
    ```
    <br/>
- ```filebeat.yml```: 파일 권한 설정 변경
    ```
    // 그룹과 다른 사용자의 쓰기 권한을 제거
    chmod go-w ~/ELK/filebeat/filebeat.yml
    ```
- 우분투에서 **용량 부족 문제 해결**을 위해 VirtualBox에서 메모리, 디스크 용량을 올린 우분투 환경을 새로 만듦

- VirtualBox에서 ```127.0.0.1 -> 10.0.2.15```로 포트포워딩 (22, 9200, 5601) 설정
![화면 캡처 2024-07-19 173507](https://github.com/user-attachments/assets/ef59c3d8-dd0f-425b-9448-676f03a65727)

## 결과물
### Elasticsearch Head 화면
![화면 캡처 2024-07-19 161052](https://github.com/user-attachments/assets/7a71cc81-e0cf-486f-b53a-c011f34a265f)
<br/>


### 우분투 logstash 부분 로그
![화면 캡처 2024-07-19 161201](https://github.com/user-attachments/assets/beda40d4-a476-4041-9bf5-04576bea7209)
<br/>

## 방법 2. 우분투 리눅스에서 ELK 스택 구축하기
### [노션링크](https://mirage-rosemary-e9d.notion.site/07-19-D-10-Pipe-13c5ed9ed2464108b8fde0675bb5346f)