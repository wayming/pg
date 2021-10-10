Build image:
docker build --rm --progress=plain -t postgres-centos .

Run container:
docker kill pg; docker system prune -f; docker run --privileged -d --name pg postgres-centos

Attach the container:
docker exec -it pg bash
