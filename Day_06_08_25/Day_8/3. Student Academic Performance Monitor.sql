CREATE DATABASE StudentPerformance;

USE StudentPerformance;

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(100)
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100),
    PrerequisiteCourseID INT
);

CREATE TABLE Exams (
    ExamID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    Semester INT,
    Marks INT,
    ExamDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

INSERT INTO Students VALUES 
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO Courses VALUES
(101, 'Mathematics', NULL),
(102, 'Physics', 101),
(103, 'Chemistry', 101),
(104, 'Advanced Physics', 102);

INSERT INTO Exams VALUES 
(201, 1, 101, 1, 88, '2023-01-10'),
(202, 1, 102, 2, 91, '2023-06-15'),
(203, 1, 104, 3, 85, '2024-01-20'),
(204, 2, 101, 1, 75, '2023-01-11'),
(205, 2, 102, 2, 78, '2023-06-16'),
(206, 2, 103, 2, 82, '2023-06-18'),
(207, 3, 101, 1, 92, '2023-01-12'),
(208, 3, 102, 2, 95, '2023-06-14'),
(209, 3, 104, 3, 96, '2024-01-22');

-- track student grades across semesters
SELECT 
  s.StudentName,
  c.CourseName,
  e.Semester,
  e.Marks
FROM Exams e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
ORDER BY s.StudentName, e.Semester;

-- use RANK() to determine toppers in each subject
SELECT 
  c.CourseName,
  s.StudentName,
  e.Marks,
  RANK() OVER (PARTITION BY c.CourseName ORDER BY e.Marks DESC) AS SubjectRank
FROM Exams e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID;

-- use ROW_NUMBER() to show attempt order of exams
SELECT 
  s.StudentName,
  c.CourseName,
  e.Marks,
  ROW_NUMBER() OVER (PARTITION BY s.StudentID ORDER BY e.ExamDate) AS AttemptOrder
FROM Exams e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID;

-- use LEAD() and LAG() to compare marks between semesters
SELECT 
  s.StudentName,
  e.Semester,
  c.CourseName,
  e.Marks,
  LAG(e.Marks) OVER (PARTITION BY s.StudentID ORDER BY e.Semester) AS PreviousMarks,
  LEAD(e.Marks) OVER (PARTITION BY s.StudentID ORDER BY e.Semester) AS NextMarks
FROM Exams e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID;

-- create CTEs for subject-wise, semester-wise analysis
WITH SubjectAnalysis AS (
  SELECT 
    c.CourseName,
    AVG(e.Marks) AS AvgMarks
  FROM Exams e
  JOIN Courses c ON e.CourseID = c.CourseID
  GROUP BY c.CourseName
),
SemesterAnalysis AS (
  SELECT 
    Semester,
    AVG(Marks) AS AvgSemesterMarks
  FROM Exams
  GROUP BY Semester
)
SELECT * FROM SubjectAnalysis;
-- You can separately query SemesterAnalysis if needed.

-- use recursive CTE to navigate course prerequisites
WITH RECURSIVE CoursePath AS (
  SELECT 
    CourseID,
    CourseName,
    PrerequisiteCourseID,
    CAST(CourseName AS VARCHAR(500)) AS Path
  FROM Courses
  WHERE PrerequisiteCourseID IS NULL

  UNION ALL

  SELECT 
    c.CourseID,
    c.CourseName,
    c.PrerequisiteCourseID,
    CAST(cp.Path + ' → ' + c.CourseName AS VARCHAR(500))
  FROM Courses c
  JOIN CoursePath cp ON c.PrerequisiteCourseID = cp.CourseID
)
SELECT * FROM CoursePath;
