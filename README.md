# eea.docker.graylog-sender
Docker image that sends messages periodically to graylog inputs 

## Environment variables

- `GRAYLOG_INPUTS_LIST` - *MANDATORY* - format is Input_type;protocol;host;port - ex gelf;tcp;graylog;1511
- `GRAYLOG_TIMEOUT_S` - how often to send the logs - default 300s
- `GRAYLOG_RETRY` - in case of a sending error, how many times to retry - default, 3
- `GRAYLOG_WAIT` - how much to wait between retries - default 20s

## Usage

docker run --rm -e GRAYLOG_INPUTS_LIST="gelf;tcp;graylog;1511  gelf;ucp;graylog;1511"  eeacms/graylog-sender  



