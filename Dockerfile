FROM docker-remotes.artifactory.prod.aws.cloud.ihf/amazonlinux:2023
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV TZ=America/Sao_Paulo \
    HTTP_PROXY=${HTTP_PROXY} \
    HTTPS_PROXY=${HTTPS_PROXY} \
    NO_PROXY=${NO_PROXY} \
    http_proxy=${HTTP_PROXY} \
    https_proxy=${HTTPS_PROXY} \
    no_proxy=${NO_PROXY}

# CA corporativo antes de qualquer acesso à rede
COPY ca_bundle.crt /etc/pki/ca-trust/source/anchors/company-root.crt
RUN yum -y install ca-certificates && update-ca-trust

# dnf.conf: CA + (se tiver) proxy
RUN printf "\nsslverify=1\n" >> /etc/dnf/dnf.conf \
 && if [ -n "${HTTPS_PROXY}${HTTP_PROXY}" ]; then \
        PROXY="${HTTPS_PROXY:-$HTTP_PROXY}"; \
        printf "proxy=%s\n" "$PROXY" >> /etc/dnf/dnf.conf; \
    fi

# (opcional) desabilite NodeSource se não usa
RUN yum -y install yum-utils && (yum-config-manager --disable nodesource* || true) \
 && rm -f /etc/yum.repos.d/nodesource*.repo || true

# pacotes necessários (sem mexer em kernel)
RUN yum -y install python3.11 python3-pip gcc gcc-c++ make openssl-devel findutils tzdata \
 && yum clean all && rm -rf /var/cache/yum

# Faça as ferramentas respeitarem o bundle de CA
ENV SSL_CERT_FILE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
    REQUESTS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
    CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem

WORKDIR /src
COPY requirements.txt .
RUN python3.11 -m pip install --upgrade pip \
 && pip3 install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8082
CMD ["gunicorn","-b","0.0.0.0:8082","run:app"]
