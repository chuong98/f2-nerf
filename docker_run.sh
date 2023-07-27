# docker run --gpus all --name f2nerf2 \
#     -v $PWD/confs:/f2-nerf/confs \
#     -v $PWD/scripts:/f2-nerf/scripts \
#     -v $PWD/exp:/f2-nerf/exp \
#     -v $PWD/data:/f2-nerf/data \
#     -v /data:/data \
#     -w /f2-nerf -it --rm -d f2-nerf:1

docker run --gpus all --name colmap2 \
    -w /working \
    -v $PWD/confs:/working/confs \
    -v $PWD/scripts:/working/scripts \
    -v $PWD/exp:/working/exp \
    -v $PWD/data:/working/data -it --rm -d colmap:latest