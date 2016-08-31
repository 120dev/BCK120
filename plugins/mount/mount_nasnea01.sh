#!/bin/bash
# 15/09/2009
# Candir Vincent
# Permet de monter les ressources réseaux nécessaires
# refait le 05/02/2009
# v0.4

# Si lancement manuel, renseignez les variables ci-dessous (VAR_BCK_CHROOT) 
if [ -z "${VAR_BCK_CHROOT}" ]; then VAR_BCK_CHROOT="/etc/init.d/bck120"; fi;
if [ -z "${MOUNT_SHARE_SCRIPT}" ]; then MOUNT_SHARE_SCRIPT="${VAR_BCK_CHROOT}/plugins/mount/mount_nasnea01.sh"; fi;

source "${VAR_BCK_CHROOT}/init/init_mount.sh" || exit 1;

# --- IDENTIFICATION  --------------------------- #
IDENT_nasnea01="/root/ident_nasnea01";
IDENT_srvbackup="/root/ident_srvbackup.txt";
# ----------------------------------------------  #
# Demonter puis remonter les partages ?
umount_before="TRUE"
debug_mount="TRUE";
srvbackup="srvbackup.sofinor.intra";
srv_nasnea01="nas-sofnea-01.sofinor.intra";

case "${1}" in
	umount)
		status 4 'On demonte les partages :'; br
		auto_umount "${srv_nasnea01}/bck120" "/BCK120-nasnea01"
		auto_umount "${srvbackup}/BCK_SOFINOR" "/BCK120-SRVBCK_pour_nas"
	;;
	*)
		if [ ${umount_before} == "TRUE" ]; then ${MOUNT_SHARE_SCRIPT} umount; fi

		status 4 'On monte les partages :'; br
		auto_mount_univ "${srv_nasnea01}" "/bck120" "/BCK120-nasnea01" "${IDENT_nasnea01}"
		auto_mount_univ "${srvbackup}" "/BCK_SOFINOR" "/BCK120-SRVBCK_pour_nas" "${IDENT_srvbackup}"
	;;
esac

#fin
if [ ${error_OP_MOUNT} -eq 0 ]; then supprime_element "${fichier_log}"; fi;
source "${VAR_BCK_CHROOT}/init/init_mount_end.sh"