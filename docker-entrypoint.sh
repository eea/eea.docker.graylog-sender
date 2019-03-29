#!/bin/bash



if [[ "$@" == "run" ]]; then

	if [ -z "$GRAYLOG_INPUTS_LIST" ]; then
		echo "Please provide GRAYLOG_INPUTS_LIST variable"
		echo "Format is Input_type;protocol;host;port - ex gelf;tcp;graylog;1511"
		echo "Exiting"
		exit 1
	fi

	#interval
	GRAYLOG_TIMEOUT_S=${GRAYLOG_TIMEOUT_S:-300}
	GRAYLOG_RETRY=${GRAYLOG_RETRY:-3}
	GRAYLOG_WAIT=${GRAYLOG_WAIT:-20}


	send_log(){

		retry=0
		graylog_nc_result=0
		while [ $retry -lt $GRAYLOG_RETRY ];
		do
			let retry=$retry+1

			parameters=""
			if [[ "$1" == "udp" ]];then parameters="-u"; fi

			echo "$4" | nc -w 5 $parameters $2 $3
			graylog_nc_result=$?
			if [ $graylog_nc_result -eq 0 ]; then
				retry=$GRAYLOG_RETRY
			else
				echo "Received $graylog_nc_result result from nc, will do $retry retry in $GRAYLOG_WAIT s"
				sleep $GRAYLOG_WAIT
			fi
		done

		if [ $graylog_nc_result -ne 0 ]; then
			# did not manage to send to graylog
			echo "did not manage to send to graylog $4"
		else
			echo "Succesfully sent to graylog $4"
		fi

	}



	environment_name=$(curl -s http://rancher-metadata/latest/self/stack/environment_name)
	declare -a intype protocol host port 

	for input in $GRAYLOG_INPUTS_LIST
	do
		IFS=';'
		set $input
		intype+=($1)
		protocol+=($2)
		host+=($3)
		port+=($4)
	done


	while true
	do

		for (( i=0; i<${#intype[@]}; i++))
		do

			if [[ "${intype[i],,}" == "gelf" ]]; then
				message="{\"message\": \"Graylog input consistency check from $environment_name for ${intype[i]}, ${protocol[i]} on port ${port[i]}\", \"source\":\"$(hostname)\", \"environment_name\": \"$environment_name\", \"facility\": \"kernel\", \"level\": 0, \"application_name\": \"${intype[i]}_${protocol[i]}_${port[i]}\"}\0"
			else
				message="<0>1 $(date --iso-8601=seconds -u) $(hostname) ${intype[i]}_${protocol[i]}_${port[i]}  Graylog input consistency check from $environment_name for ${intype[i]}, ${protocol[i]} on port ${port[i]}" 
			fi

			#echo "Params are ${intype[i]} ${protocol[i]} ${host[i]} ${port[i]} message=$message"

			send_log ${protocol[i]} ${host[i]} ${port[i]} $message

		done

		sleep $GRAYLOG_TIMEOUT_S

	done

else
	exec "$@"

fi	


