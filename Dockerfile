FROM debian:bookworm-slim

LABEL maintainer="adarshsrinivasan08@gmail.com"

# Update APT repository & install packages
RUN set -eux; \
  apt -q update && apt dist-upgrade -y; \
  apt -y --no-install-recommends install \
    supervisor \
    curl \
    apt-utils \
    bash-completion \
    gpg-agent \
    ca-certificates \
    wget \
    cron \
    nano \
    gettext-base \
    xz-utils \
    rng-tools \
    gcc \
    make \
    perl \
    rsync; \
  apt clean && apt autoclean && apt autoremove; \
  echo "if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi" >> /etc/bash.bashrc;

COPY [ "assets", "/tmp/assets" ]

# Configure apt-mirror

RUN install -m 755 -D /tmp/assets/apt-mirror /usr/local/bin/apt-mirror \
    && mkdir -p /usr/local/share/man/man1/ \
	&& pod2man apt-mirror > /usr/local/share/man/man1/apt-mirror.1 \
	&& mkdir -p /var/spool/apt-mirror/mirror \
	&& mkdir -p /var/spool/apt-mirror/skel \
	&& mkdir -p /var/spool/apt-mirror/var \
    && mkdir -p /etc/apt/ \
    && mv /tmp/assets/mirror.list /etc/apt/mirror.list

# Configure Nginx
RUN  set -eux; \
  apt -q update && apt -y install nginx && apt clean; \
  rm /etc/nginx/sites-enabled/* \
    && mkdir -p /etc/nginx/templates \
    && mv /tmp/assets/nginx.conf.template /etc/nginx/templates/default.conf.template;


# Configure supervisord
RUN mv /tmp/assets/supervisord.web.conf /etc/supervisor/conf.d/web.conf
RUN mv /tmp/assets/*.sh /opt/

# Clean up
RUN rm -r /tmp/assets;

# Declare ports in use
EXPOSE 80 8080

VOLUME [ "/var/spool/apt-mirror" ]

ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Start supervisord when container starts
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

WORKDIR /opt