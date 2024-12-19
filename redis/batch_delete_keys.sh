#!/bin/bash
# sh batch_delete_keys.sh $match $host $port 0 $count $sleep_seconds $auth
if [ "$#" -lt 3 ]
then
  echo "Scan keys in Redis matching a pattern using SCAN (safe version of KEYS)"
  echo "Usage: $0 [pattern] <host> [port] [database] [count] [second]"
  exit 1
fi
pattern=${1:-}
host=${2:-}
port=${3:-6379}
database=${4:-0}
count=${5:-5000}
second=${6:-1}
auth=${7:-}

if  [ ! -n "$pattern" ] ;then
    echo "pattern shoud not be empty!"
fi

cursor=-1

keys=''

while [ $cursor -ne 0 ]; do

   if [ $cursor -eq -1 ]
   then
       cursor=0
   fi

   reply=`redis-cli -h "$host" -p "$port" -n "$database" -a "$auth"  SCAN $cursor MATCH $pattern COUNT  $count`

   cursor=`expr "$reply" : '\([0-9]*[0-9 ]\)'`
   echo "cursor: $cursor"
   keys=${reply#[0-9]*[[:space:]]}
   echo "keys:"
   echo "$keys"
   redis-cli -h "$host" -p "$port" -a "$auth" -n "$database" DEL $keys

   sleep $second

done