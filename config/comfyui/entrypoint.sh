#!/bin/bash
set -e

# Bootstrap custom nodes into the (possibly empty) mounted custom_nodes volume
if [ ! -d "/opt/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    echo "Installing ComfyUI-Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
        /opt/ComfyUI/custom_nodes/ComfyUI-Manager
fi

if [ ! -d "/opt/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper" ]; then
    echo "Installing ComfyUI-WanVideoWrapper (kijai)..."
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
        /opt/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper
    pip install -r /opt/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt
fi

exec python main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    --fast \
    --use-sage-attention
