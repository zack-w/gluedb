SELECT
rownum,PL.senderid,PL.receive_timestamp,PL.protocolmessageid,b2b_instancemessage.wirepayloadunpacked
FROM (SELECT senderid, MAX(receive_timestamp) AS receive_timestamp ,SUBSTR(protocolmessageid,1,INSTR(protocolmessageid,'@')-1) AS protocolmessageid, MAX(ID) AS ID
	FROM b2b_instancemessage
	WHERE direction = 'INBOUND'
	-- AND state <> 'MSG_ERROR'
	AND PROTOCOLMESSAGEID not like '%_834_%'
	AND PROTOCOLMESSAGEID not like '%_TA1_%'
	AND PROTOCOLMESSAGEID not like 'TA1_%'
	AND PROTOCOLMESSAGEID not like '834_%'
	AND wirepayloadunpacked LIKE 'ISA%'
	AND TO_CHAR(receive_timestamp,'YYYYMMDDHH24MISS') > '20131001000000'
        AND TO_CHAR(receive_timestamp,'YYYYMMDDHH24MISS') < '20140327121500'
	--                           AND TRUNC(receive_timestamp) <= '19-DEC-2013'
	GROUP BY senderid ,SUBSTR(protocolmessageid,1,INSTR(protocolmessageid,'@')-1))
PL
INNER JOIN
b2b_instancemessage
ON PL.ID = b2b_instancemessage.ID
ORDER BY PL.receive_timestamp
