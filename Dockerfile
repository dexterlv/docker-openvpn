# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:3.4

MAINTAINER Kyle Manna <kyle@kylemanna.com>

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester curl dnsmasq && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* && \
    curl -L https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

RUN wget https://github.com/markriggins/dockerfy/releases/download/0.2.4/dockerfy-linux-amd64-0.2.4.tar.gz; \
    tar -C /usr/local/bin -xvzf dockerfy-linux-amd64-*tar.gz; \
    rm dockerfy-linux-amd64-*tar.gz;
    
ENTRYPOINT ["/usr/sbin/crond -f -L 8"]
