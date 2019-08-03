FROM quay.io/operator-framework/ansible-operator:v0.9.0

USER 0
RUN pip install pyopenssl
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY playbooks/ ${HOME}/playbooks/
COPY roles/ ${HOME}/roles/
