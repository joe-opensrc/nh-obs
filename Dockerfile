FROM alpine:3.23.3

ARG UID=1000
ARG USER=fubinax

RUN /sbin/apk update 
RUN /sbin/apk add bash nethack

RUN /usr/sbin/adduser -D -u ${UID} -s /bin/bash ${USER}

ENV HDIR="/opt/nethack"
WORKDIR "${HDIR}"
COPY dot-nethackrc ${HDIR}/


RUN mkdir -p bones save level lock trouble
RUN cp /var/games/nethack/nhdat \
       /var/games/nethack/symbols \
       /var/games/nethack/sysconf \
       /var/games/nethack/license "${HDIR}"/

RUN touch perm logfile xlogfile

# yolo
RUN sed -i -e "s/WIZARDS=root games/WIZARDS=root games ${USER}/" /opt/nethack/sysconf

RUN chown -R "${USER}":"${USER}" "${HDIR}"/

USER ${USER}

ENV NETHACKDIR="${HDIR}" 
ENV NETHACKOPTIONS=@"${HDIR}/dot-nethackrc" 
ENV LEVELDIR="${HDIR}/level" 
ENV SAVEDIR="${HDIR}/save" 
ENV BONESDIR="${HDIR}/bones" 
ENV LOCKDIR="${HDIR}/lock" 
ENV TROUBLEDIR="${HDIR}/trouble"

ENV USER="${USER}"
ENTRYPOINT ["nethack"] 
