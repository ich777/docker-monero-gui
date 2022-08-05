# Monero-GUI in Docker optimized for Unraid
Monero-GUI is a Dockerized GUI Monero Wallet.

**ATTENTION:** By default your wallet is saved in ../Monero/wallet (please don't store your Wallet in the .../bin directory since it get's deleted after a update is released)
I strongly recommend you to backup your keyfile on a regular basis!

**NOTE:** If you minimize the window by accident you have to restart the container to see the GUI again.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Please keep in mind that your wallet is stored there and I strongly recommend you to backup that path (ATTENTION: By default your wallet is saved in ../Monero/wallet - please don't store your Wallet in the .../bin directory since it get's deleted after a update is released). | /monero |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |

## Run example
```
docker run --name Monero-GUI -d \
	-p 8080:8080 \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--env 'TURBOVNC_PARAMS=-securitytypes none' \
	--volume /path/to/monero-gui:/monero \
	--restart=unless-stopped \
	ich777/monero-gui
```
### Webgui address: http://[IP]:[PORT:8080]/vnc.html?autoconnect=true

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/
