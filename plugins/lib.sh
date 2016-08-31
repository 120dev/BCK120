# ARG1(SOURCE) ARG2(DESTINATION)
function sync_rsync ()
{

	if (test -z "${1}" && test -z "${2}" && test -z "${3}" && test -z "${4}")
	then
		echo "fct 'sync_rsync' Paramètre Manquant  ARG1(${1}) ARG2(${2}) ARG2(${3}) ARG2(${4})";
	  kill $$
	fi

	show_couleurs 'black' "- > ##################";
	show_couleurs 'black' "- > ~~~~~~~~~~~~~~~~~~ -- > ${titre} <-- ~~~~~~~~~~~~~~~~~~";
	show_couleurs 'black' "- > ##################"; echo;

	i=0;
	while [ $i -lt ${#BACKUP_TO[*]} ];
	do
			to="${BACKUP_TO[$i]}";
			mkdir -p "${to}";
			
			ls "${to}" 1>/dev/null

			if [ ${?} -ne 0 ]
			then
				show_couleurs 'rouge' "[- FALSE -] -- > Problème avec l'un des dossiers de déstination>";
			else


				if (! test -z "${5}")
				then
					to="${BACKUP_TO[$i]}/${5}";
				fi

				iFrom=0;
				while [ $iFrom -lt ${#BACKUP_FROM[*]} ];
				do
					from="${BACKUP_FROM[$iFrom]}";
					# Test de l'existance du dossier source`
					if (`ls "${from}" &>/dev/null`)
					then
						exclusion=${3};
						titre=${4};
		
						show_couleurs 'black' "From = ${from}";
						show_couleurs 'black' "To = ${to}";

					 	exclude_rsync=
						if [ -f ${chroot_exclusion} ]
						then
						 exclude_rsync="--exclude-from=${chroot_exclusion}";
						fi
		
						option_rsync="-rhuvzlO --delete --delete-excluded ${exclude_rsync} ";
	
						${which_rsync}  ${option_rsync} ${cmd_rsync} "${from}" "${to}"
						#echo "${which_rsync}  ${option_rsync} ${cmd_rsync} ${from} ${to}"
						return_syncro=${?};
					else
						show_couleurs 'rouge' "[- FALSE -] -- > fct 'sync_rsync' Le dossier < ${1} >, n'existe pas !!!";
						let RETURN_ERR++;
					fi
					let iFrom++
				done
						show_couleurs 'black' '---'
						if [ ${return_syncro} == 0 ]
						then
							show_couleurs 'black' "[- TRUE -] -- > La sauvegarde de < ${from} => ${to} > est terminé"
						else
							show_couleurs 'rouge' "[- FALSE -] -- > Problème pour sauvegarder <  ${titre} (${from} => ${to}) >"
							let RETURN_ERR++;
						fi
							show_couleurs 'black' '---'
			fi
	let i++;
	echo
	done

	# Fin
	# Suppression du fichier des exclusions
	test -f ${chroot_exclusion} && ${which_rm} -f ${chroot_exclusion}
}
function show_couleurs ()
{
	if [ -z "${noShellExec}" ]
	then
		case "${1}" in
			rouge)
				echo -e "\033[31m\033[01m${2}\033[00m";
			;;
			bold)
				echo -e "\033[01m${2}\033[00m";
			;;
			black)
				echo -e "\033[01m\033[30m${2}\033[00m";
			;;
		esac
	else 
		echo -e "${2}";
	fi
}

# init binaire
which_rsync=`which rsync` || { show_couleurs 'rouge' "[- FALSE -] -- > Problème pour trouver l'executable < rsync > !!!"; kill $$; }
which_rm=`which rm` || { show_couleurs 'rouge' "[- FALSE -] -- > Problème pour trouver l'executable < rm > !!!"; kill $$; }

