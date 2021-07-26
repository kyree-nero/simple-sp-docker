file=$1
key=$2
value=$3

echo $1
echo $2
echo $3

PROPTOREPLACE=`cat $1 | grep ^$2`
NEWPROP=${key}=${value}

echo 'Prop to replace is ... ' + $PROPTOREPLACE
echo 'New prop will be ....' + ${NEWPROP}

#cat $1 | sed  "s|${PROPTOREPLACE}|${NEWPROP}|g" > temp.props
cat $1 | sed  "s|${PROPTOREPLACE}|${NEWPROP}|g" > temp.props
cp temp.props  $1

#echo "done"