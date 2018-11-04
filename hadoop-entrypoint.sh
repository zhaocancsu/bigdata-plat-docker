#!/bin/bash

startHadoop(){
  /usr/local/hadoop-2.8.5/sbin/start-all.sh
}

startHbase(){
  ${HBASE_HOME}/bin/start-hbase.sh
}

startSpark(){
  /usr/local/spark-2.3.2-bin-hadoop2.7/sbin/start-all.sh
}

startHive(){
  nohup ${HIVE_HOME}/bin/hive --skiphbasecp --service hiveserver2 2>&1 >> /opt/hive-server2.log &
  nohup ${HIVE_HOME}/bin/hive --skiphbasecp --service metastore 2>&1 >> /opt/hive-metastore.log &
}

main(){
  /usr/sbin/sshd
  sleep 5
  echo "${ZK_ID}" >${ZOOKEEPER_HOME}/data/myid
  zkServer.sh start
  sleep 2
  
  if [ "${ROLE}" == "master" ]
  then
    hdfs namenode -format
    schematool  -initSchema -dbType mysql
    sleep 2
    startHadoop
    sleep 5
    startHbase
    sleep 5
    startSpark
    sleep 5
    startHive		
  fi
}

main
