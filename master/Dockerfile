FROM wtakase/sge-base:ubuntu
MAINTAINER wtakase <wataru.takase@kek.jp>

RUN apt-get -y update&&sudo apt-get install -y libxml-simple-perl
RUN cp -rf /opt/sge /tmp/sge
EXPOSE 6444 30222
ADD run.sh /run.sh
RUN chmod 755 /run.sh
CMD /run.sh
