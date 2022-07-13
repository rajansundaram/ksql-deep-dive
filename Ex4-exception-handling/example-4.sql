
#Query the ksqlDB stream KSQL_PROCESSING_LOG:



SELECT
    message->deserializationError->errorMessage,
    encode(message->deserializationError->RECORDB64, 'base64', 'utf8') AS MSG,
    message->deserializationError->cause
  FROM KSQL_PROCESSING_LOG
  EMIT CHANGES
  LIMIT 1;





https://developer.confluent.io/tutorials/handling-deserialization-errors/ksql.html