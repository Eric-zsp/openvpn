# Original credit: https://github.com/Eric-zsp/openvpn

# Smallest base image
FROM centos:latest

LABEL maintainer="eric.zsp <eric.zsp@hotmail.com>"

# Testing: pamtester
RUN yum install -y openvpn iptables bash epel-release easy-rsa openvpn-auth-pam google-authenticator pamtester nginx && \
    yum install -y httpd php-mysql mariadb-server  php nodejs unzip git wget sed npm && \
    npm install -g bower && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    cd /usr/local/src  && \
    git clone https://github.com/Chocobozzz/OpenVPN-Admin openvpn-admin && \
    cd openvpn-admin && \
    rm -rf /tmp/* /var/tmp/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

CMD ["ovpn_run"]

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/