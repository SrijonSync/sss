-- Table CreationCREATE TABLE medical (
PatientId VARCHAR(30),
AppointmentID INT,
Gender CHAR(1),
ScheduledDay TIMESTAMP,
AppointmentDay TIMESTAMP,
Age INT,
Neighbourhood VARCHAR(100),
Scholarship BOOLEAN,
Hipertension BOOLEAN,
Diabetes BOOLEAN,
Alcoholism BOOLEAN,
Handcap BOOLEAN,
SMS_received BOOLEAN,
No_show BOOLEAN
);

-- Find missing values in important columns
SELECT * FROM medical
WHERE PatientId IS NULL
OR AppointmentID IS NULL
OR ScheduledDay IS NULL
OR AppointmentDay IS NULL;

-- Detect duplicates
SELECT PatientId, AppointmentDay, COUNT(*)
FROM medical
GROUP BY PatientId, AppointmentDay
HAVING COUNT(*) > 1;

-- Validation
SELECT DISTINCT No_show FROM medical;

-- Check for invalid Patient IDs (non-numeric or wrong format)
SELECT * FROM medical WHERE PatientId NOT LIKE '%[0-9]%';

-- Ensure all ages are within a reasonable range (e.g., no negative or extreme values)
SELECT * FROM medical WHERE Age < 0 OR Age > 120;

-- Error Detection in Submissions
-- Detect future-dated appointments (invalid scheduling)
SELECT * FROM medical WHERE AppointmentDay > ScheduledDay;

-- Identify negative or unrealistic age values
SELECT * FROM medical WHERE Age < 0;

-- Check for patients who have an appointment scheduled but no valid AppointmentID
SELECT * FROM medical WHERE AppointmentID IS NULL;

-- Ensure SMS_received values are only 0 or 1 (binary values)
SELECT DISTINCT SMS_received FROM medical;

-- Joins & Relationships (Cross-Checking Data)
-- Find patients who scheduled an appointment but never attended
SELECT PatientId, COUNT(*) AS missed
FROM medical 
WHERE No_show = 'Yes'
GROUP BY PatientId
ORDER BY missed DESC;

-- Identify patients with multiple appointments on the same day
SELECT PatientId, AppointmentDay, COUNT(*)
FROM medical 
GROUP BY PatientId, AppointmentDay 
HAVING COUNT(*) > 1;

-- List all patients along with their neighborhood and no-show status
SELECT PatientId, Neighbourhood, No_show FROM medical;

-- Ensure every appointment has a valid PatientId and Age recorded
SELECT * FROM medical WHERE PatientId IS NULL OR Age IS NULL;

-- Data Consistency & Anomaly Detection
-- Detect outliers in Age (patients with extreme values)
SELECT * FROM medical 
WHERE Age > (SELECT AVG(Age) + 3 * STDDEV(Age) FROM medical)
OR Age < (SELECT AVG(Age) - 3 * STDDEV(Age) FROM medical);

-- Find patients with the highest number of missed appointments
SELECT PatientId, COUNT(*) AS missed 
FROM medical
WHERE No_show = 'Yes'
GROUP BY PatientId
ORDER BY missed DESC;

-- Identify patients who had multiple no-shows in the same neighborhood
SELECT Neighbourhood, COUNT(*) AS missed
FROM medical
WHERE No_show = 'Yes'
GROUP BY Neighbourhood
ORDER BY missed DESC;

-- Check for unusually fast approval times (same ScheduledDay and AppointmentDay)
SELECT * FROM medical WHERE ScheduledDay = AppointmentDay;

-- Reporting & Aggregations
-- Count total appointments per month
SELECT TO_CHAR(AppointmentDay, 'YYYY-MM') AS Month, COUNT(*) AS TotalAppointments
FROM medical
GROUP BY Month
ORDER BY Month;

-- List the top 5 neighborhoods with the highest no-show rate
SELECT Neighbourhood, COUNT(*) AS total,
SUM(CASE WHEN No_show = 'Yes' THEN 1 ELSE 0 END) AS noshow,
ROUND((SUM(CASE WHEN No_show = 'Yes' THEN 1 ELSE 0 END)  100.0) / COUNT(), 2) AS noshowrate
FROM medical
GROUP BY Neighbourhood
ORDER BY noshowrate DESC
LIMIT 10;

-- Find the percentage of patients who received an SMS but still didn’t show up
SELECT COUNT(*) AS TotalSMSNotAttended, 
ROUND((COUNT()  100.0) / (SELECT COUNT(*) FROM medical WHERE SMS_received = 1), 2) AS Percentage 
FROM medical 
WHERE SMS_received = 1 AND No_show = 'Yes';

-- Indexing
CREATE INDEX idx_patient ON medical (PatientId);
CREATE INDEX idx_appointment_date ON medical (AppointmentDay);

-- Advanced Queries
-- Find records for a specific patient within a given date range
SELECT * 
FROM medical
WHERE PatientId = '12345678' 
AND AppointmentDay >= '2024-01-01' 
AND AppointmentDay <= '2024-02-01';

-- Identify patients who had multiple appointments on the same day using a subquery
SELECT * 
FROM medical a
WHERE EXISTS (SELECT 1 
FROM medical b 
WHERE a.PatientId = b.PatientId 
AND a.AppointmentDay = b.AppointmentDay 
GROUP BY b.PatientId, b.AppointmentDay 
HAVING COUNT(*) > 1);
