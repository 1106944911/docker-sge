FROM wtakase/sge-base:ubuntu
MAINTAINER wtakase <wataru.takase@kek.jp>

RUN apt-get -y update&&sudo apt-get install -y libxml-simple-perl vim
EXPOSE 6445 30222
ADD run.sh /run.sh
RUN chmod 755 /run.sh
CMD /run.sh
