
FROM wtakase/sge-base:ubuntu
MAINTAINER wtakase <wataru.takase@kek.jp>

EXPOSE 6445 30222
ADD set_sge_commit_env.sh /set_sge_commit_env.sh
ADD start.sh /start.sh
RUN chmod 755 /start.sh /set_sge_commit_env.sh
CMD /start.sh
