docker run --gpus all --name f2nerf \
    -v $PWD:/f2-nerf \
    -u $(id -u www-data):$(id -g www-data) \
    -w /f2-nerf -it --rm -d f2-nerf:1
