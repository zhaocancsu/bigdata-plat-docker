FROM centos
MAINTAINER fineplace <zhaocan1@xiaomi.com>

#install jdk
ADD jdk-8u191-linux-x64.tar.gz /usr/local
ENV JAVA_HOME=/usr/local/jdk1.8.0_191
ENV PATH $JAVA_HOME/bin:$PATH

#install zookeeper
ADD zookeeper-3.4.10.tar.gz /usr/local
RUN cd /usr/local \
	&& cd zookeeper-3.4.10	\
	&& mkdir data	\
	&& mkdir log	

COPY conf/zookeeper/zoo.cfg /usr/local/zookeeper-3.4.10/conf
ENV ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10
ENV PATH $ZOOKEEPER_HOME/bin:$PATH


# Hadoop Cluster install
# https://hadoop.apache.org/docs/r2.8.5/hadoop-project-dist/hadoop-common/ClusterSetup.html
ADD hadoop-2.8.5.tar.gz /usr/local
ENV HADOOP_HOME=/usr/local/hadoop-2.8.5
ENV PATH $HADOOP_HOME/bin:$PATH
ENV HADOOP_PREFIX=$HADOOP_HOME
RUN cd $HADOOP_HOME	\
	&& mkdir tmp \
	&& mkdir -p dfs/name \
	&& mkdir -p dfs/data \	
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/hadoop-env.sh \
	&& echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> etc/hadoop/hadoop-env.sh \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/yarn-env.sh \
	&& echo "slave1" >> etc/hadoop/slaves	\
	&& echo "slave2" >> etc/hadoop/slaves	\
	&& rpm --rebuilddb	\
	&& yum install -y initscripts \
	&& yum -y install which	\
	&& yum -y install openssh-server \
	&& echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
	&& yum -y install openssh-clients \
	&& /usr/sbin/sshd-keygen -A \
	&& mkdir /root/.ssh \
	&& ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa \
	&& cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys \
	&& echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
	&& echo "    StrictHostKeyChecking=no" >> /etc/ssh/ssh_config \
	&& chmod 600 /root/.ssh/authorized_keys 

COPY conf/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop
COPY conf/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop
COPY conf/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop
COPY conf/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop

#install hive
ADD apache-hive-2.3.3-bin.tar.gz /usr/local
ENV HIVE_HOME=/usr/local/apache-hive-2.3.3-bin
ENV PATH $HIVE_HOME/bin:$PATH
RUN 	cd /usr/local	\
	&& rm -rf apache-hive-2.3.3-bin.tar.gz	\
	&& cd apache-hive-2.3.3-bin	\
	&& mv lib/icu4j-4.8.1.jar lib/icu4j-4.8.1.jarold  \
	&& mkdir aux-lib	\
	&& echo "export HADOOP_HOME=$HADOOP_HOME" >> conf/hive-env.sh \
	&& echo "export HIVE_CONF_DIR=$HIVE_HOME/conf" >> conf/hive-env.sh \
	&& echo "export HIVE_AUX_JARS_PATH=$HIVE_HOME/aux-lib" >> conf/hive-env.sh

COPY conf/hive/hive-site.xml /usr/local/apache-hive-2.3.3-bin/conf
COPY phoenix-4.14.0-HBase-1.4-client.jar /usr/local/apache-hive-2.3.3-bin/aux-lib
COPY phoenix-4.14.0-HBase-1.4-hive.jar /usr/local/apache-hive-2.3.3-bin/aux-lib


#install hbase
ADD hbase-1.4.8-bin.tar.gz /usr/local

RUN 	cd /usr/local	\
	&& rm -rf hbase-1.4.8-bin.tar.gz	\
	&& cd hbase-1.4.8	\
	&& mkdir zookeeper	\
	&& mkdir /var/hbase	\
	&& cat /dev/null > conf/regionservers	\
	&& echo "slave1" >> conf/regionservers	\
	&& echo "slave2" >> conf/regionservers	\
	&& echo "export JAVA_HOME=$JAVA_HOME" >> conf/hbase-env.sh	\
	&& echo "export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib" >> conf/hbase-env.sh 
ENV HBASE_HOME=/usr/local/hbase-1.4.8
ENV HBASE_CLASSPATH=$HBASE_HOME/conf
ENV HBASE_LOG_DIR=$HBASE_HOME/logs
ENV PATH $HBASE_HOME/bin:$PATH
COPY conf/hbase/hbase-site.xml /usr/local/hbase-1.4.8/conf

#spark
ADD spark-2.3.2-bin-hadoop2.7.tgz   /usr/local
ADD scala-2.12.7.tgz 	/usr/local

RUN 	cd /usr/local	\
	&& rm -rf spark-2.3.2-bin-hadoop2.7.tgz	\
	&& rm -rf scala-2.12.7.tgz \
	&& cd spark-2.3.2-bin-hadoop2.7	\
	&& echo "slave1" >> conf/slaves	\
	&& echo "slave2" >> conf/slaves	\
	&& echo "export SCALA_HOME=/usr/local/scala-2.12.7" >> conf/spark-env.sh	\
	&& echo "export JAVA_HOME=$JAVA_HOME" >> conf/spark-env.sh	\
	&& echo "export HADOOP_HOME=$HADOOP_HOME" >> conf/spark-env.sh	\
	&& echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> conf/spark-env.sh	\
	&& echo "SPARK_MASTER_IP=master" >> conf/spark-env.sh	\
	&& echo "SPARK_LOCAL_DIRS=/usr/local/spark-2.3.2-bin-hadoop2.7" >> conf/spark-env.sh	\
	&& echo "SPARK_DRIVER_MEMORY=1G" >> conf/spark-env.sh \
	&& cp cp /usr/local/apache-hive-2.3.3-bin/conf/hive-site.xml conf/



#other
COPY mysql-connector-java-5.1.44.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars
COPY mysql-connector-java-5.1.44.jar /usr/local/apache-hive-2.3.3-bin/lib
COPY phoenix-4.14.0-HBase-1.4-client.jar /usr/local/hbase-1.4.8/lib
COPY phoenix-core-4.14.0-HBase-1.4.jar /usr/local/hbase-1.4.8/lib

RUN 	cp /usr/local/apache-hive-2.3.3-bin/lib/hive-hbase-handler-2.3.3.jar /usr/local/hbase-1.4.8/lib	\
    && cp /usr/local/apache-hive-2.3.3-bin/lib/hive-hbase-handler-2.3.3.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars	\
	&& cp /usr/local/apache-hive-2.3.3-bin/lib/metrics-core-2.2.0.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp -r /usr/local/hbase-1.4.8/lib/hbase-metrics* /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-hadoop2-compat-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-hadoop-compat-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-protocol-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-common-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-server-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \
	&& cp /usr/local/hbase-1.4.8/lib/hbase-client-1.4.8.jar /usr/local/spark-2.3.2-bin-hadoop2.7/jars  \





