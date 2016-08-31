#!/bin/bash
# 15/09/2009
# Candir Vincent
# Permet de monter les ressources réseaux nécessaires
# refait le 05/02/2009
# v0.4
# Si lancement manuel, renseignez les variables ci-dessous (VAR_BCK_CHROOT) 
if [ -z "${VAR_BCK_CHROOT}" ]; then VAR_BCK_CHROOT="/etc/init.d/bck120"; fi;
if [ -z "${MOUNT_SHARE_SCRIPT}" ]; then MOUNT_SHARE_SCRIPT="${VAR_BCK_CHROOT}/plugins/mount/mount_nas.sh"; fi;

source "${VAR_BCK_CHROOT}/init/init_mount.sh" || exit 1;
if [ -z "${1}" ]; then echo "DIE !! Vous devez specifier un hotel en parametre"; exit 1; fi;

# --- IDENTIFICATION  --------------------------- #
IDENT_share="/etc/rc.d/init.d/bck120/RESSOURCES/ident_share";
IDENT_AD="/etc/rc.d/init.d/bck120/RESSOURCES/ident_srvbackup";
# ----------------------------------------------  #
umount_before="FALSE"
debug_mount="FALSE";

restauration="restauration.sofinor.intra";

case "${1}" in

	surf) id=10; ;;
	beaurivage) id=20; ;;
	koniambo) id=30; ;;
	koulnoue) id=40; ;;
	malabou) id=50; ip="qnapmalabou.sofinor.intra";  ;; # cit-mal-01.sofinor.intra
	lanea) id=60; ;;
	*) echo "DIE !! l'hotel specifie en parametre < ${1} > n'existe pas"; exit 1; ;;

esac		

echo "

--------------------------------------
Montage des partages pour < ${1} >
--------------------------------------
";
echo "---- SOURCE ----"
auto_umount "${restauration}/archivage/Document/${id}/" "/home/dossier_bck/syncroNas/src_${1}"
auto_mount_univ "${restauration}" "/archivage/Document/${id}/" "/home/dossier_bck/syncroNas/src_${1}" "${IDENT_AD}"
echo
echo "---- DESTINATION ----"
auto_umount "${ip}/data-${1}/archivage_amadeus" "/home/dossier_bck/syncroNas/dest_${1}"
auto_mount_univ "${ip}" "/data-${1}/archivage_amadeus" "/home/dossier_bck/syncroNas/dest_${1}" "${IDENT_share}"

echo
#fin
if [ ${error_OP_MOUNT} -eq 0 ]; then supprime_element "${fichier_log}"; fi;
source "${VAR_BCK_CHROOT}/init/init_mount_end.sh"