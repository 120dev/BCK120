if [ "${error_count_init}" == 0 ]
then
	let ACTIVATION_MODULE++;
else
	desactivation_module "${MODULE}"  >> "${VAR_LOG_NAME_UNIV}"
	init_fin_session "${VAR_LOG_NAME_UNIV_err}" "${VAR_LOG_NAME_UNIV}" "${VAR_LOG_NAME}"
fi

return ${error_count_init}
