rm /tmp/.X1-lock
export DISPLAY=:1.0
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
chown monokai:monokai /home/monokai/.chronocat
/usr/bin/supervisord -n