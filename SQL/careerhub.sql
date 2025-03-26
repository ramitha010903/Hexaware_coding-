create database careerhub;

use careerhub;
go

CREATE TABLE Companies (
    CompanyID INT PRIMARY KEY,
    CompanyName VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL
);

INSERT INTO Companies (CompanyID, CompanyName, Location) VALUES
(1, 'Hexaware', 'pune'),
(2, 'Green Solutions', 'San Francisco'),
(3, 'Health First', 'Chicago'),
(4, 'FinTech Corp', 'Boston'),
(5, 'EduLearn', 'Seattle');

CREATE TABLE Jobs (
    JobID INT PRIMARY KEY,
    CompanyID INT,
    JobTitle VARCHAR(255) NOT NULL,
    JobDescription TEXT,
    JobLocation VARCHAR(255) NOT NULL,
    Salary DECIMAL(10,2),
    JobType VARCHAR(50) NOT NULL,
    PostedDate DATETIME NOT NULL,
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID)
);

INSERT INTO Jobs (JobID, CompanyID, JobTitle, JobDescription, JobLocation, Salary, JobType, PostedDate) VALUES
(101, 1, 'Software Engineer', 'Develop and maintain web applications.', 'New York', 95000.00, 'Full-time', '2025-03-20 10:00:00'),
(102, 1, 'Data Analyst', 'Analyze large datasets and generate insights.', 'New York', 80000.00, 'Full-time', '2025-03-18 12:00:00'),
(103, 2, 'Environmental Consultant', 'Provide sustainable solutions for businesses.', 'San Francisco', 70000.00, 'Contract', '2025-03-22 09:30:00'),
(104, 3, 'Nurse Practitioner', 'Provide medical care to patients.', 'Chicago', 85000.00, 'Part-time', '2025-03-21 14:00:00'),
(105, 4, 'Financial Analyst', 'Analyze financial trends and market conditions.', 'Boston', 90000.00, 'Full-time', '2025-03-19 11:00:00'),
(106, 5, 'Math Teacher', 'Teach mathematics to high school students.', 'Seattle', 60000.00, 'Full-time', '2025-03-25 08:45:00');

CREATE TABLE Applicants (
    ApplicantID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Resume TEXT
);

INSERT INTO Applicants (ApplicantID, FirstName, LastName, Email, Phone, Resume) VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '1234567890', 'Experienced software engineer with a strong background in web development.'),
(2, 'Jane', 'Smith', 'jane.smith@email.com', '9876543210', 'Certified Data Analyst with expertise in SQL and Python.'),
(3, 'Emily', 'Johnson', 'emily.johnson@email.com', '4567891234', 'Environmental consultant with 5+ years of experience in sustainability.'),
(4, 'Michael', 'Brown', 'michael.brown@email.com', '3216549870', 'Finance expert with a strong understanding of investment strategies.'),
(5, 'Sarah', 'Davis', 'sarah.davis@email.com', '7891234567', 'Experienced teacher specializing in high school mathematics.');

CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY,
    JobID INT,
    ApplicantID INT,
    ApplicationDate DATETIME NOT NULL,
    CoverLetter TEXT,
    FOREIGN KEY (JobID) REFERENCES Jobs(JobID),
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID)
);

INSERT INTO Applications (ApplicationID, JobID, ApplicantID, ApplicationDate, CoverLetter) VALUES
(101, 101, 1, '2025-03-25 10:00:00', 'I am excited to apply for the Software Engineer position at Hexaware.'),
(102, 102, 2, '2025-03-24 11:30:00', 'I am very interested in the Data Analyst role at hexaware.'),
(103, 103, 3, '2025-03-23 14:45:00', 'My experience in environmental consulting aligns well with this role.'),
(104, 105, 4, '2025-03-22 09:15:00', 'I am eager to join FinTech Corp as a Financial Analyst.'),
(105, 106, 5, '2025-03-21 13:00:00', 'As a passionate educator, I would love to contribute to EduLearn.');

--5. Count the Number of Applications for Each Job Listing
SELECT j.JobTitle, 
       COALESCE(COUNT(a.ApplicationID), 0) AS ApplicationCount
FROM Jobs j
LEFT JOIN Applications a ON j.JobID = a.JobID
GROUP BY j.JobTitle;

--6. Retrieve Job Listings within a Salary Range
SELECT j.JobTitle, c.CompanyName, j.JobLocation, j.Salary
FROM Jobs j
JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE j.Salary BETWEEN 60000.00 AND 85000.00 ;

--7. Retrieve Job Application History for a Specific Applicant
SELECT j.JobTitle, c.CompanyName, a.ApplicationDate
FROM Applications a
JOIN Jobs j ON a.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE a.ApplicantID = 1
ORDER BY a.ApplicationDate DESC;

--8. Calculate and Display the Average Salary for All Job Listings (Excluding Zero Salary)
SELECT AVG(Salary) AS AverageSalary
FROM Jobs
WHERE Salary > 0;

--9. Identify the Company with the Most Job Listings
SELECT c.CompanyName, COUNT(j.JobID) AS JobCount
FROM Jobs j
JOIN Companies c ON j.CompanyID = c.CompanyID
GROUP BY c.CompanyName
HAVING COUNT(j.JobID) = (
    SELECT MAX(JobCount) 
    FROM (SELECT COUNT(JobID) AS JobCount FROM Jobs GROUP BY CompanyID) AS JobCounts
);

--10. Find the applicants who have applied for positions in companies located in 'CityX' and have at least 3 years of experience.
SELECT DISTINCT a.ApplicantID, a.FirstName, a.LastName, a.Email
FROM Applications app
JOIN Jobs j ON app.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID
JOIN Applicants a ON app.ApplicantID = a.ApplicantID
WHERE c.Location = 'pune' AND a.Resume LIKE '%3 years%' OR a.Resume LIKE '%4 years%' 
   OR a.Resume LIKE '%5 years%' OR a.Resume LIKE '%more than 3 years%';

--11. Retrieve a list of distinct job titles with salaries between $60,000 and $80,000.
SELECT DISTINCT JobTitle
FROM Jobs
WHERE Salary BETWEEN 60000 AND 80000;

--12. Find the jobs that have not received any applications.
SELECT j.JobID, j.JobTitle, j.JobLocation, c.CompanyName
FROM Jobs j
JOIN Companies c ON j.CompanyID = c.CompanyID
LEFT JOIN Applications a ON j.JobID = a.JobID
WHERE a.ApplicationID IS NULL;

--13. Retrieve a list of job applicants along with the companies they have applied to and the positions they have applied for.
SELECT a.FirstName, a.LastName, c.CompanyName, j.JobTitle
FROM Applications app
JOIN Applicants a ON app.ApplicantID = a.ApplicantID
JOIN Jobs j ON app.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID;

--14. Retrieve a list of companies along with the count of jobs they have posted, even if they have not received any applications.
SELECT c.CompanyName, COUNT(j.JobID) AS JobCount
FROM Companies c
LEFT JOIN Jobs j ON c.CompanyID = j.CompanyID
GROUP BY c.CompanyName;

--15. List all applicants along with the companies and positions they have applied for, including those who have not applied.
SELECT a.FirstName, a.LastName, COALESCE(c.CompanyName, 'No Application') AS CompanyName, 
       COALESCE(j.JobTitle, 'No Position Applied') AS JobTitle
FROM Applicants a
LEFT JOIN Applications app ON a.ApplicantID = app.ApplicantID
LEFT JOIN Jobs j ON app.JobID = j.JobID
LEFT JOIN Companies c ON j.CompanyID = c.CompanyID;

--16. Find companies that have posted jobs with a salary higher than the average salary of all jobs.
SELECT DISTINCT c.CompanyName
FROM Jobs j
JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE j.Salary > (SELECT AVG(Salary) FROM Jobs WHERE Salary > 0);

--17. Display a list of applicants with their names and a concatenated string of their city and state.
SELECT a.FirstName, a.LastName
FROM Applicants a;

--18. Retrieve a list of jobs with titles containing either 'Developer' or 'Engineer'.
SELECT JobID, JobTitle, Salary
FROM Jobs
WHERE JobTitle LIKE '%Developer%' OR JobTitle LIKE '%Engineer%';

--19. Retrieve a list of applicants and the jobs they have applied for, including those who have not applied and jobs without applicants.
SELECT a.FirstName, a.LastName, COALESCE(j.JobTitle, 'No Job Applied') AS JobTitle
FROM Applicants a
FULL OUTER JOIN Applications app ON a.ApplicantID = app.ApplicantID
FULL OUTER JOIN Jobs j ON app.JobID = j.JobID;

--20. List All Combinations of Applicants and Companies Where the Company is in a Specific City and the Applicant Has More Than 2 Years of Experience (Example: Chennai)
SELECT a.FirstName, a.LastName, c.CompanyName
FROM Applicants a
CROSS JOIN Companies c
WHERE c.Location = 'Chennai'
AND (a.Resume LIKE '%3 years%' OR a.Resume LIKE '%4 years%' OR a.Resume LIKE '%5 years%' 
     OR a.Resume LIKE '%more than 2 years%');













