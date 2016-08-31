

# - > Permet d'inserer un saut de ligne dans le log
br ()
{
	# - > Ce test permet de ne pas rajouter des br
	# - > Lorsque le fichier log n'est pas encore cree
	if (test -z "${VAR_LOG_NAME}"); then VAR_LOG_NAME=/dev/null; fi;

	if (! test -z "${1}")
	then
		echo " " >> "${1}";
	else
		echo " " >> "${VAR_LOG_NAME}";
	fi
}

# - > Suppression des espaces des sauts de ligne en sur-nombre dans le log.
#@ARG(1 FICHIER)

clean_espace_fichier ()
{
	return 0
	if (! test -z ${1})
	then
		# init
		supprime_element "${VAR_CHROOT_SESSION}/tmp_log"
		# fin init

		outils_bck test_lecture ${1}
		if [ ${?} == 0 ]
		then
			${CHROOT_BIN_CAT} "${1}" | ${CHROOT_BIN_SED} '/^$/d' >> "${VAR_CHROOT_SESSION}/tmp_log"
			${CHROOT_BIN_CAT} "${1}" | ${CHROOT_BIN_SED} 's/ *$//' >> "${VAR_CHROOT_SESSION}/tmp_log"
			if [ ${?} == 0 ]
			then
				status_return=2
			else
				status_return=1
			fi

			deplacement_fichier_log "${VAR_CHROOT_SESSION}/tmp_log" ${1} 1>/dev/null
			return_=${?};

			echo "deplacement_fichier_log ${VAR_CHROOT_SESSION}/tmp_log ${1}"

			return ${return_}

		else
			status  1 "FALSE clean_espace_fichier pour < ${1} >";
			return 1
		fi
	else
		status 1 "fct 'clean_espace_fichier' Parametre Manquant P1(${1})"
		return 1
	fi
}

tolower()
{
	local char="$*"

	out=$(echo $char | tr [:upper:] [:lower:])
	local retval=$?
	echo $out
	unset out
	unset char
}

#if_empty ()
#{
#	check_variable="${1}"
#	i=0;
#	while [ $i -lt ${#check_variable[*]} ];
#	do
#		var_check="${check_variable[${i}]}";
#
#
#		if [ -z "${!var_check}" ]
#		then
#			status 3 "Attention !! La variable < ${!var_check} $var_check > doit être renseigne !!";
#			return 1
#		fi
#		let i++
#	done
#	return 0
#}

if_empty ()
{
	check_variable="${1}"
	if [ -z "${!check_variable}" ] || [ "${check_variable}" == '' ]
	then
		status 1 "Le contenu de < ${!check_variable} $check_variable > est vide !!";
		return 1
	fi
	return 0
}

ntpbck ()
{
	if [ ! -z "${1}" ]
	then
		CHROOT_ntpdate=`which ntpdate`
		if [ ${?} != 0 ]
		then
			status 1 "NTP -- le binaire < ntpdate > doit être installe (http://www.ntp.org/)"
			return 1
		fi
		${CHROOT_ntpdate} "${1}";
		return ${?}
	fi
}

conversion_temps ()
{
	! test -z "${1}" || echo "fct 'conversion_temps' Parametre Manquant  P1(${1})"
	MICROTIME_END="${1}"
	unite_temps="secondes";

	if [ ${MICROTIME_END} -gt 60 ]
	then
		MICROTIME_END=$((MICROTIME_END / 60 ));
		unite_temps="minutes";
		if [ ${MICROTIME_END} -gt 60 ]
		then
			MICROTIME_END=$((MICROTIME_END / 60 ));
			unite_temps="heures";
		fi
	fi
}

check_check_hdd ()
{
	for check_hdd in `${CHROOT_BIN_DF} -aPh "${1}" | grep "^/" | grep \% | sort | ${CHROOT_BIN_AWK} '{print $1";"$2";"$3";"$4";"$5";"$6}'`;
	do

	hdd=`echo "${check_hdd}" | ${CHROOT_BIN_AWK} -F ';' '{print$1}' | cut -d % -f 1`
	hdd_size_total=`echo "${check_hdd}" | ${CHROOT_BIN_AWK} -F ';' '{print$2}' | cut -d % -f 1`
	hdd_size_used=`echo "${check_hdd}" | ${CHROOT_BIN_AWK} -F ';' '{print$3}' | cut -d % -f 1`
	hdd_size_free=`echo "${check_hdd}" | ${CHROOT_BIN_AWK} -F ';' '{print$4}' | cut -d % -f 1`
	hdd_size_prcent_used=`echo "${check_hdd}" | ${CHROOT_BIN_AWK} -F ';' '{print$5}' | cut -d % -f 1`
	hdd_size_prcent_free=$((100-${hdd_size_prcent_used}));

	if (! test -z "${4}")
	then
		status 4 " < ${hdd} > (${1}) - ${hdd_size_total} -";
		echo "Espace utilise : ${hdd_size_used} (${hdd_size_prcent_used}%)"
		echo "Espace libre : ${hdd_size_free} (${hdd_size_prcent_free}%)"
		br
	fi

	if (! test -z "${2}")
	then
		hdd_need_prct="${2}";

		if [ "${hdd_need_prct}" -ge 100 ];then hdd_need_prct=100; fi

		if [ ${hdd_size_prcent_free} -lt ${hdd_need_prct} ]
		then
#			case ${3} in
#				DIE)
#					status_exit=2;
#					;;
#				NOTICE)
#					status_exit=1;
#					;;
#				esac
			status 4 "ALERTE !! L'espace disque est manquant sur la partion < ${1} > car il ne reste que < ${hdd_size_free} (${hdd_size_prcent_free}%) de libre>"
			status 1 "L'alerte se declenche si l'espace disque sur la partition < ${1} > est inferieur a < ${hdd_need_prct}% >"
			return 1;
		else
			status 0 "L'espace disque sur < ${1} > est superieur a ${2}%";
			return 0;
		fi
	fi
done
}

#debug_Print_r ()
#{
#	i_debug_Print_r=0
#	
#	debug_array="${1}"
#	echo ${#debug_array[*]}
#	while [ $i_debug_Print_r -lt ${#debug_array[*]} ];
#	do
#		echo " ${i_debug_Print_r} // ${debug_array[${i_debug_Print_r}]}";
#		let i_debug_Print_r++
#	done
#}
