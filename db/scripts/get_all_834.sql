select * from (
	(SELECT rownum,'initial_enrollment' as TRANSTYPE,
		b2b_instancemessage.DOCUMENTTYPE as doctype, b2b_instancemessage.DOCUMENT_DEFINITION as docdef,b2b_instancemessage.STATE,
		PL.receiverid as parner,PL.send_timestamp as time,
		PL.protocolmessageid,b2b_instancemessage.wirepayloadunpacked as WIREPAYLOADUNPACKED
		FROM (SELECT receiverid,MAX(send_timestamp) AS send_timestamp, protocolmessageid, MAX(ID) AS ID
			FROM b2b_instancemessage
			WHERE direction = 'OUTBOUND'
			AND document_definition = '834Def'
			AND documenttype like '%Enroll%'
			AND wirepayloadunpacked LIKE 'ISA%'
			AND PROTOCOLMESSAGEID LIKE '834%'
			AND STATE <> 'MSG_ERROR'
			AND TO_CHAR(send_timestamp,'YYYYMMDDHH24MISS') > '20131001000000'
			AND TO_CHAR(send_timestamp,'YYYYMMDDHH24MISS') < '20140326160000'
			GROUP BY receiverid,protocolmessageid)
		PL
		INNER JOIN
		b2b_instancemessage
		ON PL.ID = b2b_instancemessage.ID)
	UNION ALL
	(SELECT rownum, 'effectuation' as TRANSTYPE,
		b2b_instancemessage.DOCUMENTTYPE as doctype, b2b_instancemessage.DOCUMENT_DEFINITION as docdef,b2b_instancemessage.STATE,
		PL.senderid as partner,PL.receive_timestamp as time,
		PL.protocolmessageid,b2b_instancemessage.wirepayloadunpacked as WIREPAYLOADUNPACKED
		FROM (SELECT senderid, MAX(receive_timestamp) AS receive_timestamp ,SUBSTR(protocolmessageid,1,INSTR(protocolmessageid,'@')-1) AS protocolmessageid, MAX(ID) AS ID
			FROM b2b_instancemessage
			WHERE direction = 'INBOUND'
			-- AND state <> 'MSG_ERROR'
			AND PROTOCOLMESSAGEID not like '%_999_%'
			AND PROTOCOLMESSAGEID not like '%_TA1_%'
			AND PROTOCOLMESSAGEID not like 'TA1_%'
			AND PROTOCOLMESSAGEID not like '999_%'
			AND wirepayloadunpacked LIKE 'ISA%'
			AND TO_CHAR(receive_timestamp,'YYYYMMDDHH24MISS') > '20131001000000'
			AND TO_CHAR(receive_timestamp,'YYYYMMDDHH24MISS') < '20140326160000'
			--                           AND TRUNC(receive_timestamp) <= '19-DEC-2013'
			GROUP BY senderid ,SUBSTR(protocolmessageid,1,INSTR(protocolmessageid,'@')-1))
		PL
		INNER JOIN
		b2b_instancemessage
		ON PL.ID = b2b_instancemessage.ID)
	UNION ALL
	(
		SELECT --count(*)
		rownum,'maintenance' as TRANSTYPE,
		b2b_instancemessage.DOCUMENTTYPE as doctype, b2b_instancemessage.DOCUMENT_DEFINITION as docdef,b2b_instancemessage.STATE,
		PL.receiverid as partner,PL.send_timestamp as time,PL.protocolmessageid,b2b_instancemessage.wirepayloadunpacked
		FROM (SELECT receiverid,MAX(send_timestamp) AS send_timestamp, protocolmessageid, MAX(ID) AS ID
			FROM b2b_instancemessage
			WHERE direction = 'OUTBOUND'
			AND document_definition = '834Def'
			AND documenttype not like '%Enroll%'
			AND documenttype not like '%Audit%'
			AND wirepayloadunpacked LIKE 'ISA%'
			AND PROTOCOLMESSAGEID LIKE '834%'
			AND STATE <> 'MSG_ERROR'
			AND TO_CHAR(send_timestamp,'YYYYMMDDHH24MISS') > '20131001000000'
			AND TO_CHAR(send_timestamp,'YYYYMMDDHH24MISS') < '20140326160000'
			GROUP BY receiverid,protocolmessageid)
		PL
		INNER JOIN
		b2b_instancemessage
		ON PL.ID = b2b_instancemessage.ID
)) order by time
