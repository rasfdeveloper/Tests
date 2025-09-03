# syntax=docker/dockerfile:1
FROM docker-remotes.artifactory.prod.aws.cloud.ihf/amazonlinux:2023

# Proxies (passe via --build-arg no build)
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

# 1) CA corporativo antes de qualquer dnf/yum
COPY ca_bundle.crt /etc/pki/ca-trust/source/anchors/company-root.crt
RUN dnf -y install ca-certificates && update-ca-trust

# 2) dnf.conf: liga verificação de SSL e configura proxy (se fornecida)
RUN printf "\nsslverify=1\n" >> /etc/dnf/dnf.conf \
 && if [ -n "${HTTPS_PROXY}${HTTP_PROXY}" ]; then \
      PROXY="${HTTPS_PROXY:-$HTTP_PROXY}"; \
      printf "proxy=%s\n" "$PROXY" >> /etc/dnf/dnf.conf; \
    fi

# 3) Pacotes necessários (sem kernel, sem nodesource)
RUN dnf -y install \
      python3.11 python3-pip \
      gcc gcc-c++ make \
      openssl-devel findutils tzdata \
 && dnf clean all && rm -rf /var/cache/dnf

# 4) Ferramentas usam o mesmo bundle de CA
ENV SSL_CERT_FILE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
    REQUESTS_CA_BUNDLE=/etc/pki/ca-trrust/extracted/pem/tls-ca-bundle.pem \
    CURL_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem

WORKDIR /src
COPY requirements.txt .
RUN python3.11 -m pip install --upgrade pip \
 && pip3 install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8082
CMD ["gunicorn","-b","0.0.0.0:8082","run:app"]
