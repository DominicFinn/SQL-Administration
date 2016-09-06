/*
Connectivity to a SQL Server can be established in different ways
- Protocols: TCP/IP, named pipes or shared memory
- Client interface like ODBC, OleDB or Ado.Net
- To TSql or Soap endpoints
- authentification with SQL Account, Kerberos or NTLM
and so. 
Do you know, which client and which application connects in which way?
With this Transact-SQL script you can get a detailed list with these informations for all current established connections.
Bases on this script you can also create small statistics about the parameter usage, like which applications uses OleDB?

TDS Version info:
   http://blogs.msdn.com/b/jenss/archive/2009/03/02/tds-protocol-versions-meet-client-stacks.aspx

TDS Versions list:
   http://msdn.microsoft.com/en-us/library/dd339982(PROT.13).aspx
   
Connection failure because of mismatched TDS version:
   http://blogs.msdn.com/b/sql_protocols/archive/2008/07/15/connection-failure-because-of-mismatched-tds-version.aspx
*/

-- Connectivity informations
;WITH con AS
   (SELECT SES.host_name AS HostName
          ,CON.client_net_address AS ClientAddress
          ,SES.login_name AS LoginName
          ,SES.program_name AS ProgramName
          ,EP.name AS ConnectionTyp
          ,CON.net_transport AS NetTransport
          ,CON.protocol_type AS ProtocolType
          ,CONVERT(VARBINARY(9), CON.protocol_version) AS TDSVersionHex
          ,SES.client_interface_name AS ClientInterface
          ,CON.encrypt_option AS IsEncryted
          ,CON.auth_scheme AS Auth
    FROM sys.dm_exec_connections AS CON
         LEFT JOIN sys.endpoints AS EP
             ON CON.endpoint_id = EP.endpoint_id
         INNER JOIN sys.dm_exec_sessions as SES
             ON CON.session_id = SES.session_id)
-- Detailed list
SELECT *
FROM con
-- Optional filter
--WHERE con.ClientInterface = 'ODBC'
ORDER by con.TDSVersionHex,con.HostName
        ,con.LoginName
        ,con.ProgramName;

/*
-- Count of different connectivity parameters
SELECT COUNT(*) AS [Connections #]
      ,COUNT(DISTINCT con.HostName) AS [Hosts #]
      ,COUNT(DISTINCT con.LoginName) AS [Logins #]
      ,COUNT(DISTINCT con.ProgramName) AS [Programs #]
      ,COUNT(DISTINCT con.NetTransport) AS [NetTransport #]
      ,COUNT(DISTINCT con.TDSVersionHex) AS [TdsVersions #]
      ,COUNT(DISTINCT con.ClientInterface) AS [ClientInterfaces #]
FROM con;
*/