ARG UV_VERSION=0.9.2
ARG PYTHON_VERSION=3.12-trixie-slim
FROM ghcr.io/astral-sh/uv:${UV_VERSION}-python${PYTHON_VERSION} AS builder
ARG AVD_VERSION=5.7.0
ARG AVD_VENV=/avd-venv
ARG YQ_VERSION=v4.48.1
ARG YQ_BINARY=yq_linux_amd64

COPY requirements.txt collection-requirements.yml /build/

ENV ANSIBLE_COLLECTIONS_PATH=/usr/share/ansible/collections

RUN python -m venv ${AVD_VENV}
RUN UV_PYTHON=${AVD_VENV}/bin/python uv pip install pyavd[ansible]==${AVD_VERSION} -r /build/requirements.txt
RUN ${AVD_VENV}/bin/ansible-galaxy collection install arista.avd:==${AVD_VERSION}
RUN ${AVD_VENV}/bin/ansible-galaxy install -r /build/collection-requirements.yml

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq \
    && apt-get upgrade \
      --yes -qq --no-install-recommends \
    && apt-get install \
      --yes -qq --no-install-recommends \
      wget

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq

# Main stage
ARG UV_VERSION=0.9.2
ARG PYTHON_VERSION=3.12-trixie-slim
FROM ghcr.io/astral-sh/uv:${UV_VERSION}-python${PYTHON_VERSION} AS main
ARG AVD_VENV=/avd-venv

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq \
    && apt-get upgrade \
      --yes -qq --no-install-recommends \
    && apt-get install \
      --yes -qq --no-install-recommends \
      git \
      make \
      wget \
      curl

ENV AVD_VENV=${AVD_VENV}
ENV ANSIBLE_COLLECTIONS_PATH=/usr/share/ansible/collections

COPY --from=builder ${AVD_VENV} ${AVD_VENV}
COPY --from=builder /usr/share/ansible/collections /usr/share/ansible/collections
COPY --from=builder /usr/bin/yq /usr/bin/yq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
