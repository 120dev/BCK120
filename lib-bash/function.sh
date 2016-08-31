# - > Permet de personnaliser le log en fonction des etats & resultats, du backup
status()
{
	if [ "${1}" != '' ] && [ "${2}" != '' ]
	then

		case "${1}" in
			0)
				echo "[- TRUE -] -- > ${2}"
				let nbr_OP++;
			;;
			1)
				echo "[- FALSE -] -- > ${2}"
				echo '-------------------------------------------------------------------------------'
				let error_OP++;
			;;
			2)
				echo "[- NOTICE -] -- > ${2}"
			;;
			3)
				if [ ! -z "${VAR_LOG_NAME}" ]
				then
					echo "[- DIE -] -- > ${2}" >> "${VAR_LOG_NAME}"
				fi
				echo "[- DIE -] -- > ${2}";
				let error_OP++;
				echo '-------------------------------------------------------------------------------'
				#init_fin_session ${VAR_LOG_NAME_SQL_err} ${VAR_LOG_NAME_SQL} "${VAR_LOG_NAME}"
				showLog "${VAR_LOG_NAME}";
				nettoyage_session && kill -9 $$

			;;
			4)
				echo "[- INFO -] -- > ${2}"
			;;
			5)
				echo "[- DEBUG -] -- > ${2}"
			;;
			6)
				echo "[- DEBUG CMD -] -- > ${2}"
			;;
			7)
				echo "[- FIN ${MODULE} -] -- > ${2}"
			;;
			8)
				echo "[- FIN init ${MODULE} -] -- > ${2}"
			;;
		esac
	else
		status 1 "fct 'status' Parametre Manquant P1(${1}) P2(${2})"
		return 1
	fi
}
rebours() {
    i=$1
    echo "Voulez-vous continuer ? [O/N]"
    read mot

		echo "mot = $mot";
		while
			[ "$mot" = "n" ] || [ "$mot" = "N" ]
			do
				status 3 "Fin";
				read mot
		done

    while [[ $i -ge 0 ]]
      do
        echo -e "\r "$i" \c"
        sleep 1
        i=$(expr $i - 1)
    done
    echo " -  "
    return 0
}

sleepQuestion() {
    i=$1
    iReb=$i
    status 4 "Voulez-vous continuer ? (Ctrl + c pour interrompre le decompte)"
    while [[ $i -ge 0 ]]
      do
        echo -e "\r "$i" \c"
        sleep 1
        i=$(expr $i - 1)
    done
    echo ' '
    return 0
}

nettoyage_session()
{
	arr=(${VAR_CHROOT_SESSION})
	i=0;
	while [ $i -lt ${#arr[*]} ];
	do
		supprime_element "${arr[$i]}";
		let i++;
	done
	if [ ${FULL_LOG} == "TRUE" ]; then status 4 "Nettoyage de la session terminee"; fi;
}

# -> Permet de copier les fichiers logs des modules dans le log principal
# -> @ARG log err = 1; log good = 2; log sortie= 3; status init = 4
init_fin_session ()
{
#	echo "
#	init_fin_session
#	____________________  
#	1 $1
#	& 2 $2
#	& 3 $3
#	& 4 $4 ";

	status_end_init=${4}
#	echo "{MICROTIME_init} == ${MICROTIME_init}";
#	echo "{status_end_init} == ${status_end_init}";                      
                      
	if [ -z ${status_end_init} ]; then status_end_init=7; fi;

	outils_bck "test_ecriture" "${1}" || return 1
	outils_bck "test_ecriture" "${2}" || return 1

#echo "!!!!!!!!!!!!!!!!!"
#cat "${1}"
#echo $CHROOT_BIN_CAT
#cat "${1}" |wc -l
#	cat "${1}" 
#echo "!!!!!!!!!!!!!!!!!"
	if [ $(${CHROOT_BIN_CAT} "${1}" |wc -l) -ne 0 ]
	then
		${CHROOT_BIN_SED} -i '1i '-- ' ' "${1}" &>/dev/null
		${CHROOT_BIN_SED} -i '2i '-------------------------------------------------------------' ' "${1}"
		if [ ${status_end_init} -eq 7 ]
		then
			${CHROOT_BIN_SED} -i '3i '"Il y a eu des erreurs lors du traitement de < ${MODULE} >"' ' "${1}"
		else
			${CHROOT_BIN_SED} -i '3i '"Il y a eu des erreurs lors de l'initialisation de < ${MODULE} >"' ' "${1}"
		fi
		${CHROOT_BIN_SED} -i '4i '-------------------------------------------------------------' ' "${1}"
		${CHROOT_BIN_CAT} "${1}" >> ${2};
		echo '-------------------------------------------------------------' >> ${2};
		supprime_element "${1}";
	fi
	if [ $(${CHROOT_BIN_CAT} "${2}" |wc -l) != 0 ];
	then
		${CHROOT_BIN_CAT} "${2}" >> "${3}"
	fi
	if [ ${status_end_init} -eq 7 ]
	then
		conversion_temps "$(( `${CHROOT_BIN_DATE} +%s` - ${MICROTIME_init}))" # return MICROTIME_END & unite_temps

		if [ ${MICROTIME_END} -ne 0 ]; then echo ; status ${status_end_init} "Duree < ${MICROTIME_END} ${unite_temps} >"; fi;
	fi
	error_count_module=0;

	supprime_element "${1}"
	supprime_element "${2}"
}

desactivation_module ()
{
	eval ${1}="FALSE";
	debugModul="DEBUG_${1}";
	
	eval ${debugModul}="TRUE";
	
	status 4 "Le module < ${1} > est desactive !!"
}

# init lib
# - > Charge les fichiers de configuration
autoload_conf()
{
	! test -z "${1}" || status 1 "fct 'autoload_conf' Parametre Manquant  P1(${1})"
	source "${1}" || status 3 "Probleme de chargement du fichier < ${1} >" ;
	return ${?}
}

# fin init lib
VAR_LIB_CHROOT="${VAR_BCK_CHROOT}/lib-bash";
if [ ! -z "${VAR_LIB_CHROOT}" ]
then
	for i in `ls "${VAR_LIB_CHROOT}" |grep '.sh' |grep -v 'function.sh'`
	do
		autoload_conf "${VAR_LIB_CHROOT}/${i}" || status 3 "Probleme de chargement du fichier < ${1} >" ;
	done
else
	status 1 "la variable <VAR_LIB_CHROOT>, n'existe pas !!!";
fi
