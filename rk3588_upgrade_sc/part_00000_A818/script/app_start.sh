#! /bin/sh

REAL_LIB=/tmp/real_part/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$REAL_LIB:$REAL_LIB/common:$REAL_LIB/opencv:$REAL_LIB/mpp:/lib/aarch64-linux-gnu/
mount -o remount,rw /
cp -arf $REAL_LIB/mpp/librockchip_mpp.so.0 /usr/lib/librockchip_mpp.so.0
sync
mount -o remount,ro /
mount -o remount,rw /oem

cd /tmp/real_part/bin/
# 初始化计数器
counter=0

# 生成日志文件名
log_file="/tmp/output${counter}.log"

# 循环查找可用的日志文件名
while [ -e "$log_file" ]; do
    echo "日志文件 $log_file 已存在，尝试下一个文件名..."
    ((counter++))
    log_file="/tmp/output${counter}.log"
done

# 启动程序并将输出重定向到找到的日志文件
stdbuf -oL -eL ./rk_rga_test > "$log_file" 2>&1 &

# 可选：打印日志文件位置
echo "程序重启"
cd -
