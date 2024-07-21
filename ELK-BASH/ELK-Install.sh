#!/bin/bash

# 시스템 업데이트 및 HTTPS 전송 지원 설치
sudo apt update
sudo apt-get install -y apt-transport-https

# Elasticsearch 서비스 종료
sudo systemctl stop elasticsearch.service

# Elasticsearch 패키지 및 설정 파일 삭제
sudo dpkg --purge elasticsearch

# Elasticsearch 설치
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-amd64.deb.sha512

# SHA512 체크섬 확인
shasum -a 512 -c elasticsearch-7.11.1-amd64.deb.sha512

# Elasticsearch 패키지 설치
sudo dpkg -i elasticsearch-7.11.1-amd64.deb

# 기본 설정 파일 작성
sudo bash -c 'cat <<EOL > /etc/elasticsearch/elasticsearch.yml
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
discovery.type: single-node
EOL'

# Elasticsearch 서비스 시작
sudo systemctl start elasticsearch.service

# Logstash 서비스 종료
if systemctl is-active --quiet logstash; then
    echo "Logstash 서비스가 실행 중입니다. 종료합니다..."
    sudo systemctl stop logstash
else
    echo "Logstash 서비스가 실행 중이지 않습니다."
fi

# Logstash 패키지 및 설정 파일 삭제
sudo apt-get purge -y logstash

# 시스템 업데이트 및 HTTPS 전송 지원 설치
sudo apt update
sudo apt install -y apt-transport-https ca-certificates wget

# GPG 키 추가
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Elastic repository 추가
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'

# 패키지 목록 업데이트
sudo apt update

# Logstash 설치
sudo apt install -y logstash=1:7.11.1-1

# 기본 설정 파일 작성
sudo bash -c 'cat <<EOL > /etc/logstash/logstash.yml
output.logstash:
  hosts: ["localhost:5044"]
EOL'

# Logstash 설정 conf.d 및 bankfisa3 파일 생성
sudo mkdir -p /etc/logstash/conf.d
sudo touch /etc/logstash/conf.d/bankfisa3.conf

# Logstash 설정 파일 내용 작성
sudo bash -c 'cat <<EOL > /etc/logstash/conf.d/bankfisa3.conf
input {
  beats {
    port => 5044
  }
}

filter {
  mutate {
    split => [ "message",  "," ]
    add_field => {
      "date" => "%{[message][0]}"
      "bank" => "%{[message][1]}"
      "branch" => "%{[message][2]}"
      "location" => "%{[message][3]}"
      "customers" => "%{[message][4]}"
    }
    remove_field => ["ecs", "host", "@version", "agent", "log", "tags", "input", "message"]
  }

  date {
    match => [ "date", "yyyyMMdd"]
    timezone => "Asia/Seoul"
    locale => "ko"
    target => "date"
  }

  mutate {
    convert => {
      "customers" => "integer"
    }
    remove_field => [ "@timestamp" ]
  }
}

output {
  stdout {
    codec => rubydebug
  }

  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "bankfisa3"
  }
}
EOL'

echo "Logstash bankfisa3 작성 완료"

# Logstash 서비스 시작
sudo systemctl start logstash

# Filebeat 설치 시작
if systemctl is-active --quiet filebeat; then
    echo "Filebeat 서비스가 실행 중입니다. 종료합니다..."
    sudo systemctl stop filebeat
else
    echo "Filebeat 서비스가 실행 중이지 않습니다."
fi

# Filebeat 패키지 삭제
sudo dpkg --purge filebeat

# Filebeat 설치 시작
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.11.1-amd64.deb
sudo dpkg -i filebeat-7.11.1-amd64.deb

# Filebeat 설정 파일 생성
sudo touch /etc/filebeat/filebeat.yml

# 현재 사용자 이름 동적으로 가져오기
USERNAME=$(whoami)

# 기본 설정 파일 작성
sudo bash -c 'cat <<EOL > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: filestream
  id: my-filestream-id
  enabled: true
  paths:
    - /home/'"$USERNAME"'/bank.csv

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

output.elasticsearch:
  hosts: ["localhost:9200"]

setup.template.settings:
  index.number_of_shards: 1

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
EOL'

# bank.csv 파일 생성
sudo touch /home/"$USERNAME"/bank.csv

# 데이터 추가
sudo bash -c 'cat <<EOL > /home/'"$USERNAME"'/bank.csv
20180601,NH농협은행,1호점,종각,2314
20170601,NH농협은행,1호점,강남,5412
20170710,우리은행,1호점,강남,2543
20180715,NH농협은행,2호점,강남,4456
20200818,NH농협은행,4호점,강남,5724
20200902,우리은행,1호점,신촌,1002
20200911,우리은행,1호점,양재,4121
20200920,NH농협은행,3호점,홍제,1021
20201001,우리은행,1호점,불광,971
20230601,NH농협은행,2호점,종각,875
20180601,우리은행,2호점,강남,1506
20200902,우리은행,2호점,신촌,3912
20200911,우리은행,2호점,양재,784
20201001,우리은행,2호점,불광,4513
20211001,우리은행,3호점,불광,235
20160701,기업은행,1호점,불광,971
20171001,기업은행,2호점,불광,100
20231101,기업은행,3호점,불광,151
20201001,기업은행,4호점,불광,1302
EOL'
echo "Data has been written to /home/$USERNAME/bank.csv"

sudo systemctl start filebeat

echo "Filebeat install end"

