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

#####################################################################################
cat Dockerfile-master | \
    sed -e "s/__UBUNTU_VERSION__/$UBUNTU_VERSION/g" \
    -e "s/__UBUNTU_CODENAME__/$UBUNTU_CODENAME/g" \
    -e "s/__POSTGRESQL_VERSION__/$POSTGRESQL_VERSION/g"  \
    | docker build -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_master -
echo "Built: ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_master"

#####################################################################################
cat Dockerfile-slave | \
    sed -e "s/__UBUNTU_VERSION__/$UBUNTU_VERSION/g" \
    -e "s/__UBUNTU_CODENAME__/$UBUNTU_CODENAME/g" \
    -e "s/__POSTGRESQL_VERSION__/$POSTGRESQL_VERSION/g"  \
    | docker build -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_slave -

echo "Built: ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_slave"
#####################################################################################

echo "Starting test instance"
PG_MASTER_TEST=$(docker run -d -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_master)
echo "Grabbing :5432 for $PG_TEST"
PG_MASTER_TEST_PORT=$(docker port $PG_MASTER_TEST 5432)
echo "Waiting for ${PG_TEST}'s :${PG_MASTER_TEST_PORT} to start..."
sleep .25
echo "Test psql conection and grabbing the version"

PG_MASTER_IP=$(docker inspect $PG_MASTER_TEST | awk '$0 ~ /IPAddress/ {print $2}' | sed 's/[^0-9.]//g')
echo "PG_MASTER_IP=${PG_MASTER_IP}"

#PG_SLAVE_TEST=$(docker run -d -e PG_MASTER_HOST=$PG_MASTER_IP -t ${UBUNTU_CODENAME}_postgresql:${POSTGRESQL_VERSION}_slave)
#echo "Grabbing :5432 for $PG_SLAVE_TEST"
#PG_SLAVE_TEST_PORT=$(docker port $PG_SLAVE_TEST 5432)

echo "CREATE TABLE array_int (vector  int[][]);" | psql -U postgres -h localhost -p $PG_MASTER_TEST_PORT


docker stop $PG_MASTER_TEST
#docker stop $PG_SLAVE_TEST
