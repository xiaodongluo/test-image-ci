FROM nginx
MAINTAINER 2018-07-02 20:13:10
ENV RUN_USER nginx
ENV RUN_GROUP nginx
ENV DATA_DIR /data/web
ENV LOG_DIR /data/log/nginx
RUN mkdir /data/log/nginx -p
RUN chown nginx.nginx -R /data/log/nginx
RUN ln -sf /dev/stdout /data/log/nginx/access.log
ADD web /data/web
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT nginx -g "daemon off;"
