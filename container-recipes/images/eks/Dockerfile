FROM alpine:latest

WORKDIR root

RUN apk add --update --no-cache curl groff py3-pip

# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
RUN pip3 install --no-cache-dir awscli

# https://kubernetes.io/docs/tasks/tools/install-kubectl/
RUN curl -#LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# https://eksctl.io/introduction/installation/
RUN curl -#L "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar -xz

RUN chmod +x kubectl eksctl && mv kubectl eksctl /usr/local/bin
RUN rm -rf .* * 2> /dev/null || true

ADD .shrc .shrc
ENV ENV=.shrc
