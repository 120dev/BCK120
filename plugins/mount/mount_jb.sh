#!/bin/bash
# 15/09/2009
# Candir Vincent
# Permet de monter les ressources réseaux nécessaires
# refait le 05/02/2009
# v0.4

# Si lancement manuel, renseignez les variables ci-dessous (VAR_BCK_CHROOT) 
if [ -z "${VAR_BCK_CHROOT}" ]; then VAR_BCK_CHROOT="/etc/init.d/bck120"; fi;
if [ -z "${MOUNT_SHARE_SCRIPT}" ]; then MOUNT_SHARE_SCRIPT="${VAR_BCK_CHROOT}/plugins/mount/mount_jb.sh"; fi;

source "${VAR_BCK_CHROOT}/init/init_mount.sh" || exit 1;

# --- IDENTIFICATION  --------------------------- #
IDENT_srvbackup="/root/ident_srvbackup.txt";
IDENT_srv_ident_login_bck120="/root/ident_login_bck120";
IDENT_srv_kone="/root/ident_srv_kone.txt";
IDENT_vincent="/root/ident_vincent.txt";
# ----------------------------------------------  #
# Demonter puis remonter les partages ?
umount_before="TRUE"
debug_mount="FALSE";
srv_bck="srvbackup.sofinor.intra";
srv_ged="ged.sofinor.intra";
srv_app="srvapp.sofinor.intra";


case "${1}" in
	umount)
		status 4 'On demonte les partages :'; br
		auto_umount "${srv_bck}/BCK_SOFINOR" "/BCK120-JB"
	;;
	*)
		if [ ${umount_before} == "TRUE" ]; then ${MOUNT_SHARE_SCRIPT} umount; fi

		status 4 'On monte les partages :'; br
		auto_mount_univ "${srv_bck}" "/BCK_SOFINOR" "/BCK120-JB" "${IDENT_srv_ident_login_bck120}"

	;;
esac



#fin
if [ ${error_OP_MOUNT} -eq 0 ]; then supprime_element "${fichier_log}"; fi;
source "${VAR_BCK_CHROOT}/init/init_mount_end.sh"