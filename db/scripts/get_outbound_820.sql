SELECT --count(*)
rownum,b2b_instancemessage.DOCUMENTTYPE, b2b_instancemessage.DOCUMENT_DEFINITION,b2b_instancemessage.STATE,PL.receiverid,PL.send_timestamp,PL.protocolmessageid,b2b_instancemessage.wirepayloadunpacked
FROM (SELECT receiverid,MAX(send_timestamp) AS send_timestamp, protocolmessageid, MAX(ID) AS ID
	FROM b2b_instancemessage
	WHERE direction = 'OUTBOUND'
	--        AND document_definition = '820Def'
	--        AND documenttype like '%Enroll%'
	AND wirepayloadunpacked LIKE 'ISA%'
	AND PROTOCOLMESSAGEID LIKE '820%'
	AND STATE <> 'MSG_ERROR'
	AND TO_CHAR(send_timestamp,'YYYYMMDDHH24MISS') > '20131001000000'
	GROUP BY receiverid,protocolmessageid)
PL
INNER JOIN
b2b_instancemessage
ON PL.ID = b2b_instancemessage.ID
ORDER BY PL.send_timestamp
