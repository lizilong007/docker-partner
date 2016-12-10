# docker-partner
dockerfile bulid phpbrew+php+nginx Environment

# Install Docker
[Install Docker](https://docs.docker.com/engine/installation/)

# Building the container
Once you have to setup the project run:
```
docker build -t partner
```
If hesitant network causes mirror to build slowly, can I build a good image
```
docker pull daocloud.io/lizilong/partner:latest
```

# Getting it running
To run nginx in the blackgroud process, simply start the container useing the following command:
```
docker run -p 80:80 -v /dockerdata:/dockerdata -d partner
```
If you hope login the container by ssh.need config new file example`config/id_rsa/xxx.pub.enabled` and after rebuild to run :
```
docker run -p 80:80 -p 50001:22 -v /dockerdata:/dockerdata -d partner
ssh root@localhost -p 50001
```
-p 80:80 publishes port 80 in the container to 80 on the host machine.
-v /dockerdata:/dockerdata If you’re actively developing you want to be able to change files in your usual editor and have them reflected within the container without having to rebuild it. The -v flag allows us to mount a directory from the host into the container

