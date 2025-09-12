create database employee;
use employee;
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from Employee;
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;

-- Analysis Questions
-- 1. EMPLOYEE INSIGHTS
-- 1.1 How many unique employees are currently in the system?
select distinct count(emp_id) as unique_employees
from employee;

-- 1.2 Which departments have the highest number of employees?
select max(jobdept), count(jobdept) as employee_count
from jobdepartment
group by jobdept
order by count(jobdept) desc
limit 1;

-- 1.3 What is the average salary per department?
select jd.jobdept, avg(sb.amount) as avg_salary
from salarybonus sb
join jobdepartment jd on sb.job_id = jd.job_id
group by jd.jobdept;

-- 1.4 Who are the top 5 highest-paid employees?
select e.firstname, e.lastname, annual as highest_paid
from employee e
join salarybonus sb on e.job_id = sb.job_id
order by sb.amount desc
limit 5;

-- 1.5 What is the total salary expenditure across the company?
select sum(amount) as total_salary_expenditure
from salarybonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- 2.1 How many different job roles exist in each department?
select jobdept, count(job_id) as total_job_roles
from jobdepartment
group by jobdept;

-- 2.2 What is the average salary range per department?
select jd.jobdept, avg(sb.annual) as avg_salary
from jobdepartment jd
join salarybonus sb on jd.job_id = sb.job_id
group by jd.jobdept
order by avg_salary desc;

-- 2.3 Which job roles offer the highest salary?
select jd.name as job_role, max(sb.annual) as highest_salary
from jobdepartment jd
join salarybonus sb on jd.job_id = sb.job_id
group by jd.name
order by highest_salary desc
limit 1;

-- 2.4 Which departments have the highest total salary allocation?
select jd.jobdept, sum(annual) as total_salary
from jobdepartment jd
join salarybonus sb on jd.job_id = sb.job_id
group by jd.jobdept
order by total_salary desc
limit 1;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- 3.1 How many employees have at least one qualification listed?
select count(requirements) as employees_with_qualification
from qualification;

-- 3.2 Which positions require the most qualifications?
select position,requirements,length(requirements) as req_len
from qualification
order by req_len desc
limit 1;

-- 3.3 Which employees have the highest number of qualifications?
select e.emp_id, e.firstname, e.lastname, count(q.qualid) as num_qualifications
from employee e
join qualification q on e.emp_id = q.emp_id
group by e.emp_id, e.firstname, e.lastname
order by num_qualifications desc;


-- 4. LEAVE AND ABSENCE PATTERNS
-- 4.1 Which year had the most employees taking leaves?
select year(date) as leave_year, count(emp_id) as employees_on_leave
from leaves
group by year(date);

-- 4.2 What is the average number of leave days taken by its employees per department?
select jd.jobdept, avg(l.leave_id) as avg_leave_days
from leaves l 
inner join jobdepartment jd
on l.emp_id = jd.job_id
group by jd.jobdept;

-- 4.3 Which employees have taken the most leaves?
select firstname, e.lastname, count(l.leave_id) as total_leaves
from employee e
join leaves l on e.emp_id = l.emp_id
group by e.firstname, e.lastname;

-- 4.4 What is the total number of leave days taken company-wide?
select count(*) as total_leaves
from leaves;

-- 4.5 How do leave days correlate with payroll amounts?
SELECT e.emp_ID, COUNT(l.leave_ID) AS total_leaves, SUM(p.total_amount) AS total_payroll
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- 5.1 What is the total monthly payroll processed?
select year(p.date) as year,
       month(p.date) as month,
       sum(p.total_amount) as total_monthly_payroll
from payroll p
group by year(p.date), month(p.date);

-- 5.2 What is the average bonus given per department?
select jd.jobdept, avg(sb.bonus) as avg_bonus
from jobdepartment jd 
inner join salarybonus sb
on sb.job_id=jd.job_id
group by jd.jobdept;

-- 5.3 Which department receives the highest total bonuses?
select jd.jobdept, sum(sb.bonus) as total_bonus
from salarybonus sb
join jobdepartment jd on sb.job_id = jd.job_id
group by jd.jobdept
order by total_bonus desc
limit 1;

-- 5.4 What is the average value of total_amount after considering leave deductions?
select avg(total_amount) as avg_total_after_leave
from payroll;

-- 6. EMPLOYEE PERFORMANCE AND GROWTH
-- Which year had the highest number of employee promotions?
select count(sb.bonus) as total_bonus,year(p.date) 
from salarybonus sb
inner join payroll p
on sb.salary_id=p.salary_id
group by year(date);