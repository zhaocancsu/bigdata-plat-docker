FROM bigdata-env:v1.0
MAINTAINER fineplace <zhaocan1@xiaomi.com>

COPY hadoop-entrypoint.sh /usr/bin/
RUN chmod a+x /usr/bin/hadoop-entrypoint.sh

ENTRYPOINT [ "sh", "-c", "./usr/bin/hadoop-entrypoint.sh; bash"]
