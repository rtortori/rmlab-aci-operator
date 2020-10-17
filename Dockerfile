FROM quay.io/operator-framework/ansible-operator:v1.0.0

COPY requirements.yml ${HOME}/requirements.yml

USER 0
RUN pip3 install pyopenssl \
&& ansible-galaxy collection install -r ${HOME}/requirements.yml \
&& chmod -R ug+rwx ${HOME}/.ansible
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
