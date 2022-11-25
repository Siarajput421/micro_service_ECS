FROM ubuntu:18.04

ARG file_path

RUN apt update -y
RUN apt install nginx -y

COPY $file_path /var/www/html

RUN rm /var/www/html/index.nginx-debian.html

EXPOSE 80 

CMD ["nginx", "-g","daemon off;"]

