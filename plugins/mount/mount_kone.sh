#!/bin/bash
# 15/09/2009
# Candir Vincent
# Permet de monter les ressources réseaux nécessaires
# refait le 05/02/2009
# v0.5
# 23/05/2009 Ajout de l'umount universel

# Si lancement manuel, renseigner la variable ci-dessous (VAR_BCK_CHROOT) 
if [ -z "${MOUNT_SHARE_BCK120}" ]; then VAR_BCK_CHROOT="/etc/init.d/bck120"; fi;

VAR_LIB_CHROOT="${VAR_BCK_CHROOT}/lib-bash"; VAR_LIB_INIT="${VAR_BCK_CHROOT}/init"
source "${VAR_BCK_CHROOT}/init/init_mount.sh" || exit 1;

# --- IDENTIFICATION  --------------------------- #
IDENT_srvbackup="/root/ident_srvbackup.txt";
IDENT_srv_kone="/root/ident_srv_kone.txt";
IDENT_srv_ident_login_bck120="/root/ident_login_bck120";
# ----------------------------------------------  #
# Demonter puis remonter les partages ?
umount_before="FALSE"
debug_mount="TRUE";

srv_bck="172.22.10.6";
srv_kone="192.168.21.1";

case "${1}" in
	umount)
		status 4 'On demonte les partages :'; br
		auto_umount "${srv_bck}/BCK_KONE" "/BCK120-KONE"
		auto_umount "${srv_kone}/Techniqu" "/home/dossier_bck/srvkone/Technique"
		auto_umount "${srv_kone}/Directio" "/home/dossier_bck/srvkone/Directio"
		auto_umount "${srv_kone}/Compta" "/home/dossier_bck/srvkone/Compta"
		auto_umount "${srv_kone}/Apps" "/home/dossier_bck/srvkone/Apps"
		auto_umount "${srv_kone}/sysvol" "/home/dossier_bck/srvkone/sysvol"
		auto_umount "${srv_kone}/public" "/home/dossier_bck/srvkone/public"
	;;
	*)
		if [ ${umount_before} == "TRUE" ]
		then
			${VAR_BCK_CHROOT}/mount_share_kone.sh umount
		fi
		status 4 'On monte les partages :'; br
		auto_mount_univ "${srv_bck}" "/BCK_KONE" "/BCK120-KONE" "${IDENT_srv_ident_login_bck120}" 
		auto_mount_univ "${srv_kone}" "/Techniqu" "/home/dossier_bck/srvkone/Technique" "${IDENT_srv_kone}" 

		auto_mount_univ "${srv_kone}" "/Directio" "/home/dossier_bck/srvkone/Directio" "${IDENT_srv_kone}" 
		auto_mount_univ "${srv_kone}" "/Compta" "/home/dossier_bck/srvkone/Compta" "${IDENT_srv_kone}" 

		auto_mount_univ "${srv_kone}" "/Apps" "/home/dossier_bck/srvkone/Apps" "${IDENT_srv_kone}" 
		auto_mount_univ "${srv_kone}" "/sysvol" "/home/dossier_bck/srvkone/sysvol" "${IDENT_srv_kone}" 
		auto_mount_univ "${srv_kone}" "/public" "/home/dossier_bck/srvkone/public" "${IDENT_srv_kone}" 
	;;
esac

if [ ${error_OP} -eq 0 ]; then supprime_element  "${fichier_log}"; fi;
source "${VAR_LIB_INIT}/init_mount_end.sh" 

exit
