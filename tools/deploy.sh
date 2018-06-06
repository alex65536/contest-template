#!/bin/bash

CONTEST_NAME="$(basename "${PWD}")"

SSH_HOST="${CMS_CONTEST_DEPLOY_USER}@${CMS_CONTEST_DEPLOY_HOST}"
SSH_PATH="${CMS_CONTEST_DEPLOY_DIR}${CONTEST_NAME}"

rsync -trl --del --progress "${PWD}/" "${SSH_HOST}:${SSH_PATH}/"

ssh -t "${SSH_HOST}" "bash -c \"
    . ~/cmsvenv.sh
    cmsImportContest -iuU '${SSH_PATH}'
\""
