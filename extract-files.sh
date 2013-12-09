#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE=galaxys4
COMMON=c1-common
MANUFACTURER=samsung

if [[ -z "${ANDROIDFS_DIR}" && -d ../../../backup-${DEVICE}/system ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    echo Pulling files from device
    DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
else
    echo Pulling files from ${ANDROIDFS_DIR}
    DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
fi

case "$DEVICE_BUILD_ID" in
"JDQ39.I545VRUAME7")
  FIRMWARE=ME7 ;;
*)
  echo Your device has unknown firmware $DEVICE_BUILD_ID >&2
  echo >&2
  echo Supported firmware: >&2
  echo JDQ39.I545VRUAME7 >&2
  exit 1 ;;
esac

if [[ ! -d ../../../backup-${DEVICE}/system  && -z "${ANDROIDFS_DIR}" ]]; then
    echo Backing up system partition to backup-${DEVICE}
    mkdir -p ../../../backup-${DEVICE} &&
    adb pull /system ../../../backup-${DEVICE}/system
fi

BASE_PROPRIETARY_COMMON_DIR=vendor/$MANUFACTURER/$COMMON/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_COMMON_DIR=../../../$BASE_PROPRIETARY_COMMON_DIR

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio cameradata egl firmware hw keychars wifi media
do
    mkdir -p $PROPRIETARY_COMMON_DIR/$NAME
done

# galaxys2


# c1-common
(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \\

# All the blobs necessary for galaxys2 devices
PRODUCT_COPY_FILES += \\

EOF

COMMON_BLOBS_LIST=../../../vendor/$MANUFACTURER/$COMMON/c1-vendor-blobs.mk

(cat << EOF) | sed s/__COMMON__/$COMMON/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > $COMMON_BLOBS_LIST
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := device/sample/etc/apns-full-conf.xml:system/etc/apns-conf.xml

# All the blobs necessary for galaxys2 devices
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src name
# $2 = dst name
# $3 = directory path on device
# $4 = directory name in $PROPRIETARY_COMMON_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        adb pull /$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    else
           # Hint: Uncomment the next line to populate a fresh ANDROIDFS_DIR
           #       (TODO: Make this a command-line option or something.)
           # adb pull /$3/$1 ${ANDROIDFS_DIR}/$3/$1
        cp ${ANDROIDFS_DIR}/$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    fi

    if [[ -f $PROPRIETARY_COMMON_DIR/$4/$2 ]]; then
        echo   $BASE_PROPRIETARY_COMMON_DIR/$4/$2:$3/$2 \\ >> $COMMON_BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_COMMON_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$NAME" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $COMMON_BLOBS_LIST
    done
}

COMMON_LIBS="
	libaudiopolicy_sec.so
	libchromatix_imx074_default_video.so
	libchromatix_imx074_preview.so
	libchromatix_imx074_video_hd.so
	libchromatix_imx074_zsl.so
	libchromatix_imx091_default_video.so
	libchromatix_imx091_preview.so
	libchromatix_imx091_video_hd.so
	libchromatix_mt9e013_default_video.so
	libchromatix_mt9e013_preview.so
	libchromatix_mt9e013_video_hfr.so
	libchromatix_ov2720_default_video.so
	libchromatix_ov2720_hfr.so
	libchromatix_ov2720_preview.so
	libchromatix_ov2720_zsl.so
	libchromatix_ov5647_default_video.so
	libchromatix_ov5647_preview.so
	libchromatix_ov8825_default_video.so
	libchromatix_ov8825_preview.so
	libchromatix_ov9726_default_video.so
	libchromatix_ov9726_preview.so
	libchromatix_s5k3l1yx_default_video.so
	libchromatix_s5k3l1yx_hfr_120fps.so
	libchromatix_s5k3l1yx_hfr_60fps.so
	libchromatix_s5k3l1yx_hfr_90fps.so
	libchromatix_s5k3l1yx_preview.so
	libchromatix_s5k3l1yx_video_hd.so
	libchromatix_s5k3l1yx_zsl.so
	libchromatix_s5k4e1_default_video.so
	libchromatix_s5k4e1_preview.so
	libchromatix_s5k6b2yx_pip.so
	libchromatix_s5k6b2yx_preview.so
	libchromatix_s5k6b2yx_smartstay.so
	libchromatix_s5k6b2yx_video.so
	libchromatix_s5k6b2yx_vt.so
	libchromatix_s5k6b2yx_vt_hd.so
	libgemini.so
	libimage-jpeg-enc-omx-comp.so
	libimage-omx-common.so
	libmercury.so
	libmmcamera_faceproc.so
	libmmcamera_frameproc.so
	libmmcamera_hdr_lib.so
	libmmcamera_image_stab.so
	libmmcamera_imx091.so
	libmmcamera_interface.so
	libmmcamera_interface2.so
	libmmcamera_plugin.so
	libmmcamera_statsproc31.so
	libmmcamera_wavelet_lib.so
	libmmjpeg.so
	libmmjpeg_interface.so
	libmmmpod.so
	libmmstillomx.so
	liboemcamera.so
	libsecnativefeature.so
	libvdis.so
	libdrmdecrypt.so
	libdrmfs.so
	libdrmtime.so
	libhdcp2.so
	libQSEEComAPI.so
	libWVStreamControlAPI_L1.so
	libwvm.so
	libqc-opt.so
	libsensirion_j1.so
	libsam.so
	libloc_api_v02.so
	libatparser.so
	libcordon.so
	libdiag.so
	libdsutils.so
	libdsi_netctrl.so
	libfactoryutil.so
	libidl.so
	libnetmgr.so
	libomission_avoidance.so
	libqdi.so
	libqdp.so
	libqmi.so
	libqmiservices.so
	libqmi_cci.so
	libqmi_common_so.so
	libqmi_csi.so
	libqmi_encdec.so
	libqcci_legacy.so
	libqmi_client_qmux.so
	libreference-ril.so
	libril-qcril-hook-oem.so
	libril-qc-qmi-1.so
	libril.so
	libsecril-client.so
	libtime_genoff.so
	libmm-color-convertor.so
	libC2D2.so
	libOpenVG.so
	libOpenCL.so
	libsc-a2xx.so
	libsc-a3xx.so
	libllvm-a3xx.so
	libExtendedExtractor.so
	libmmparser.so
	libmmosal.so
	libdivxdrm.so
	libacdbloader.so
	libaudcal.so
	libcsd-client.so
	libalsa-intf.so
	libc2dcolorconvert.so
	libdashplayer.so
	libdivxdrmdecrypt.so
	libexternal.so
	libgenlock.so
	libmemalloc.so
	libmm-omxcore.so
	libOmxAacEnc.so
	libOmxAmrEnc.so
	libOmxCore.so
	libOmxEvrcEnc.so
	libOmxQcelp13Enc.so
	libOmxVdec.so
	libOmxVenc.so
	liboverlay.so
	libqdMetaData.so
	libqdutils.so
	libqservice.so
	libstagefrighthw.so
	"
copy_files "$COMMON_LIBS" "system/lib" ""

COMMON_BINS="
	qseecomd
	ds_fmc_appd
	efsks
	ks
	netmgrd
	sec-ril
	qcks
	qmiproxy
	qmuxd
	rild
	rmt_storage
	mm-qcamera-daemon
	thermald
	thermal-engine
	mpdecision
	mm-vdec-omx-test
	mm-venc-omx-test720p
	mm-video-driver-test
	mm-video-encdrv-test
	"
copy_files "$COMMON_BINS" "system/bin" ""

COMMON_CAMERADATA="
	M10MO_SFW.bin
	RS_M10MO_OL.bin
	RS_M10MO_OS.bin
	RS_M10MO_SL.bin
	RS_M10MO_SS.bin
	datapattern_420sp.yuv
	datapattern_front_420sp.yuv
	"
copy_files "$COMMON_CAMERADATA" "system/cameradata" "cameradata"

COMMON_EGL="
	eglsubAndroid.so
	libGLES_android.so
	libGLESv2S3D_adreno200.so
	libEGL_adreno200.so
	libGLESv1_CM_adreno200.so
	libGLESv2_adreno200.so
	libq3dtools_adreno200.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

COMMON_FIRMWARE="
	a225p5_pm4.fw
	a225_pfp.fw
	a225_pm4.fw
	a300_pfp.fw
	a300_pm4.fw
	leia_pfp_470.fw
	leia_pm4_470.fw
	vidc_1080p.fw
	wcd9310/wcd9310_anc.bin
	wcd9310/wcd9310_mbhc.bin
	"
copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "firmware"

VENDOR_FIRMWARE="
	bcm2079xB4_firmware.ncd
	bcm2079xB4_pre_firmware.ncd
	bcm4335.hcd
	bcm4335_A0.hcd
	bcm4335_murata.hcd
	bcm4335_semco.hcd
	"
copy_files "$VENDOR_FIRMWARE" "vendor/firmware" "vendor/firmware"

COMMON_HW="
	camera.msm8960.so
	sensors.msm8960.so
	sensorhubs.msm8960.so
	audio.primary.msm8960.so
	audio_policy.msm8960.so
	copybit.msm8960.so
	gralloc.msm8960.so
	hwcomposer.msm8960.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_IDC="
	qwerty2.idc
	qwerty.idc
	"
copy_local_files "$COMMON_IDC" "system/usr/idc" "idc"

COMMON_KEYCHARS="
	Generic.kcm
	qwerty.kcm
	qwerty2.kcm
	Virtual.kcm
	"
copy_files "$COMMON_KEYCHARS" "system/usr/keychars" "keychars"

COMMON_WIFI="
	bcmdhd_apsta.bin
	bcmdhd_apsta.bin_a0
	bcmdhd_mfg.bin
	bcmdhd_mfg.bin_a0
	bcmdhd_sta.bin
	bcmdhd_sta.bin_a0
	cred.conf
	nvram_mfg.txt
	nvram_mfg.txt_a0
	nvram_mfg.txt:etc/wifi/nvram_mfg.txt_murata
	nvram_mfg.txt_murata_a0
	nvram_mfg.txt_muratafem1
	nvram_mfg.txt_muratafem2
	nvram_mfg.txt_semco3rd
	nvram_mfg.txt_semco3rd_a0
	nvram_mfg.txt_semcosh
	nvram_net.txt
	nvram_net.txt_a0
	nvram_net.txt:etc/wifi/nvram_net.txt_murata
	nvram_net.txt_murata_a0
	nvram_net.txt_muratafem1
	nvram_net.txt_muratafem2
	nvram_net.txt_semco3rd
	nvram_net.txt_semco3rd_a0
	nvram_net.txt_semcosh
	wpa_supplicant.conf
	"
copy_files "$COMMON_WIFI" "system/etc/wifi" "wifi"

COMMON_AUDIO="
	libsoundalive.so
	libsoundspeed.so
	lib_Samsung_Resampler.so
	"
copy_files "$COMMON_AUDIO" "system/lib" "audio"

COMMON_MEDIA="
	battery_batteryerror.qmg
	battery_charging_45.qmg
	battery_charging_85.qmg
	battery_charging_100.qmg
	battery_charging_50.qmg
	battery_charging_90.qmg
	battery_charging_10.qmg
	battery_charging_55.qmg
	battery_charging_95.qmg
	battery_charging_15.qmg
	battery_charging_5.qmg
	battery_error.qmg
	battery_charging_20.qmg
	battery_charging_60.qmg
	bootsamsungloop.qmg
	battery_charging_25.qmg
	battery_charging_65.qmg
	bootsamsung.qmg
	battery_charging_30.qmg
	battery_charging_70.qmg
	chargingwarning.qmg
	battery_charging_35.qmg
	battery_charging_75.qmg
	Disconnected.qmg
	battery_charging_40.qmg
	battery_charging_80.qmg
"
copy_files "$COMMON_MEDIA" "system/media" "media"

./setup-makefiles.sh
