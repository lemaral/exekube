FROM alpine:3.7

ENV CLOUD_SDK_VERSION 193.0.0
ENV HELM_VERSION 2.7.2
ENV TERRAFORM_VERSION 0.11.4
ENV TERRAGRUNT_VERSION 0.14.2
ENV TERRAFORM_PROVIDER_HELM_VERSION 0.5.0

ENV PATH /google-cloud-sdk/bin:/exekube-modules/scripts:$PATH

COPY modules /exekube-modules/
COPY docker-entrypoint.sh /usr/local/bin/

RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        openssl \
        tar \
        ca-certificates \
        apache2-utils

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && ln -s /lib /lib64 \
        && gcloud config set core/disable_usage_reporting true \
        && gcloud config set component_manager/disable_update_check true \
        && gcloud config set metrics/environment github_docker_image \
        && gcloud --version \
        && gcloud components install alpha beta kubectl \
        && gcloud components update

RUN curl -L -o helm.tar.gz \
        https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        && tar -xvzf helm.tar.gz \
        && rm -rf helm.tar.gz \
        && chmod 0700 linux-amd64/helm \
        && mv linux-amd64/helm /usr/bin

RUN curl -o ./terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        && unzip terraform.zip \
        && mv terraform /usr/bin \
        && rm -rf terraform.zip

RUN curl -L -o ./terragrunt \
        https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
        && chmod 0700 terragrunt \
        && mv terragrunt /usr/bin

RUN curl -L -o ./tph.tar.gz \
        https://github.com/mcuadros/terraform-provider-helm/releases/download/v${TERRAFORM_PROVIDER_HELM_VERSION}/terraform-provider-helm_v${TERRAFORM_PROVIDER_HELM_VERSION}_linux_amd64.tar.gz \
        && tar -xvzf tph.tar.gz \
        && rm -rf tph.tar.gz \
        && cd terraform-provider-helm_linux_amd64 \
        && mv terraform-provider-helm terraform-provider-helm_v${TERRAFORM_PROVIDER_HELM_VERSION} \
        && chmod 0700 terraform-provider-helm_v${TERRAFORM_PROVIDER_HELM_VERSION} \
        && mkdir -p /root/.terraform.d/plugins/ \
        && mv terraform-provider-helm_v${TERRAFORM_PROVIDER_HELM_VERSION} /root/.terraform.d/plugins/

ENTRYPOINT [ "docker-entrypoint.sh" ]
