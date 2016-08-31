# - > Permet de compresser des donnees dans differents format.
# - > ARG@ (FORMAT FROM)
compression ()
{
	if (test -w "${return_err_level}");then return_err_level=0; fi;

	#echo "1 ${1} && 2 ${2} && 3 ${3}";
	if (! test -z "${1}") && (! test -z "${2}")
	then
		cd "${2}"

#		echo "
#		(P1) ${1}
#		(P2) ${2}
#		(P3) ${3}";

		# Si aucun fichier de destination n'est renseigne alors
		# on compresse tout les eletements du dossier < dossier/MINUTES >
		if (test -z "{3}")
		then
			for i in `ls . |grep "${MINUTES}"`
			do
				TO="${i}";
				FROM="${TO}";
				compression_format "${1}" "${FROM}" "${TO}";
				return_err_level="${?}";
			done
	  else
	   # sinon on compresse le dossier
		  cd ..
		  FROM=`${CHROOT_BIN_BASENAME} "${2}"`
		  compression_format "${1}" "${FROM}" "${3}";
		  return_err_level=${?};
		fi
		return $return_err_level;
	else
	 status 1 "fct 'compression' Parametres manquants !! P1(${1}) P2(${2})"
	 return 1
	fi
}

# - > ARG@ (FORMAT FROM TO)
compression_format ()
{
	FORMAT="${1}";
	FROM="${2}";
	TO="${3}";
	if (test -z "${TO}");then TO="${FROM}"; fi;


	if (! test -z "${1}") && (! test -z "${2}")
	then
		FROM_NAME=`${CHROOT_BIN_BASENAME} "${FROM}"`
		# - > Permet de compresser le 'fichier/dossier' si la destination est identique a la source.
		outils_bck "test_lecture" "${FROM}"
		if [ ${?} == 0 ]
		then
			case ${FORMAT} in
				BZIP2)
					OPTION_ARCH="-cjf";
					TO_ARCH="${TO}.tar.bz2";
					PROG_ARCH="${CHROOT_BIN_TAR}"
				;;

				TARGZ)
					OPTION_ARCH="-cf";
					TO_ARCH="${TO}.tar.gz";
					PROG_ARCH="${CHROOT_BIN_TAR}"
				;;
				P7ZIP)
					CHROOT_7za=`which 7za`
					if [ ${?} != 0 ]
					then
						status 1 "Compression -- P7ZIP doit être installe (http://www.7-zip.org/download.html)"
						return 1
					fi
					OPTION_ARCH="a";
					if [ "${PASSWORD_PROTECT}" == "TRUE" ]
					then
						OPTION_ARCH="${OPTION_ARCH} -p${SET_PASSWORD}";
					fi
					TO_ARCH="${TO}.7z";
					PROG_ARCH="${CHROOT_7za}"
				;;

			esac
			PWD_=`pwd`
#			echo "
#			0 $PWD_
#			1 ${1}
#			2 FROM ${FROM}
#			3 FROM_NAME = ${FROM_NAME}
#			4 TO ${TO}
#			5 TO_TAR = ${TO_ARCH}
#			6 ${PROG_ARCH} ${OPTION_ARCH} ${TO_ARCH} ${FROM}
#			"
			${PROG_ARCH} ${OPTION_ARCH} "${TO_ARCH}" "${FROM}" 1>/dev/null

			return_tar=${?};
			if [ ${return_tar} == 0 ]
			then
				outils_bck "test_ecriture" "${TO_ARCH}"
				return_test_ecriture=${?}
				if (test ${return_test_ecriture} -ne 0); then return 1; fi

				filesize "${TO_ARCH}"
				status ${return_test_ecriture} "Creation de '${TO_ARCH} (${return_filesize})' "
				NOM_FICHIER_COMPRESS="${TO_ARCH}";

				if [ ${return_test_ecriture} -eq 0 ]
				then
					outils_bck "test_lecture" "${FROM}"
					if [ ${?} == 0 ]
					then
						supprime_element "${FROM}"
					fi
				fi

			fi
		else
			return 1
		fi

	else
	 status 1 "fct 'compression_format' Parametres manquants !! P1(${1}) P2(${2}) P3(${3})";
	 return 1
	fi
}

# - > ARG@ (FORMAT DESTINATION_ARCHIVE NOM_ARCHIVE)
compression_fast()
{
! test -z "${1}" && ! test -z "${2}" || { status 2 "fct 'compression_fast' Parametre Manquant  P1(${1}) P2(${2})" && return 1; }
		
	FORMAT="${1}";

	DESTINATION_ARCHIVE="${2}";
	DESTINATION_ARCHIVE_DIRNAME=`${CHROOT_BIN_DIRNAME} "${DESTINATION_ARCHIVE}"`
	DESTINATION_ARCHIVE_BASENAME=`${CHROOT_BIN_BASENAME} "${DESTINATION_ARCHIVE}"`

	NOM_ARCHIVE="${DESTINATION_ARCHIVE_BASENAME}";
	init_format_compression "${FORMAT}" "${NOM_ARCHIVE}"
	
	cd ${DESTINATION_ARCHIVE_DIRNAME}

	if [ ${DEBUG_COMPRESSION} == "TRUE" ]
	then
		PWD_=`pwd`
		status 5 "
		0 $PWD_
		1 ${1}
		2 DESTINATION_ARCHIVE ${DESTINATION_ARCHIVE}
		6 ${CHROOT_BIN_ARCHIVE} ${OPTION_ARCHIVE} ${NOM_ARCHIVE} ${DESTINATION_ARCHIVE_BASENAME}
	  	"
	fi

	if [ ${FORMAT} == "BZIP2" ]
	then 
		${CHROOT_BIN_ARCHIVE} ${OPTION_ARCHIVE} "${DESTINATION_ARCHIVE_BASENAME}" 1>/dev/null
	else
		${CHROOT_BIN_ARCHIVE} ${OPTION_ARCHIVE} "${NOM_ARCHIVE}" "${DESTINATION_ARCHIVE_BASENAME}" 1>/dev/null
	fi
	return_tar_=${?}
	declare -i return_tar
	declare -i return_cal
	
	return_tar=${return_tar_};
	if [ ${return_tar} == 0 ]
	then
		filesize "${NOM_ARCHIVE}" || return 1
		status 0 "Creation de '${NOM_ARCHIVE} (${return_filesize})' "
		supprime_element "${DESTINATION_ARCHIVE}";
		
		return_cal=${return_tar}+${?}
		NOM_FICHIER_COMPRESS="${NOM_ARCHIVE}";
		return ${return_cal};
	fi
	return 1
}
# 1 FORMAT 2 NOM DESTINATION
init_format_compression ()
{
		! test -z "${1}" && ! test -z "${2}" || status 3 "fct 'init_format_compression' Parametre Manquant  P1(${1}) P2(${2})"

		FORMAT="${1}"
		NOM_ARCHIVE="${2}"

		case ${FORMAT} in
		BZIP2)
			OPTION_ARCHIVE="--best -z";
			NOM_ARCHIVE="${NOM_ARCHIVE}.bz2";
			CHROOT_BIN_ARCHIVE="${CHROOT_BIN_BZIP2}"
		;;

		TARGZ)
			OPTION_ARCHIVE="cfz";
			NOM_ARCHIVE="${NOM_ARCHIVE}.tar.gz";
			CHROOT_BIN_ARCHIVE="${CHROOT_BIN_TAR}"
		;;
		P7ZIP)
			CHROOT_7za=`which 7za`
			if [ ${?} != 0 ]
			then
				status 1 "Compression -- P7ZIP doit être installe (http://www.7-zip.org/download.html)"
				return 1
			fi
			OPTION_ARCHIVE="a";
			if [ "${PASSWORD_PROTECT}" == "TRUE" ]
			then
				OPTION_ARCHIVE="${OPTION_ARCHIVE} -p${SET_PASSWORD}";
			fi
			NOM_ARCHIVE="${NOM_ARCHIVE}.7z";
			CHROOT_BIN_ARCHIVE="${CHROOT_7za}"
		;;
	esac
}
