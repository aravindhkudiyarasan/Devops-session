FROM centos:7
LABEL Author=AravindhK
USER root:root
EXPOSE 8080
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
RUN yum -y install java-1.8.0-openjdk-devel
RUN curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | tee /etc/yum.repos.d/jenkins.repo
WORKDIR /DG/activeRelease/jenkins
COPY init_d_jenkins /etc/init.d/jenkins
COPY etc_sysconfig_jenkins /etc/sysconfig/jenkins
COPY iptables /etc/sysconfig/iptables
COPY etc_bashrc /etc/bashrc
COPY jenkins.service /etc/systemd/system/multi-user.target.wants/jenkins.service
RUN rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
RUN yum -y install iptables-services && yum install net-tools -y && yum install epel-release -y && yum install ansible -y
RUN yum -y install mlocate && yum -y install vim && yum -y install iproute && yum install -y initscripts
RUN yum -y install jenkins
RUN systemctl enable iptables
COPY base_volume/lib /DG/activeRelease/lib
COPY base_volume/bin /DG/activeRelease/bin
COPY base_volume/Tools /DG/activeRelease/Tools
COPY base_volume/F5 /DG/activeRelease/F5
COPY volume/ /DG/activeRelease/jenkins/
COPY workspace/ /DG/activeRelease/jenkins/workspace/
RUN yum install -y python3 && yum install -y nc && yum install -y openssh-server openssh-clients
RUN yum install sudo -y && useradd -m autoinstall && groupadd kodiakgroup && usermod -aG kodiakgroup autoinstall
RUN systemctl enable sshd
RUN mkdir /root/.ssh/ && mkdir /home/autoinstall/.ssh
COPY ssh_keys/.ssh_root /root/.ssh
COPY ssh_keys/.ssh_autoinstall /home/autoinstall/.ssh
RUN rm -rf /run/nologin
RUN chmod 765 /etc/init.d/jenkins && chmod 765 /etc/bashrc && chmod 765 /etc/sysconfig/jenkins && chmod 765 /etc/sysconfig/iptables
RUN echo 'autoinstall:kodiak' | chpasswd
CMD ["/usr/sbin/init"]
