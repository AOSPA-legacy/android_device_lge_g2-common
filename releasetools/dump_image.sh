#!/system/bin/sh
function usage {
	echo "[-] Usage: ./dump_image.sh <build> <partition> <output_dir>" | tee /dev/kmsg
	exit 1
}

buildflag=0
partflag=0

if [ "$1" = "qcom" ]; then
	buildflag=1
else
	usage
fi

if [ $buildflag == 1 ]; then
	dd if=/dev/block/platform/msm_sdcc.1/by-name/"$2" of="$3"/"$2".img || partflag=1
	if [ -e "$3"/"$2".img ]; then
		echo "[+] Output: $3/$2.img" | tee /dev/kmsg
	else
		echo "[-] Output: failed!" | tee /dev/kmsg
	fi
fi

if [ $partflag == 1 ]; then
	usage
fi
