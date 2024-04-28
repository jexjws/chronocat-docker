rm /tmp/.X1-lock
export DISPLAY=:1.0
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
/usr/bin/supervisord -n