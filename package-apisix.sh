#!/usr/bin/env bash
set -euo pipefail
set -x
mkdir /output
dist=$(cat /tmp/dist)

# Determine the dependencies
dep_pcre="pcre"
if [ "$PACKAGE_TYPE" == "deb" ]
then
	dep_pcre="libpcre3"
fi

# Determine the min version of openresty or apisix-openresty
#	openresty >= 1.17.8.2
#	apisix-openresty >= 1.19.3.2.0
or_version="1.17.8.2"
if [ "$OPENRESTY" == "apisix-openresty"]
then
	or_version="1.19.3.2.0"
fi

fpm -f -s dir -t "$PACKAGE_TYPE" \
	--"$PACKAGE_TYPE"-dist "$dist" \
	-n apisix \
	-a "$(uname -i)" \
	-v "$PACKAGE_VERSION" \
	--iteration "$ITERATION" \
	-d "$OPENRESTY >= $or_version" \
	-d "$dep_pcre" \
	--description 'Apache APISIX is a distributed gateway for APIs and Microservices, focused on high performance and reliability.' \
	--license "ASL 2.0" \
	-C /tmp/build/output/apisix \
	-p /output \
	--url 'http://apisix.apache.org/' \
	--config-files usr/lib/systemd/system/apisix.service

# Rename deb file with adding $DIST section
if [ "$PACKAGE_TYPE" == "deb" ]
then
	mv /output/apisix_${PACKAGE_VERSION}-${ITERATION}_amd64.deb /output/apisix_${PACKAGE_VERSION}-${ITERATION}~${dist}_amd64.deb
fi
