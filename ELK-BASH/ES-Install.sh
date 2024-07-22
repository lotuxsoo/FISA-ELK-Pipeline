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

# 매개변수 처리
CONFIG_YML=""

# getopts를 사용하여 -c 옵션 처리
while getopts "c:" opt; do
    case ${opt} in
        c )
            CONFIG_YML="$OPTARG"  # config-yml 옵션
            ;;
        \? )
            echo "Usage: cmd [-c config-yml]"
            exit 1
            ;;
    esac
done

# Elasticsearch 설정 파일 작성( 매개변수가 존재하는 경우 )
if [[ -n $CONFIG_YML ]] && [[ -f $CONFIG_YML ]]; then
    # 지정된 파일의 내용을 /etc/elasticsearch/elasticsearch.yml에 복사
    sudo cp "$CONFIG_YML" /etc/elasticsearch/elasticsearch.yml
else
    # 기본 설정 파일 작성( 매개변수가 존재하지 않는 경우 )
    sudo bash -c 'cat <<EOL > /etc/elasticsearch/elasticsearch.yml
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
discovery.type: single-node
EOL'
fi

# Elasticsearch 서비스 시작
sudo systemctl start elasticsearch.service

