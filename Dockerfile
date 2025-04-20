# 再去 https://github.com/chrononeko/chronocat/releases
# 下载 Chronocat 本体以及你需要的引擎 的 zip包 放到LiteLoaderPlugins目录下。

# 使用Ubuntu 22.04
FROM ubuntu:22.04 as builder

# 设置环境变量
ARG DEBIAN_FRONTEND=noninteractive
ENV VNC_PASSWD=vncpasswd
ENV QQ_deb_Link=https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.16_250401_amd64_01.deb
# 安装必要的软件包
RUN apt-get update && apt-get install -y \
    openbox \
    curl \
    unzip \
    x11vnc \
    xvfb \
    fluxbox \
    supervisor \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    libgbm1 \
    libasound2 \
    fonts-wqy-zenhei \
    git \
    gnutls-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 复制项目文件夹 安装：novnc和websockify
COPY noVNC /opt/noVNC
COPY websockify /opt/noVNC/utils/websockify
RUN cp /opt/noVNC/vnc.html /opt/noVNC/index.html\
    && mkdir -p ~/.vnc \
    && touch ~/.vnc/passwd

# 下载 安装：Linux QQ
RUN curl -o /root/linuxqq_amd64.deb $QQ_deb_Link\
    && dpkg -i /root/linuxqq_amd64.deb && apt-get -f install -y && rm /root/linuxqq_amd64.deb

RUN useradd -m monokai \
    && chown -R monokai:monokai /home/monokai 

RUN apt-get update &&  apt-get install -y sudo  && echo "monokai ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/monokai
# 下载 安装：LiteLoader https://github.com/Mzdyl/LiteLoaderQQNT_Install
RUN curl -L "https://github.com/Mzdyl/LiteLoaderQQNT_Install/raw/main/install.sh" -o /tmp/LiteLoaderQQNT_Install.sh \
    && chmod +x /tmp/LiteLoaderQQNT_Install.sh \
    && su monokai -c "/tmp/LiteLoaderQQNT_Install.sh" \
    && rm /tmp/LiteLoaderQQNT_Install.sh


# 复制zip包 安装：chronocat
COPY LiteLoaderPlugins/* /tmp/meow/
RUN mkdir -p /home/monokai/.local/share/LiteLoaderQQNT/plugins \
  && find /tmp/meow/ -name '*.zip' -exec unzip -o -d /home/monokai/.local/share/LiteLoaderQQNT/plugins {} \; \
  && rm -r /tmp/meow/


# 创建 supervisor配置、start.sh
COPY utils/super.conf /root/
COPY utils/start.sh /root/
RUN cat /root/super.conf >> /etc/supervisor/supervisord.conf \
  && chmod +x /root/start.sh \
  && rm /root/super.conf \
  && mkdir /root/logs

# 暴露 VNC 端口
EXPOSE 5900

# 可以通过在命令行上传递 -n 标志来在前台启动supervisord可执行文件。这对于调试启动问题很有用。
#CMD ["/bin/bash"]
CMD ["/bin/bash", "-c", "/root/start.sh"]
