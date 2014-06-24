#!/sbin/sh
mkdir /tmp/out

# Unloki boot.img
if [ -e /tmp/boot.img ]; then
	mv /tmp/boot.img /tmp/boot.lok
	/tmp/loki_tool unlok /tmp/boot.lok /tmp/boot.img
	rm -rf /tmp/boot.lok
else
	echo "[PanelSwap] Dump boot.img failed!" | tee /dev/kmsg
	exit 1
fi

# Unpack boot.img
if [ -e /tmp/boot.img ]; then
	/tmp/unpackbootimg -i /tmp/boot.img -o /tmp/out
	rm -rf /tmp/boot.img
else
	echo "[PanelSwap] unlok boot.img failed!" | tee /dev/kmsg
	exit 1
fi

# Check ramdisk compression
if [ -e /tmp/out/boot.img-ramdisk.gz ]; then
	rdcomp=/tmp/out/boot.img-ramdisk.gz
	echo "[PanelSwap] New ramdisk uses GZ compression." | tee /dev/kmsg
elif [ -e /tmp/out/boot.img-ramdisk.lz4 ]; then
	rdcomp=/tmp/out/boot.img-ramdisk.lz4
	echo "[PanelSwap] New ramdisk uses LZ4 compression." | tee /dev/kmsg
else
	echo "[PanelSwap] Unknown ramdisk format!" | tee /dev/kmsg
	exit 1
fi

# Make sure kernel is KK based
panelincmd=$(grep -c "mdss_mdp.panel" /tmp/out/boot.img-cmdline)
if [ $panelincmd == 0 ]; then
	echo "[PanelSwap] Kernel is NOT KK based" | tee /dev/kmsg
	exit 1
else
	echo "[PanelSwap] KK Kernel found!" | tee /dev/kmsg
fi

# Detect and swap panel cmdline
panelvar=$(grep -c "lgd" /tmp/out/boot.img-cmdline)
if [ $panelvar == 1 ]; then
	echo "[PanelSwap] LGD cmdline found, switching to JDI" | tee /dev/kmsg
	sed -i 's/lgd/jdi/g' /tmp/out/boot.img-cmdline
elif [ $panelvar == 0 ]; then
	echo "[PanelSwap] JDI cmdline found, switching to LGD" | tee /dev/kmsg
	sed -i 's/jdi/lgd/g' /tmp/out/boot.img-cmdline
fi

# Make new boot.img
/tmp/mkbootimg --kernel /tmp/out/boot.img-zImage --ramdisk $rdcomp --cmdline "$(cat /tmp/out/boot.img-cmdline)" --base $(cat /tmp/out/boot.img-base) --pagesize $(cat /tmp/out/boot.img-pagesize) --ramdisk_offset $(cat /tmp/out/boot.img-ramdisk_offset) --tags_offset $(cat /tmp/out/boot.img-tags_offset) --dt /tmp/out/boot.img-dt --output /tmp/boot.img
if [ -e /tmp/boot.img ]; then
	echo "[PanelSwap] Boot.img created successfully!" | tee /dev/kmsg
else
	echo "[PanelSwap] Boot.img failed to create!" | tee /dev/kmsg
	exit 1
fi

# Loki and flash new boot.img
dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=/tmp/aboot.img
/tmp/loki_tool patch boot /tmp/aboot.img /tmp/boot.img /tmp/boot.lok || exit 1
/tmp/loki_tool flash boot /tmp/boot.lok || exit 1
exit 0
