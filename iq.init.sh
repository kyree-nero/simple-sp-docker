#!/bin/sh

EXTRACTDIR=$1
IQBUILDCOMMANDSFILEPATH=$2

cd ${EXTRACTDIR}/WEB-INF/bin 
./iiq console < ${IQBUILDCOMMANDSFILEPATH}