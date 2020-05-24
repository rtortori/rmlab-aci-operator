FROM quay.io/operator-framework/ansible-operator:v0.17.0

USER 0
RUN update-crypto-policies --set LEGACY && pip3 install pyopenssl
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY playbooks/ ${HOME}/playbooks/
COPY roles/ ${HOME}/roles/