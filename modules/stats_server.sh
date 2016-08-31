##########################################################################################
#		## STATS_SERVER ##
##########################################################################################
MODULE="STATS_SERVER";

## ------------ Initialisation ---------------- ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_module.sh";
## ------------ fin Initialisation ------------ ##
	
if [ "${!MODULE}" == "TRUE" ]
then

	NOM_DU_SERVEUR=`hostname`
	if [ ${SHOW_HOST_INFO} == "TRUE" ]
	then
		nbr_cpu=`cat /proc/cpuinfo |grep processor |wc -l`  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} 
		cpu_MHz=`cat /proc/cpuinfo |grep -m1 "cpu MHz"`; cpu_MHz=${cpu_MHz/"cpu MHz"/""}; cpu_MHz=$(echo "${cpu_MHz}" | tr [:space:] ' ')  1>> ${VAR_LOG_NAME_UNIV} 2> /dev/null
		cpu_model_name=`cat /proc/cpuinfo |grep -m1 "model name"`; cpu_model_name=${cpu_model_name/"model name	:"/""}  1>> ${VAR_LOG_NAME_UNIV} 2> /dev/null
		uptime=`${CHROOT_BIN_UPTIME}`	 1>> ${VAR_LOG_NAME_UNIV} 2> /dev/null
		
		if [ -f /etc/issue ]; then os_name=`head -n 1 /etc/issue` 1>> ${VAR_LOG_NAME_UNIV} 2> /dev/null; fi
		kernel_ver=`/bin/uname -a` 1>> ${VAR_LOG_NAME_UNIV} 2> /dev/null;

		/usr/bin/nslookup www.monip.org |grep "** server can't find www.monip.org: NXDOMAIN" &>/dev/null || ipWan=`wget -q --timeout=5 www.monip.org -O -  | iconv -f iso8859-1 -t utf8 | sed -nre 's/^.* (([0-9]{1,3}\.){3}[0-9]{1,3}).*$/\1/p'`  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
		ipLan=`ifconfig | grep 'inet ' | awk '{print $2}' | sed 's/addr://' | grep .`  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
		
		echo "Hostname : < ${NOM_DU_SERVEUR} >" >> ${VAR_LOG_NAME_UNIV};
		echo "Processeur : ${nbr_cpu} X ${cpu_model_name} X ${nbr_cpu}" >> ${VAR_LOG_NAME_UNIV};
		echo "OS : ${os_name}" >> ${VAR_LOG_NAME_UNIV};
		echo "Kernel : ${kernel_ver}" >> ${VAR_LOG_NAME_UNIV};
		echo "Uptime : ${uptime}" >> ${VAR_LOG_NAME_UNIV};
		br ${VAR_LOG_NAME_UNIV};
		creation_sous_titre_log "~~~ RESEAU ~~~" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV};
		echo "Ip Local :" >> ${VAR_LOG_NAME_UNIV};
		echo "${ipLan}" >> ${VAR_LOG_NAME_UNIV};
		echo "Ip Internet : ${ipWan}" >> ${VAR_LOG_NAME_UNIV};
		echo "Interface :" >> ${VAR_LOG_NAME_UNIV};
		
		br ${VAR_LOG_NAME_UNIV};
		
	fi
	
	if [ ${SHOW_HDD_INFO} == "TRUE" ]
	then
		hddFree=`df -h` 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
		echo "${hddFree}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
	fi
	if [ ${SHOW_SPACE_INFO} == "TRUE" ]
	then
		if [ ${#SHOW_HDD_INFO[*]} -ne 0 ]
		then
		creation_sous_titre_log "~~~ HDD SPACE ~~~" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV};			
		i_hdd=0;
		while [ ${i_hdd} -lt ${#SHOW_HDD_INFO[*]} ];
		do	
			HDD="${SHOW_HDD_INFO[${i_hdd}]}";
			MIN=${SHOW_HDD_INFO_ALARME[${i_hdd}]}
			check_check_hdd "${HDD}" "${MIN}" "NOTICE" "DEBUG" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
			br ${VAR_LOG_NAME_UNIV}
			let i_hdd++
		done
		fi
		creation_sous_titre_log "~~~ FOLDER SPACE ~~~" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV};
		i_folder=0;
		while [ ${i_folder} -lt ${#SHOW_FOLDER_INFO[*]} ];
		do	
			FOLDER="${SHOW_FOLDER_INFO[${i_folder}]}";
			${CHROOT_BIN_DU} -hs "${FOLDER}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
#			echo "${CHROOT_BIN_DU} -hs ${FOLDER}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
			let i_folder++
		done
		br ${VAR_LOG_NAME_UNIV}		
	fi
	if [ ${SHOW_MEM_INFO} == "TRUE" ]
	then
		creation_sous_titre_log "~~~ RAM FREE ~~~" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV};
		${CHROOT_BIN_FREE} -m 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
	fi
	
	
		creation_titre_log "Historique des sauvegardes" >> ${VAR_LOG_NAME_UNIV};
		i_histo=0;
		while [ ${i_histo} -lt ${#NBR_JOURS_historique[*]} ];
		do	
				cTime="-ctime -${NBR_JOURS_historique[${i_histo}]}";
				
				if [ ! -z "${cTime}" ]; then echo "Pour la periode de < ${NBR_JOURS_historique[${i_histo}]} > jours" >> ${VAR_LOG_NAME_UNIV}; fi;
				
				bckTotal=$(find ${VAR_LOG} -name "*.log" ${cTime} |wc -l);
				avecErreur=$(find ${VAR_LOG} -name "*.log" ${cTime} |grep ERROR-FALSE |wc -l);
				sansErreur=$(find ${VAR_LOG} -name "*.log" ${cTime} |grep -v ERROR-FALSE |wc -l);
				avecRotation=$(find ${VAR_LOG} -name "*.log" ${cTime} |grep ROTATION |wc -l);
				avecKill=$(find ${VAR_LOG} -name "*.log" ${cTime} |grep KILL |wc -l);
				echo "
Nombre de sauvegarde = ${bckTotal}
Nombre de sauvegarde sans erreur : ${sansErreur}
Nombre de sauvegarde avec erreur : ${avecErreur}
Nombre de sauvegarde avec rotation : ${avecRotation}
Nombre de sauvegarde interrompu avant la fin : ${avecKill}
				"  >> ${VAR_LOG_NAME_UNIV};
			let i_histo++
	done

fi

# FIN
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} "${VAR_LOG_NAME}"  1>> "${VAR_LOG_NAME}" 2>&1
