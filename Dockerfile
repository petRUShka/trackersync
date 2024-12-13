FROM redmine:latest

COPY entrypoint.sh /usr/src/redmine/entrypoint.sh
RUN chmod +x /usr/src/redmine/entrypoint.sh
ENTRYPOINT ["/usr/src/redmine/entrypoint.sh"]
