FROM alpine:3.23

WORKDIR /app

COPY main  ./
COPY entrypoint.sh ./
COPY wait-for-it.sh ./

RUN chmod +x main entrypoint.sh wait-for-it.sh

# Install bash for wait-for-it.sh
RUN apk add --no-cache bash

# 若是更新代码，加上下面的指令，防止触发 entrypoint.sh 脚本的初始化操作。
RUN touch .initialized

EXPOSE 8080

ENTRYPOINT ["./wait-for-it.sh", "-t", "0", "elasticsearch:9200", "--", "./entrypoint.sh"]
