#!/bin/sh
if [ ! -f "/app/.initialized" ]; then
  ./main -sql
  ./main -es
  touch /app/.initialized
fi
./main

# 重定向 和 管道输入echo | 都不起作用。决定./main -admin 暂时手动完成，后续再优化。
  # echo -e "2528765108@qq.com\n123456789\n" | ./main -admin

#   ./main -admin << EOF
# 2528765108@qq.com
# 123456789
# 123456789
# EOF