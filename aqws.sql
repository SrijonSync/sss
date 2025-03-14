create table medical(
PatientId VARCHAR(30),
AppointmentID INT,
Gender CHAR(1),
ScheduledDay TIMESTAMP,
AppointmentDay TIMESTAMP,
Age	INT,
Neighbourhood VARCHAR(100),
Scholarship BOOLEAN,
Hipertension BOOLEAN,
Diabetes BOOLEAN,
Alcoholism BOOLEAN,
Handcap BOOLEAN,
SMS_received BOOLEAN,
No_show BOOLEAN

);
--Find missing values in important columns
select * from medical;

select from medical where patientid is null
or AppointmentID is null
or 	ScheduledDay is null
	or AppointmentDay is null;

---- Duplictes

select patientid, Appointmentday, count(*)
from medical group by patientid, Appointmentday
having count(*) > 1;

---validation

SELECT DISTINCT No_show 
FROM medical;

--- Check for invalid Patient IDs (non-numeric or wrong format)
select * from medical where patientid not like '%[0-9]%';

---Ensure all ages are within a reasonable range (e.g., no negative or extreme values)

select * from medical where age < 0 or age > 120;


----Error Detection in Submissions


---Detect future-dated appointments (invalid scheduling)



select * from medical 
where appointmentday > ScheduledDay;

---Identify negative or unrealistic age values

select * from medical 
where age < 0;

----Check for patients who have an appointment scheduled but no valid AppointmentID

SELECT * 
FROM medical 
WHERE AppointmentID IS NULL;


---Ensure SMS_received values are only 0 or 1 (binary values)

SELECT DISTINCT SMS_received
FROM medical;


----Joins & Relationships (Cross-Checking Data)
---Find patients who scheduled an appointment but never attended
select PatientId, count(*) as missed
from medical 
where No_show = 'Yes'
group by PatientId
order by missed desc;

---- Identify patients with multiple appointments on the same day


select PatientId, AppointmentDay, count(*)
from medical 
group by PatientId, AppointmentDay having count(*) > 1;



----List all patients along with their neighborhood and no-show status

select PatientId,Neighbourhood, No_show from medical;

---Ensure every appointment has a valid PatientId and Age recorded

select * from medical where PatientId is null or Age is Null;




---Data Consistency & Anomaly Detection
---Detect outliers in Age (patients with extreme values)
select * from medical 
where Age > ( select avg(Age) +3 * stddev(age) from medical)
or Age < ( select avg(Age) -3 * stddev(age) from medical);




---Find patients with the highest number of missed appointments
select PatientId, count(*) as missed 
from medical
where No_show = 'Yes'
group by PatientId
order by missed desc;




---Identify patients who had multiple no-shows in the same neighborhood
select  Neighbourhood, count(*) as missed
from medical
where No_show = 'Yes'
 group by Neighbourhood
 order by missed desc;



---Check for unusually fast approval times (same ScheduledDay and AppointmentDay)

select from medical 
where ScheduledDay = AppointmentDay;



---Reporting & Aggregations

----Count total appointments per month
SELECT TO_CHAR(AppointmentDay, 'YYYY-MM') AS Month, COUNT(*) AS TotalAppointments
FROM medical
GROUP BY Month
ORDER BY Month;

----List the top 5 neighborhoods with the highest no-show rate
select Neighbourhood , count(*) as total,
sum(case when No_show = 'Yes' then 1 else 0 end) as noshow,
round((sum(case when No_show = 'Yes' then 1 else 0 end) * 100.0)/ count(*),2) as noshowrate

from medical
group by Neighbourhood
order by noshowrate desc limit 10;

 
----Find the percentage of patients who received an SMS but still didn’t show up
SELECT COUNT(*) AS TotalSMSNotAttended, 
       ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM medical_appointments WHERE SMS_received = 1), 2) AS Percentage 
FROM medical_appointments 
WHERE SMS_received = 1 AND "No-show" = 'Yes';
---
CREATE INDEX idx_patient ON medical (PatientId);
CREATE INDEX idx_appointment_date ON medical (AppointmentDay);

---
SELECT * 
FROM medical
WHERE PatientId = '12345678' 
   AND AppointmentDay >= '2024-01-01' 
   AND AppointmentDay <= '2024-02-01';
---
SELECT * 
FROM medical a
WHERE EXISTS (SELECT 1 
              FROM medical b 
              WHERE a.PatientId = b.PatientId 
                AND a.AppointmentDay = b.AppointmentDay 
              GROUP BY b.PatientId, b.AppointmentDay 
              HAVING COUNT(*) > 1);


