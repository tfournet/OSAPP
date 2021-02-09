containerdir=/usr/local/containers/domotz

compose="podman-compose" 

mkdir -p $containerdir

cp -f docker-compose.yaml $containerdir 

mkdir -p $containerdir/etc 

cd $containerdir
$compose pull
$compose up -d 

sleep 5
podman ps
