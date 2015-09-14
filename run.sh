#!/bin/bash
image=${1}
host=www
work_path="$(pwd)"
zone_volume="${work_path}/www:/var/html/www"

if [ ! "$#" -eq 1 ]; then
	echo -e "Please keyin docker image name after $0"
else
	echo -e "docker run -d -h ${host} -v ${zone_volume} -p 5000:22 -p 80:80 ${image}"		
	docker run -d -h ${host} -v ${zone_volume} -p 5000:22 -p 80:80 ${image}
fi

#docker run -d -h top_bind -v /home/administrator/Dockers/bind-server/zones:/etc/bind/zones -p 5000:22 -p 53:53/udp top_bind-20150603:data
