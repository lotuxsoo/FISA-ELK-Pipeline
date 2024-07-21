#!/bin/bash

# 기본 값 설정
CONFIG_YML=""
BANKFISA_CONF=""

# 옵션 처리
while getopts "c:f:" opt; do
    case ${opt} in
        c )
            CONFIG_YML="$OPTARG"  # config-yml 옵션
            ;;
        f )
            BANKFISA_CONF="$OPTARG"  # filter-conf 옵션
            ;;
        \? )
            echo "Usage: cmd [-c config-yml] [-f filter-conf]"
            exit 1
            ;;
    esac
done

# Logstash 서비스 종료
if systemctl is-active --quiet logstash; then
    echo "Logstash 서비스가 실행 중입니다. 종료합니다..."
    sudo systemctl stop logstash
else
    echo "Logstash 서비스가 실행 중이지 않습니다."
fi

# Elasticsearch 패키지 및 설정 파일 삭제
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

# Logstash 설정 파일 수정
if [[ -n $CONFIG_YML ]] && [[ -f $CONFIG_YML ]]; then
    # 지정된 파일의 내용을 /etc/logstash/logstash.yml에 복사
    sudo cp "$CONFIG_YML" /etc/logstash/logstash.yml
else
    # 기본 설정 파일 작성
    sudo bash -c 'cat <<EOL > /etc/logstash/logstash.yml
output.logstash:
  hosts: ["localhost:5044"]
EOL'
fi

# Logstash 설정 conf.d 및 bankfisa3 파일 생성
sudo mkdir -p /etc/logstash/conf.d
sudo touch /etc/logstash/conf.d/bankfisa3.conf

# Logstash 설정 파일 내용 작성
if [[ -n $BANKFISA_CONF ]] && [[ -f $BANKFISA_CONF ]]; then
    # 지정된 파일의 내용을 /etc/logstash/conf.d/bankfisa3.conf에 복사
    sudo cp "$BANKFISA_CONF" /etc/logstash/conf.d/bankfisa3.conf
else
    # 기본 설정 파일 작성
    sudo bash -c 'cat <<EOL > /etc/logstash/conf.d/bankfisa3.conf
input {
  # beat에서 데이터를 받을 port 지정
  beats {
    port => 5044
  }
}

filter {
  mutate {
    # 실제 데이터는 "message" 필드로 오기 때문에 csv 형태의 내용을 분할하여 새로운 이름으로 필드를 추가
    split => [ "message",  "," ]
    add_field => {
      "date" => "%{[message][0]}"
      "bank" => "%{[message][1]}"
      "branch" => "%{[message][2]}"
      "location" => "%{[message][3]}"
      "customers" => "%{[message][4]}"
    }

    # 기본으로 전송되는 데이터 분석에 불필요한 필드는 제거한다. "message" 필드도 위에서 재 가공했으니 제거
    remove_field => ["ecs", "host", "@version", "agent", "log", "tags", "input", "message"]
  }

  # "date" 필드를 이용하여 Elasticsearch에서 인식할 수 있는 date 타입의 형태로 필드를 추가
  date {
    match => [ "date", "yyyyMMdd"]
    timezone => "Asia/Seoul"
    locale => "ko"
    target => "date"
  }

  # Kibana에서 데이터 분석 시 필요하기 때문에 숫자 타입으로 변경
  mutate {
    convert => {
      "customers" => "integer"
    }
    remove_field => [ "@timestamp" ]
  }
}

output {
  # 콘솔창에 어떤 데이터들로 필터링 되었는지 확인
  stdout {
    codec => rubydebug
  }

  # 위에서 설치한 Elasticsearch로 "bank"라는 이름으로 인덱싱
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "bankfisa3"
  }
}
EOL'
fi

echo "Logstash bankfisa3 작성 완료"

# Logstash 서비스 시작
sudo systemctl start logstash

