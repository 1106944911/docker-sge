
FROM wtakase/sge-base:ubuntu
MAINTAINER wtakase <wataru.takase@kek.jp>

RUN apt-get -y update&&sudo apt-get install -y libxml-simple-perl vim
EXPOSE 6445 30222
ADD set_sge_client_env.sh /set_sge_client_env.sh
ADD start.sh /start.sh
RUN chmod 755 /start.sh /set_sge_client_env.sh
CMD /start.sh
