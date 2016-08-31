#!/bin/bash
# 15/09/2009
# Candir Vincent
# Permet de monter les ressources réseaux nécessaires
# refait le 05/02/2009
# v0.4

# Si lancement manuel, renseignez les variables ci-dessous (VAR_BCK_CHROOT) 
if [ -z "${VAR_BCK_CHROOT}" ]; then VAR_BCK_CHROOT="/etc/init.d/bck120"; fi;
if [ -z "${MOUNT_SHARE_SCRIPT}" ]; then MOUNT_SHARE_SCRIPT="${VAR_BCK_CHROOT}/plugins/mount/mount_noumea.sh"; fi;

source "${VAR_BCK_CHROOT}/init/init_mount.sh" || exit 1;

# --- IDENTIFICATION  --------------------------- #
IDENT_srvbackup="/etc/rc.d/init.d/bck120/RESSOURCES/ident_srvbackup";
# ----------------------------------------------  #
# Demonter puis remonter les partages ?
umount_before="TRUE"
debug_mount="FALSE";

srvbackup="srvbackup.sofinor.intra";
ged="ged.sofinor.intra";
srvapp="srvapp.sofinor.intra";
srvsql2003="srvsql2003.sofinor.intra";
tse01="tse01.sofinor.intra";
tse02="tse02.sofinor.intra";
tse03="tse03.sofinor.intra"; 

case "${1}" in
	umount)
		status 4 'On demonte les partages :'; br
		auto_umount "${srvbackup}/BCK_SOFINOR" "/BCK120-NOUMEA"
		auto_umount "${ged}/sofinor$" "/home/dossier_bck/${ged}/sofinor"
		auto_umount "${ged}/Utilisateurs$" "/home/dossier_bck/${ged}/Utilisateurs"
		auto_umount "${srvsql2003}/DB_SAV_BCKEXEC$/SRVSQL2003/MSSQLSERVER" "/home/dossier_bck/${srvsql2003}/DB_SAV_BCKEXEC"
	;;
	*)
		if [ ${umount_before} == "TRUE" ]; then ${MOUNT_SHARE_SCRIPT} umount; fi
		echo
		status 4 'On monte les partages :'; br
		auto_mount_univ "${srvbackup}" "/BCK_SOFINOR" "/BCK120-NOUMEA" "${IDENT_srvbackup}"
		#auto_mount_univ "172.22.10.50" "/www" "/home/dossier_bck/srvweb" "${IDENT_srv_50}"

		auto_mount_univ "${ged}" "/sofinor$" "/home/dossier_bck/${ged}/sofinor" "${IDENT_srvbackup}"
		auto_mount_univ "${ged}" "/Utilisateurs$" "/home/dossier_bck/${ged}/Utilisateurs" "${IDENT_srvbackup}"
		auto_mount_univ "${srvsql2003}" "/DB_SAV_BCKEXEC$/SRVSQL2003/MSSQLSERVER" "/home/dossier_bck/${srvsql2003}/DB_SAV_BCKEXEC" "${IDENT_srvbackup}"
	;;
esac

#fin
if [ ${error_OP_MOUNT} -eq 0 ]; then supprime_element "${fichier_log}"; fi;
source "${VAR_BCK_CHROOT}/init/init_mount_end.sh"
