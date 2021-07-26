#!/bin/sh

file=$1
startswith=$2

echo $1
echo $2

LINES_TO_UNCOMMENT=`cat $1 | grep ^#${2}`


echo 'lines to change is ... ' + $LINES_TO_UNCOMMENT

cat $1 | sed "s/^#${2}/${2}/" > temp.props
cp temp.props  $1