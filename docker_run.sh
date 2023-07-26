docker run --gpus all --name f2nerf2 \
    -v $PWD/confs:/f2-nerf/confs \
    -v $PWD/scripts:/f2-nerf/scripts \
    -v $PWD/exp:/f2-nerf/exp \
    -v /data:/data \
    -w /f2-nerf -it --rm -d f2-nerf:1

