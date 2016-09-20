#!/bin/sh
set -e

: ${POSTGRES_PORT_5432_TCP_ADDR:?"--link to a PostgreSQL container is not set"}
: ${GPG_PUBKEY_ID:?"-e GPG_PUBKEY_ID is not set"}
: ${S3_KEY:?"-e S3_KEY is not set"}

echo "* pg_dumpall to all.sql"
pg_dumpall -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres > all.sql
echo

echo "* downloading public key: ${GPG_PUBKEY_ID}"
gpg --keyserver pgp.mit.edu --recv-keys ${GPG_PUBKEY_ID}
echo

echo "* encrypting dump file using gpg"
gpg --always-trust -v -e -r ${GPG_PUBKEY_ID} -o all.sql.gpg all.sql
echo

echo "* shredding dump file"
shred -u -v all.sql
echo

echo "* uploading to Amazon S3 as: ${S3_KEY}"

if [ -z ${AWS_ACCESS_KEY_ID} ]; then
	echo -n "AWS_ACCESS_KEY_ID: "
	read AWS_ACCESS_KEY_ID
else
	echo "AWS_ACCESS_KEY_ID is set"
fi

if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then
	echo -n "AWS_SECRET_ACCESS_KEY: "
	read -s AWS_SECRET_ACCESS_KEY
	echo
else
	echo "AWS_SECRET_ACCESS_KEY is set"
fi

AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	aws s3 cp all.sql.gpg ${S3_KEY} --sse

echo

exec "$@"
