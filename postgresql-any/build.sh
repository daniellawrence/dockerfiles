#!/bin/bash 
#--------------------------------------
# Build the docker image 
#--------------------------------------

usage() { 
	echo "usage: $0 -u 12.04|12.10|13.04|13.10 -p 9.0|9.1|9.2|9.3";
        echo " -u <ubuntu_version> (default: 12.04)"
        echo " -p <postgresql_version> (default: 9.3)"
	exit 1;
}
UBUNTU_VERSION="12.04"
POSTGRESQL_VERSION="9.3"

if [ $# == 0 ];then
   usage
fi

while getopts ":u:p:" o; do
    case "${o}" in
        u)
            UBUNTU_VERSION=${OPTARG}
            ;;
        p)
            POSTGRESQL_VERSION=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ $UBUNTU_VERSION == "12.04" ];then
     UBUNTU_CODENAME="precise"
elif [ $UBUNTU_VERSION == "12.10" ];then
     UBUNTU_CODENAME="quantal"
elif [ $UBUNTU_VERSION == "13.04" ];then
     UBUNTU_CODENAME="raring"
elif [ $UBUNTU_VERSION == "13.10" ];then
     UBUNTU_CODENAME="saucy"
else
    echo "Unknown Ubuntu Version: $UBUNTU_VERSION"
    exit 1
fi

cat Dockerfile.template | \
    sed -e "s/__UBUNTU_VERSION__/$UBUNTU_VERSION/g" \
    -e "s/__UBUNTU_CODENAME__/$UBUNTU_CODENAME/g" \
    -e "s/__POSTGRESQL_VERSION__/$POSTGRESQL_VERSION/g"  \
    | docker build -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION} -

echo "Starting test instance"
PG_TEST=$(docker run -d -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION})
echo "Grabbing :5432 for $PG_TEST"
PG_TEST_PORT=$(docker port $PG_TEST 5432)
echo "Waiting for ${PG_TEST}'s :${PG_TEST_PORT} to start..."
sleep .25
echo "Test psql conection and grabbing the version"
echo 'select version();' | psql -t -h localhost -U postgres -p $PG_TEST_PORT
echo "Shutting down $PG_TEST"
docker stop $PG_TEST
