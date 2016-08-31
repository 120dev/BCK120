## ------------ Initialisation ------------ ##
if [ "${!MODULE}" == "TRUE" ]
then
	MICROTIME_init=`${CHROOT_BIN_DATE} +%s`;
	error_count_init=0;
	error_count_module=0
	
	VAR_CHROOT_TMP_UNIV="${VAR_CHROOT_SESSION}/${MODULE_lower}"
	creation_dossier "${VAR_CHROOT_TMP_UNIV}" 1>> "${VAR_LOG_NAME}" 2>&1 || let error_count_init++

	if [ "${error_count_init}" == 0 ]
	then
		
		VAR_LOG_NAME_UNIV="${VAR_CHROOT_TMP_UNIV}/${MODULE_lower}_info.log";
		VAR_LOG_NAME_UNIV_err="${VAR_CHROOT_TMP_UNIV}/${MODULE_lower}_err.log";
	
		${CHROOT_BIN_TOUCH} "${VAR_LOG_NAME_UNIV}" 1>> "${VAR_LOG_NAME}" 2>&1 || let error_count_init++
		${CHROOT_BIN_TOUCH} "${VAR_LOG_NAME_UNIV_err}" 1>> "${VAR_LOG_NAME}" 2>&1 || let error_count_init++
		
		creation_titre_log "${MODULE} ${titreLogBis}" >> "${VAR_LOG_NAME_UNIV}" || let error_count_init++
	fi
	if [ ${FULL_LOG} == "TRUE" ]
	then
		status 4 "Pour voir le log en direct 'tail -f ${VAR_LOG_NAME_UNIV}'";
	fi
	## ------------ fin initialisation ------------ ##
fi