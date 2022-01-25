#!/bin/bash

VERSION=3.4.0.38
IMAGE=deepin-wine-wechat-arch:$VERSION

docker build \
        -t "$IMAGE" \
        .
