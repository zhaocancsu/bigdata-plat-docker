# bigdata-plat-docker

基于docker搭建的大数据测试学习环境

- 软件列表
  - hadoop-2.8.5
  - hive-2.3.3
  - hbase-1.4.8
  - zookeeper-3.4.10
  - scala-2.12.7
  - jdk-8u191
  - spark-2.3.2
  - phoenix-4.14-hbase-1.4
  
  需要环境安装docker与docker-compose,然后按如下命令执行
  
  >docker build -f bigdata-base.dockerfile -t bigdata-env:v1.0 .<br>
   docker build -f bigdata.dockerfile -t bigdata-plat .<br>
   docker-compose up -d
