#!/bin/bash

# 매개변수 처리
CONFIG_YML=""

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

# Filebeat 서비스 종료
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

if [[ -n $CONFIG_YML ]] && [[ -f $CONFIG_YML ]]; then
    # 지정된 파일의 내용을 /etc/filebeat/filebeat.yml에 복사
    sudo cp "$CONFIG_YML" /etc/filebeat/filebeat.yml
else
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
  # Array of hosts to connect to.
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
fi  # if 문 종료

sudo systemctl start filebeat

echo "Filebeat install end"
