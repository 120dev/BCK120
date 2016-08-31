if [ `whoami` != 'root' ]; then echo "Uniquement root peut faire ça !!"; exit; fi;

# --- init -------------------- #
if [ -z "${MOUNT_SHARE_BCK120}" ]
then
	fichier_function="${VAR_BCK_CHROOT}/lib-bash/function.sh"
	if [ -f "${fichier_function}" ]; then source "${fichier_function}"; else echo "Probleme de chargement du fichier '${fichier_function}'"; exit 1; fi;
	
	fichier_log="${VAR_BCK_CHROOT}/mount_error.log"
	SHOW_PASSWORD_LOG_MOUNT="FALSE";
else
	# VAR_CHROOT_SESSION vient du fichier init du backup
	fichier_log="${VAR_CHROOT_SESSION}/mount_error.log"
fi
supprime_element "${fichier_log}" &>/dev/null
export error_OP_MOUNT=0
# --- fin init -------------------- #