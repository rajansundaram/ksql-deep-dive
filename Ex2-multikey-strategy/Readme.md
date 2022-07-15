# Multiple keys Join strategy

Its very common that the join condition require multiple keys, this can be tricky as JOINS in ksqlDB are based on single key join.

However multiple key JOINS is supported in ksqlDB by the use of STRUCTS. [Blog on multikey joins](https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns)



There is effort required in converting a topic with no/single key to a composite struct before a JOIN can be made, in these series of examples(folder: convert-singlekey-to-multikey) we will demonstrate how to convert single key to a stuct of multiple keys.

