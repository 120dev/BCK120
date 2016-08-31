#!/bin/bash
# RE FAIT LE 25/02/2008 && 15/06/2008 && 27/08/2008 && 05/02/2008
####################################################################################################


nettoyage_montage ()
{
	! test -z "${1}" && ! test -z "${2}" || echo "fct 'nettoyage_montage' Parametre Manquant  P1(${1}) P2(${2})"
	#echo "${CHROOT_BIN_MOUNT} | grep -w \"${1} on ${2} type cifs\" |wc -l"
	return_count=`${CHROOT_BIN_MOUNT} | grep -w "${1} on ${2} type cifs" |wc -l`
	
	if [ ${return_count} -gt 1 ] || [ "${3}" == 'TRUE' ]
	then
		if [ ${return_count} -gt 1 ]
		then
			status 4 "Suppression des montages identiques";
		fi
		
		i=0
		while [ 1 ] # Boucle sans fin
		do
		#	echo "check_si_mount 1 ${1} -- 2 ${2} && auto_umount ${1}"
			check_si_mount "${1}" "${2}" && auto_umount "${1}" "${2}" || return 1
			let i++
		done
	fi
	return ${?}
}

check_si_mount ()
{
	#echo "fct 'check_si_mount' P1(${1}) P2(${2})"
	! test -z "${1}" || echo "fct 'check_si_mount' Parametre Manquant  P1(${1})"
	
	if (test -z "${2}")
	then
		#echo "${CHROOT_BIN_MOUNT} | grep -w ${1}"
		${CHROOT_BIN_MOUNT} | grep -w "${1}" 1>/dev/null
	else
		#echo "${CHROOT_BIN_MOUNT} | grep -w ${1} on ${2}"
		${CHROOT_BIN_MOUNT} | grep -w "${1} on ${2}" 1>/dev/null
	fi
	return_check_si_mount=$?
	#echo "return_check_si_mount == $return_check_si_mount"

	return ${return_check_si_mount}
}
# - > Permet de demonter un partage reseau
#@ARG P1(source)

auto_umount ()
{
	! test -z "${1}" && ! test -z "${2}" || echo "fct 'auto_umount' Parametre Manquant  P1(${1}) P2(${2})"
	check_si_mount "${1}" "${2}"
	if [ ${?} != 1 ]
	then
		${CHROOT_BIN_UMOUNT} -l "${2}" &>/dev/null
		return_mount=$?
		status $return_mount "De-montage de < ${2} >"
		return $return_mount
	else
		status 4 "Le dossier < ${2} >, n'est pas monte !!"
	fi
}

ping_shell ()
{
	path_ping=`which ping`
	${path_ping} -c 1 "${1}" &>/dev/null
	return $?
}


check_host ()
{
	ping_shell "${1}"
	if [ "${?}" != 0 ]
	then
		status 1 "Hote injoignable < ${1} > !!"
		echo "${3}" >> "${fichier_log}";
		nettoyage_montage "${2}" "${3}" "TRUE"
		return 1
	fi
	return 0
}

# -------------------------------------------------
auto_mount_univ ()
{
	! test -z "${1}" && ! test -z "${2}" || echo "fct 'auto_mount' Parametre Manquant  P1(${1}) P2(${2})"
	
	mount_HOST="${1}"
	mount_SOURCE="//${1}${2}"
	mount_DEST="${3}"
	mount_IDENT="${4}"
	mount_TYPE_AUTH="${5}"
	
	creation_dossier "${mount_DEST}" || return 1
	if ( ! check_host "${mount_HOST}" "${mount_SOURCE}" "${mount_DEST}" )
	then
		let error_OP_MOUNT++
	else
	
		check_si_mount "${mount_SOURCE}" "${mount_DEST}" && status 2 "Le lecteur < ${mount_SOURCE} > est deja monte dans < ${mount_DEST} >" && return 1
		outils_bck "test_lecture" "${mount_DEST}" || exit;
		${CHROOT_BIN_MOUNT} -t cifs -o credentials="${mount_IDENT}" "${mount_SOURCE}" "${mount_DEST}"
	
		if [ ${?} != 0 ]
		then
			status 1 "Probleme de montage < ${mount_SOURCE} > dans < ${mount_DEST} >";
			echo "${mount_DEST}" >> "${fichier_log}"
	
			status 4 "Vous pouvez tester la configuration avec la commande suivante : "
			status 4 "${CHROOT_BIN_MOUNT} -t cifs -o credentials=${mount_IDENT} ${mount_SOURCE} ${mount_DEST}";
			let error_OP_MOUNT++
			return 1
		else
			sleep 1
			check_si_mount "${mount_SOURCE}" "${mount_DEST}"
			return_check=${?};
	
			if [ ${return_check} != 0 ]
			then
				echo "${mount_DEST}" >> "${fichier_log}"
				let error_OP_MOUNT++
			fi
			status ${return_check} "Montage de < ${mount_SOURCE} > dans < ${mount_DEST} >"
	 	fi
	 fi
}
