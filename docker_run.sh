#!/bin/bash

image_name=reg.deeproute.ai/deeproute-public/deepin-wine-wechat-arch:3.4.0.38
wechat_files=$HOME/Temps/WechatFiles
container_name=wechat-arch

RUN_CMD=/opt/apps/com.qq.weixin.deepin/files/run.sh
WINDOW_CMD="/opt/deepinwine/tools/sendkeys.sh w wechat 4"

[ ! -d $wechat_files ] && mkdir -p $wechat_files

xhost + > /dev/null 2>&1

function docker_run() {
  docker run -i -d \
    --name $container_name \
    --ipc=host \
    --net=host \
    --device /dev/snd \
    --device /dev/video0 \
    -v "$wechat_files":'/root/WeChat Files/' \
    -v /etc/localtime:/etc/localtime:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e VIDEO_GID=`getent group video | cut -d: -f3` \
    --entrypoint /bin/bash \
    $image_name 
    #$RUN_CMD
    #--gpus=all \
    #-e NVIDIA_DRIVER_CAPABILITIES="all" \
}

function print_help() {
    echo "Supported ctions (default start if action is not specified):
  start: start $container_name container and run wechat application
  retsrat: restart $container_name container and run wechat application
  stop: stop wechat application and stop $container_name container
  remove: stop wechat application and remove $container_name container from docker
  window: restore wechat window if wechat window disappeared while container is running"
}

action=$1
if [ "$action" = "help" ]; then
    print_help
    exit 0
elif [ "$action" = "restart" ]; then
    docker ps --filter name=$container_name | grep $container_name -q && docker restart $container_name || \
      docker inspect $container_name > /dev/null && docker start $container_name || docker_run
    docker exec $container_name $RUN_CMD
elif [ "$action" = "stop" ]; then
    echo "stop container $container_name"
    docker ps --filter name=$container_name | grep $container_name -q && docker stop $container_name > /dev/null
elif [ "$action" = "rm" ] || [ "$action" = "remove" ]; then
    echo "remove container $container_name"
    docker ps --filter name=$container_name | grep $container_name -q && docker stop $container_name
    docker inspect $container_name > /dev/null && docker rm $container_name
elif [ "$action" = "window" ]; then
    docker ps --filter name=$container_name | grep $container_name -q || \
      { echo "container $container_name is not running, use '$0' to start at first"; exit 1; }
    docker exec $container_name ps aux | grep WeChat.exe -q && \
      docker exec $container_name $WINDOW_CMD || \
      docker exec $container_name $RUN_CMD
elif [ "$action" = "exec" ]; then
    docker exec -it $container_name bash
else
    docker ps --filter name=$container_name | grep $container_name -q && \
      echo "container $container_name is already running" && \
      docker exec $container_name ps aux | grep WeChat.exe -q && \
      docker exec $container_name $WINDOW_CMD && exit 0
    docker inspect $container_name > /dev/null && docker start $container_name || docker_run
    docker exec $container_name $RUN_CMD
fi

