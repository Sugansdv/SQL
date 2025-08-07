CREATE DATABASE CallCenterReporting;

USE CallCenterReporting;

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    StaffName VARCHAR(100),
    Role VARCHAR(50),
    ReportsTo INT
);

CREATE TABLE SupportTickets (
    TicketID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    AssignedTo INT,
    EscalationTime DATETIME,
    ResolutionTime DATETIME,
    FOREIGN KEY (AssignedTo) REFERENCES Staff(StaffID)
);


INSERT INTO Staff VALUES
(1, 'Alice', 'Agent', 2),
(2, 'Bob', 'Supervisor', 3),
(3, 'Charlie', 'Manager', NULL),
(4, 'David', 'Agent', 2),
(5, 'Eva', 'Supervisor', 3);

INSERT INTO SupportTickets VALUES
(101, 'John Doe', 1, '2025-08-01 10:00:00', '2025-08-01 11:30:00'),
(102, 'Jane Smith', 1, '2025-08-01 12:00:00', '2025-08-01 13:00:00'),
(103, 'Tom Hill', 4, '2025-08-01 09:30:00', '2025-08-01 11:00:00'),
(104, 'Sam Lee', 1, '2025-08-01 14:00:00', '2025-08-01 15:15:00'),
(105, 'Mary Joe', 4, '2025-08-01 16:00:00', '2025-08-01 17:45:00'),
(106, 'Anna Ray', 4, '2025-08-02 10:30:00', '2025-08-02 12:00:00');

-- escalation levels: Agent → Supervisor → Manager
SELECT 
  s1.StaffName AS Agent,
  s2.StaffName AS Supervisor,
  s3.StaffName AS Manager
FROM Staff s1
LEFT JOIN Staff s2 ON s1.ReportsTo = s2.StaffID
LEFT JOIN Staff s3 ON s2.ReportsTo = s3.StaffID
WHERE s1.Role = 'Agent';

-- use recursive CTE to show escalation flow
WITH RECURSIVE EscalationChain AS (
  SELECT 
    StaffID,
    StaffName,
    Role,
    ReportsTo,
    CAST(StaffName AS CHAR(500)) AS EscalationPath
  FROM Staff
  WHERE ReportsTo IS NULL

  UNION ALL

  SELECT 
    s.StaffID,
    s.StaffName,
    s.Role,
    s.ReportsTo,
    CAST(ec.EscalationPath + ' → ' + s.StaffName AS CHAR(500))
  FROM Staff s
  JOIN EscalationChain ec ON s.ReportsTo = ec.StaffID
)
SELECT * FROM EscalationChain;

-- use ROW_NUMBER() to order support interactions
SELECT 
  st.CustomerName,
  st.TicketID,
  s.StaffName,
  st.EscalationTime,
  ROW_NUMBER() OVER (PARTITION BY st.AssignedTo ORDER BY st.EscalationTime) AS InteractionOrder
FROM SupportTickets st
JOIN Staff s ON st.AssignedTo = s.StaffID;

-- use RANK() to find most escalated agents
WITH AgentTicketCount AS (
  SELECT 
    AssignedTo,
    COUNT(*) AS TotalTickets
  FROM SupportTickets
  GROUP BY AssignedTo
)
SELECT 
  s.StaffName,
  s.Role,
  atc.TotalTickets,
  RANK() OVER (ORDER BY atc.TotalTickets DESC) AS EscalationRank
FROM AgentTicketCount atc
JOIN Staff s ON atc.AssignedTo = s.StaffID
WHERE s.Role = 'Agent';

-- compare issue resolution time with LAG()
SELECT 
  s.StaffName,
  st.TicketID,
  st.EscalationTime,
  st.ResolutionTime,
  DATEDIFF(MINUTE, st.EscalationTime, st.ResolutionTime) AS ResolutionMinutes,
  LAG(DATEDIFF(MINUTE, st.EscalationTime, st.ResolutionTime)) OVER (PARTITION BY s.StaffID ORDER BY st.EscalationTime) AS PreviousResolutionMinutes
FROM SupportTickets st
JOIN Staff s ON st.AssignedTo = s.StaffID;
