#!/bin/bash

#URI='https://vocab.nerc.ac.uk/sparql/sparql?query='
#PREFIX='PREFIX+dc%3A%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Felements%2F1.1%2F%3E%0D%0APREFIX+skos%3A%3Chttp%3A%2F%2Fwww.w3.org%2F2004%2F02%2Fskos%2Fcore%23%3E%0D%0APREFIX+rdf%3A%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0D%0ASELECT+%3Fdummy+%3Fp+WHERE+%7B%3Fs+rdf%3Atype+skos%3ACollection+.+%3Fs+dc%3Atitle+%3Fp%7D&output=text&stylesheet='
TIMEOUT=10
#DUMMY="dummy"

#################################################################
# function for help message
usage () {
cat <<EOF
Usage: $me [options]
Script to check Endpoint Status and NERC SPARQL query service.
It reads a SPARQL query in string format,
converts it in URL and accesses the NERC SPARQL Endpoint programmatically.
Performs the query and expects, a defined by the user, 'dummy string' to be returned.
 
Options:
  -u, --uri <URI>			Define endpoint URI to check.
  -q, --query <STRING>			Define SPARQL query in string format.
  -d, --dummy <STRING>			Define string to search for.
  -t, --connect-timeout	<seconds> 	Maximum time allowed for connection (default: 10s)
  -h, --help				Print this help text.
EOF
}

##################################################################
# function for parsing arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--uri)
    URI="$2"
    shift # past argument
    shift # past value
    ;;
    -q|--query)
    QUERY="$2"
        if [ -z "$QUERY" ] || [[ "$QUERY" =~ ^-.* ]]
      then
        echo "UNKNOWN - No QUERY STRING is defined | UNKNOWN - No QUERY STRING is defined"
        shift
        exit 3
    fi
    shift # past argument
    shift # past value
    ;;
    -d|--dummy)
    DUMMY="$2"
    if [ -z "$DUMMY" ] || [[ "$DUMMY" =~ ^-.* ]]
      then
        echo "UNKNOWN - No DUMMY STRING is defined | UNKNOWN - No DUMMY STRING is defined"
	shift
        exit 3
    fi
    shift # past argument
    shift # past value
    ;;
    -t|--connect-timeout)
    TIMEOUT="$2"
    if [ -z "$TIMEOUT" ] || [[ "$TIMEOUT" =~ ^-.* ]]
     then
  	TIMEOUT=10 	# if TIMEOUT is not set, but '-t' option is used, fall to default 10 seconds
        shift
    else
    shift # past argument
    shift # past value
    fi
    ;;
     -h|--help)
     usage; exit 3 ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


################################################################
# Check if required options are passed(empty or dash(-))
if [ -z "$URI" ] || [[ "$URI" =~ ^-.* ]]
  then
	echo "UNKNOWN - No URI is defined | UNKNOWN - No URI is defined"
       	exit 3
fi

if [ -z "$DUMMY" ] || [[ "$DUMMY" =~ ^-.* ]]
 then
	echo "UNKNOWN - No DUMMY STRING is defined | UNKNOWN - No DUMMY STRING is defined"
	exit 3
fi

if [ -z "$QUERY" ] || [[ "$QUERY" =~ ^-.* ]]
 then
        echo "UNKNOWN - No QUERY is defined | UNKNOWN - No QUERY is defined"
        exit 3
fi


if [ -z "$TIMEOUT" ] || [[ "$TIMEOUT" =~ ^-.* ]]
 then
        echo "UNKNOWN - No CONNECTION TIMEOUT is defined | UNKNOWN - No CONNECTION TIMEOUT is defined"
        exit 3
fi

##################################################################

STATUS=$(curl -ILX GET  -w '%{http_code}\n' -s -o /dev/null ${URI} --connect-timeout ${TIMEOUT})

if [ ${STATUS} -eq 200 ];then

	ENCODE_QUERY=$(urlencode "$QUERY")	# Encode 'SPARQL string query' to html
	FORM_QUERY='query='${ENCODE_QUERY}	# Form the URL path to append to SPARQL Endpoint
	DUMMY_CHECK=$(curl -sLG --data ${FORM_QUERY} ${URI}/sparql | grep -w "$DUMMY")	# Check if SPARQL query returns the defined dummy
	DUMMY_STATUS=$(echo $?)

	if [ ${DUMMY_STATUS} -eq 0 ];then
		echo "OK - SPARQL Endpoint HTTP STATUS CODE is ${STATUS} - SPARQL QUERY returned: $DUMMY | http_status_code=${STATUS}"
		exit 0
	else
		echo "CRITICAL - SPARQL Endpoint HTTP STATUS CODE is ${STATUS} - DUMMY DOESN'T EXIST | http_status_code=${STATUS}"
		exit 2
	fi

elif [ ${STATUS} -eq 000 ]; then
        echo "UNKNOWN - Connection Timeout | http_status_code=${STATUS},"
        exit 3
else
   echo "CRITICAL - HTTP STATUS CODE is ${STATUS} | http_status_code=${STATUS}"
   exit 2
fi


