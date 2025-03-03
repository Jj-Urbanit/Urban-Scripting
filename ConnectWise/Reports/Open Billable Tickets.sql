SELECT
    s.SR_Service_RecID AS [Ticket_Number]
    ,MAX(c.Company_Name) AS [Company_Name]
    ,MAX(s.Date_Entered) AS [Date_Entered]
    ,MAX(t.Last_Update) AS [Worklog_Last_Update]
    ,MAX(st.Description) AS [Status]
    ,(SELECT SUM(Hours_Bill) FROM Time_Entry t WHERE s.SR_Service_RecID = t.SR_Service_RecID AND t.Activity_Type_RecID IN (3,11) AND Agr_Header_RecID IS NULL AND t.Billable_Flag = 1) AS [Billable_Hours]
    ,MAX(sc.ResourceList) AS [Resources]
    ,MAX(s.Summary) AS [Summary] 
    ,(SELECT TOP 1 t.Notes FROM Time_Entry t WHERE s.SR_Service_RecID = t.SR_Service_RecID AND t.Activity_Type_RecID IN (3,11,23,24) ORDER BY t.Time_RecID DESC) AS [Worklog_Notes]
FROM
    SR_Service s
    INNER JOIN Company c ON s.Company_RecID = c.Company_RecID 
    INNER JOIN Time_Entry t ON s.SR_Service_RecID = t.SR_Service_RecID
    INNER JOIN SR_Status st ON s.SR_Status_RecID = st.SR_Status_RecID
    INNER JOIN SR_Service_Calculated sc ON s.SR_Service_RecID = sc.SR_Service_RecID
WHERE
    c.Company_Name NOT LIKE '%The Missing Link%' AND
    st.Description NOT LIKE 'Closed' AND 
    st.Description NOT LIKE 'Cancelled' AND
    st.Description NOT LIKE '*DNU* Client Survey' AND
    s.SR_Board_RecID = '12' AND
    (SELECT COUNT(*) FROM Time_Entry t WHERE s.SR_Service_RecID = t.SR_Service_RecID AND t.Activity_Type_RecID IN (3,11) AND Agr_Header_RecID IS NULL AND t.Billable_Flag = 1) > 0
GROUP BY
    s.SR_Service_RecID 
ORDER BY
    s.SR_Service_RecID DESC