build:
	docker build -t containers.cisco.com/sonicbuild-docker/sonic-cisco-apt-mirror:latest .

start:
	docker run -d --name mirror -v /nobackup/apt-mirror:/var/spool/apt-mirror -p 8080:80 containers.cisco.com/sonicbuild-docker/sonic-cisco-apt-mirror:latest
.PHONY: build start