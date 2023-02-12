# FROM httpd:2.4
# COPY ./website/ /usr/local/apache2/htdocs/

#Use an existing image as the base image
FROM centos:7

#Install Apache HTTP server
RUN yum update -y && \
    yum install httpd -y

#Make port 100 available to the host
EXPOSE 100

WORKDIR /var/www/html
COPY index.html /var/www/html/index.html

#Start the Apache service when the container starts
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
