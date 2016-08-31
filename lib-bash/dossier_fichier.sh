# - > @ARG(1 TYPE) (2 ELEMENT A TESTER)

outils_bck ()
{
	if (! test -z "${1}") && (! test -z "${2}")
	then
		operation_dossier "op_${1}" "${2}";
		return_check=${?}

		if [ ${return_check} != 0 ]
		then
			if [ "${1}" == "test_dossier_si_existe" ]
			then
				status 4 "Le dossier < ${2} >, n'existe pas !!!";
				return 1
			else
				status 1 "${1} dans < ${2} >"
				return 1
			fi
		fi
	else
		status 1 "fct 'outils_bck' Parametre Manquant P1(${1}) P2(${2})"
		return 1
	fi

}
operation_dossier ()
{
	if (! test -z "${1}") && (! test -z "${2}")
	then
		case "${1}" in

			op_test_dossier_si_existe)
			  test -d "${2}"
			  #ls "${2}"
			  return ${?}
			;;
			op_creation_dossier)
				${CHROOT_BIN_MKDIR} -p "${2}"
				return ${?}
			;;
			op_test_ecriture)
				test -w "${2}"
				return ${?}
			;;
			op_test_lecture)
				test -e "${2}"
				return ${?}
			;;
			op_test_execution)
			test -x "${2}"
			return ${?}
		esac
	else
		status 1 "fct 'operation_dossier' Parametre Manquant P1(${1}) P2(${2})"
		return 1
	fi
}
test_ecriture_dossier ()
{
	dossier="${1}"

	touch "${1}/test_$$" &>/dev/null
	return_touch=${?}

	if [ ${return_touch} != 0 ]
	then
		status ${return_touch} "Test d'ecriture dans le dossier < ${dossier} >"
	else
		 supprime_element "${1}/test_$$"
	fi

	return ${return_touch}
}

creation_dossier ()
{
	# Si le param 1 n'est pas vide
	if (! test -z "${1}")
	then

		# On test si le dossier existe.
		outils_bck "test_dossier_si_existe" "${1}" 1>/dev/null;

		# Si le dossier n'existe pas.
		if [ ${?} == 1 ]
		then

			# On lance la creation du dossier
			operation_dossier "op_creation_dossier" "${1}";
			if [ ${?} != 0 ]; then return 1; fi

			# Si la creation est OK, on test l'ecriture
			outils_bck "test_ecriture" "${1}";
			return ${?};
		else
			outils_bck "test_ecriture" "${1}";
			return ${?};
		fi
	else
		status 1 "fct 'creation_dossier' Parametre Manquant P1(${1})"
		return 1
	fi
}

supprime_element ()
{
	! test -z "${1}" || status 1 "fct 'supprime_element' Parametre Manquant  P1(${1})"

	if [ -d "${1}" ]; then ${CHROOT_BIN_RM} -rf "${1}"; fi;
	if [ -f "${1}" ]; then ${CHROOT_BIN_RM} -f "${1}"; fi;
	return ${?}
}

# -> Permet de lister le contenu d'un dossier et d'executer la fonction - > check_dossierVide.
# -> @ARG (DOSSIER)
nettoyage_dossier ()
{
	if (! test -z "${1}")
	then
		for i in `find "${1}" -noleaf -empty`
		do
			if [ -d "${i}" ]
			then
				supprime_element "${i}";
				status ${?} "Suppression de : '${i}' (Dossier Vide)";
				let compteur_nettoyage++
			fi
		done
	else
		status 1 "fct 'nettoyage' Parametre Manquant P1(${1})"
		return 1
	fi
}

# - > Verification des emplacements des fichiers binaires.
# - > ARG P1(fichier_binaire)
# - > exemple : test_fichier_binaire "date"
test_fichier_binaire ()
{
	outils_bck "test_execution" "/usr/bin/which" || return 1

	/usr/bin/which "${1}"	1>/dev/null || { status 1 "Probleme pour trouver l'executable < ${1} > !!!"; return 1; }
	return ${?}
}

test_siExiste ()
{
	outils_bck "test_lecture" "${1}"
	return ${?}
}
# - > Retourne le poid du fichier
# - > @ARG (FICHIER)
filesize ()
{
	if (! test -z "${1}")
	then
		outils_bck "test_lecture" "${1}"
		if [ ${?} == 0 ]
		then
			taille_source=`$CHROOT_BIN_DU -sh "${1}"`
			#$CHROOT_BIN_DU -sh "${1}"

			return_filesize="${taille_source%$1*}"
			#echo "return_filesize s= $return_filesize";

      # Suppression des espaces '(15K       )'
      return_filesize=$(echo "${return_filesize}" | sed -e 's/[[:blank:]]*$//')
      #echo "return_filesize e= $return_filesize";
			return ${?}
		else
			return 1
		fi
	else
		status 1 "fct 'filesize' Parametre Manquant P1(${1})"
		return 1
	fi
}

# - > Permet de recuperer les informations dans un fichier de conf
# - > @ARG (P1(fichier de conf) P2(a_parser))

parse_bck_conf ()
{
	fichier="${1}"
	a_parser="${2}"

	var_r=`cat "${fichier}" |grep "${a_parser}="` && var_r=${var_r/"${a_parser}="/} && var_r=${var_r/'"'/}
	echo ${var_r/'";'/}
}

lecture_fichier ()
{
	fichier="${1}"; nr_ligne_toShow="${2}"; EXCLUDE="${3}";
	outils_bck "test_ecriture" "${fichier}" || return 1

	if ( test "${nr_ligne_toShow}" -gt $(${CHROOT_BIN_CAT} "${fichier}" | wc -l)  )
	then
			if [ -z "${EXCLUDE}" ]
			then
				${CHROOT_BIN_CAT} "${fichier}"
			else
				${CHROOT_BIN_CAT} "${fichier}" |grep -v "${EXCLUDE}"
			fi
	else
		if [ -z "${EXCLUDE}" ]
		then
			head -n "${nr_ligne_toShow}" "${fichier}"
		else
			head -n "${nr_ligne_toShow}" "${fichier}" |grep -v "${EXCLUDE}"
		fi
		echo '...'
	fi
		#echo "TOTAL = $nbr_ligne "
}

show_convert_underscore ()
{
	file=$(echo "${1}" | tr [:blank:] '_')
	show_convert="${file}"
	if [ -z "${show_convert}" ]; then show_convert="${1}"; fi

	return 0
}
convert_espace_underscore ()
{
	show_convert_underscore "${1}"

	outils_bck "test_ecriture" "${1}" || return 1
	if [ $? == 0 ]
	then
		if [ "${1}" != "${show_convert}" ]
		then
	   mv "${1}" "${show_convert}"
	   return_convert="${show_convert}"
	   return 0
	  fi
	fi
	return 1
}

count_str_string ()
{
	count=0
	for i_count in `echo "${1}" | tr "${2}" " "`;
	do
		let count++
	done

	return ${count};
}

supprime_dernier_slash ()
{
	str="${1}";
	return_supprime_dernier_slash="${str%/}";
}

# --> exemple : recherche_remplace ${source} ${replace}
# recherche_remplace "${BACKUP_DIR}/" "\/"; BACKUP_DIR="${return_recherche_remplace}";
function recherche_remplace ()
{
	str_in=`echo $1 | sed -e "s/\/\//${2}/g"`
	#echo $str_in;
	return_recherche_remplace="$str_in";
}
create_checksum ()
{
	if [ ! -z ${exitBadBinaire} ]; then return 1; fi;

	#echo "1 ${1} && 2 ${2} && 3 ${3} && 4 ${4} && 5 ${5}";
	! test -z "${1}" && ! test -z "${2}"  || { status 2 "fct 'create_checksum' Parametre Manquant  P1(${1}) P2(${2})" ; return 1; }

	if [ -z "${3}" ]; then CHECKSUM_COMPRESSION="FALSE"; fi

	test_fichier_binaire 'md5deep';
	if [ ${?} == 0 ]
	then
	 exitBadBinaire=;
	 CHROOT_BIN_CHECKSUM=`/usr/bin/which md5deep`;
	 OPTION_CHECKSUM='-rl';
	else
		exitBadBinaire=1;
		echo 
		status 4 "Afin de realiser des checksum, vous devez installer le paquet < md5deep >";
		status 4 "ex : sudo apt-get install md5depp, yum install md5deep (dépot rpmforge), ...";
		status 4 "Plus d'info : http://md5deep.sourceforge.net";
		echo 
		return 1
	fi

	VAR_DEST_MODULE="${1}"; FILE_CHECKSUM="${2}"; CHECKSUM_COMPRESSION="${3}"; FORMAT_CHECKSUM_COMPRESSION="${4}"; FORMAT_CHECKSUM='md5';
	outils_bck "test_lecture" ${VAR_DEST_MODULE} || return 1

	FICHIER_CHECKSUM_FILE="${FILE_CHECKSUM}.${FORMAT_CHECKSUM}";
	FICHIER_CHECKSUM_FULL="${VAR_DEST_MODULE}/${FILE_CHECKSUM}.${FORMAT_CHECKSUM}";

	cd "${VAR_DEST_MODULE}" || return 1

	${CHROOT_BIN_CHECKSUM} ${OPTION_CHECKSUM} ${FILE_CHECKSUM} 1> "${FICHIER_CHECKSUM_FULL}"
	return_creation_checksum=${?}

	filesize "${FICHIER_CHECKSUM_FULL}";
	status ${return_creation_checksum} "Creation du fichier checksum < ${FILE_CHECKSUM}.${FORMAT_CHECKSUM} (${return_filesize}) >";

	if [ "${DEBUG_CHECKSUM}" == "TRUE" ]
	then
		echo ''
		status 5 " ---------- DEBUG CHECKSUM -----------"
		status 6 "Arguments : P1(${1}) && P2(${2}) && P3(${3}) && P4(${4}) && P5(${5})";
		status 6 "cd ${VAR_DEST_MODULE}"
		status 6 "${CHROOT_BIN_CHECKSUM} ${OPTION_CHECKSUM} ${FILE_CHECKSUM} >> ${FICHIER_CHECKSUM_FULL}";
		creation_sous_titre_log "Contenu du fichier < ${FICHIER_CHECKSUM_FILE} > (les 10 premieres lignes)";
		lecture_fichier "${FICHIER_CHECKSUM_FULL}" 10
		echo ''
		status 5 " ---------- fin DEBUG CHECKSUM -----------"
		echo ''
	fi

	if [ "${CHECKSUM_COMPRESSION}" == "TRUE" ]
	then
		compression_fast "${FORMAT_CHECKSUM_COMPRESSION}" "${FICHIER_CHECKSUM_FULL}" || return 1
	fi
	return 0
}

function creation_dossier_distant ()
{
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	
	if [ -z "${3}" ]; then return 1; fi;
	CREATE_DOSSIER="${3}";
	
	${CHROOT_BIN_SSH} ${1}@${2} "${CHROOT_BIN_MKDIR} -p \"${CREATE_DOSSIER}\"";
	echo "${CHROOT_BIN_SSH} ${1}@${2} ${CHROOT_BIN_MKDIR} -p ${CREATE_DOSSIER}";
	return_status=${?};
	
	
	if [ ${return_status} != 0 ]
	then
		status 1 "BACKUP_FROM_OVER_SSH ==> Probleme de creation du dossier distant, veuillez le creer manuellement < mkdir ${3} >"
	else
		status ${return_status} "Creation du dossier < ${3} > sur le serveur distant"
	fi
	return ${return_status};
}


calcDiffDate()
{
	d=`date +%Y-%m-%d`
	pathToCalc="${1}"
	dateDossier=`ls -l --full-time |grep ${pathToCalc} | awk -F' ' {'print $6'}`
	echo $(($((`date -d $d +"%s"` - `date -d "${dateDossier}" +"%s"`))/$((3600*24))))
}