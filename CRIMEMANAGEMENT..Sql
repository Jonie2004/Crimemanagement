-- Drop the database if it exists
DROP DATABASE IF EXISTS CrimeManagement;

-- Create the database
CREATE DATABASE CrimeManagement;
USE CrimeManagement;

-- Create the Crime table
CREATE TABLE Crime (
    CrimeID INT PRIMARY KEY,
    IncidentType VARCHAR(255),
    IncidentDate DATE,
    Location VARCHAR(255),
    Description TEXT,
    Status VARCHAR(20)
);

-- Create the Victim table
CREATE TABLE Victim (
    VictimID INT PRIMARY KEY,
    CrimeID INT,
    Name VARCHAR(255),
    ContactInfo VARCHAR(255),
    Injuries VARCHAR(255),
    Age INT,
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Create the Suspect table
CREATE TABLE Suspect (
    SuspectID INT PRIMARY KEY,
    CrimeID INT,
    Name VARCHAR(255),
    Description TEXT,
    CriminalHistory TEXT,
    Age INT,
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Insert sample data into Crime
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
    (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
    (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
    (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

-- Insert sample data into Victim
INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries, Age)
VALUES
    (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries', 35),
    (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased', 28),
    (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None', 30);

-- Insert sample data into Suspect
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory, Age)
VALUES
    (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions', 40),
    (2, 2, 'Unknown', 'Investigation ongoing', NULL, 0),
    (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests', 35);

-- 1. Select all open incidents
SELECT * FROM Crime WHERE Status = 'Open';

-- 2. Find the total number of incidents
SELECT COUNT(*) AS TotalIncidents FROM Crime;

-- 3. List all unique incident types
SELECT DISTINCT IncidentType FROM Crime;

-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'
SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';

-- 5. List persons involved in incidents in descending order of age
SELECT Name, Age, 'Victim' AS Role FROM Victim
UNION
SELECT Name, Age, 'Suspect' AS Role FROM Suspect
ORDER BY Age DESC;

-- 6. Find the average age of persons involved in incidents
SELECT AVG(Age) AS AverageAge FROM (
    SELECT Age FROM Victim
    UNION ALL
    SELECT Age FROM Suspect
) AS CombinedAges;

-- 7. List incident types and their counts, only for open cases
SELECT IncidentType, COUNT(*) AS Count
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType;

-- 8. Find persons with names containing 'Doe'
SELECT Name FROM Victim WHERE Name LIKE '%Doe%'
UNION
SELECT Name FROM Suspect WHERE Name LIKE '%Doe%';

-- 9. Retrieve the names of persons involved in open or closed cases
SELECT V.Name, 'Victim' AS Role, C.Status
FROM Victim V JOIN Crime C ON V.CrimeID = C.CrimeID
WHERE C.Status IN ('Open', 'Closed')
UNION
SELECT S.Name, 'Suspect' AS Role, C.Status
FROM Suspect S JOIN Crime C ON S.CrimeID = C.CrimeID
WHERE C.Status IN ('Open', 'Closed');

-- 10. List incident types where there are persons aged 30 or 35 involved
SELECT DISTINCT C.IncidentType
FROM Crime C
LEFT JOIN Victim V ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE V.Age IN (30, 35) OR S.Age IN (30, 35);

-- 11. Find persons involved in incidents of the same type as 'Robbery'
SELECT V.Name, 'Victim' AS Role FROM Victim V
JOIN Crime C ON V.CrimeID = C.CrimeID
WHERE C.IncidentType = 'Robbery'
UNION
SELECT S.Name, 'Suspect' AS Role FROM Suspect S
JOIN Crime C ON S.CrimeID = C.CrimeID
WHERE C.IncidentType = 'Robbery';

-- 12. List incident types with more than one open case
SELECT IncidentType, COUNT(*) AS Count
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType
HAVING COUNT(*) > 1;

-- 13. List all incidents with suspects whose names also appear as victims
SELECT DISTINCT C.*
FROM Crime C
JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE S.Name IN (
    SELECT Name FROM Victim
);

-- 14. Retrieve all incidents along with victim and suspect details
SELECT C.CrimeID, C.IncidentType, C.IncidentDate, C.Location, C.Status,
       V.Name AS VictimName, V.ContactInfo, V.Injuries,
       S.Name AS SuspectName, S.Description, S.CriminalHistory
FROM Crime C
LEFT JOIN Victim V ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID;

-- 15. Find incidents where the suspect is older than any victim
SELECT DISTINCT C.*
FROM Crime C
JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE S.Age > ALL (
    SELECT V.Age FROM Victim V WHERE V.CrimeID = C.CrimeID
);

-- 16. Find suspects involved in multiple incidents
SELECT Name, COUNT(*) AS IncidentCount
FROM Suspect
GROUP BY Name
HAVING COUNT(*) > 1;

-- 17. List incidents with no suspects involved
SELECT * FROM Crime
WHERE CrimeID NOT IN (SELECT DISTINCT CrimeID FROM Suspect);

-- 18. List cases where at least one incident is 'Homicide' and all others are 'Robbery'
SELECT * FROM Crime
WHERE EXISTS (
    SELECT 1 FROM Crime WHERE IncidentType = 'Homicide'
)
AND NOT EXISTS (
    SELECT 1 FROM Crime WHERE IncidentType NOT IN ('Homicide', 'Robbery')
);

-- 19. List all incidents and associated suspects, or 'No Suspect' if none
SELECT C.CrimeID, C.IncidentType, C.IncidentDate, C.Status,
       IFNULL(S.Name, 'No Suspect') AS SuspectName
FROM Crime C
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID;

-- 20. List all suspects involved in 'Robbery' or 'Assault' incidents
SELECT S.*
FROM Suspect S
JOIN Crime C ON S.CrimeID = C.CrimeID
WHERE C.IncidentType IN ('Robbery', 'Assault');
