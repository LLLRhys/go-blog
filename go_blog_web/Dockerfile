FROM nginx:stable-alpine3.23-perl

WORKDIR /app
COPY ./dist /opt/go_blog/web/dist
# 涉及敏感数据的文件，不copy到镜像了，通过挂载卷注入
# COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
# COPY ./nginx/conf.d/nginx.conf /etc/nginx/conf.d/nginx.conf
# COPY ./cert  /etc/nginx/cert/

# 删除 Nginx 默认配置
RUN rm -f /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD  ["nginx", "-g", "daemon off;"]