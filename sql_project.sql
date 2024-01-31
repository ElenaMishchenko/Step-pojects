/*
Запити
1. Покажіть середню зарплату працівників за кожен рік (середня заробітна плата серед тих, хто працював у звітний період – статистика з початку до 2005 року).
2. Покажіть середню зарплату працівників у кожному відділу. Примітка: прийняти в розрахунок лише поточні відділи та поточну заробітну плату.
3. Покажіть середню зарплату працівників по кожному відділу за кожний рік.Примітка: для середньої зарплати відділу X року Y нам потрібно взяти середнє значення 
   всіх зарплат у році Y працівників, які були у відділі X у році Y.
4. Покажіть для кожного року найбільший відділ (за кількістю співробітників) у цьому року та його середню зарплату.
5. Покажіть детальну інформацію про менеджера, який найдовше виконує свої обов'язки зараз.
6. Покажіть топ-10 нинішніх співробітників компанії з найбільшою різницею між їхньою зарплатою та поточною середньою зарплатою у їхньому відділі.
*/
#1. Покажіть середню зарплату працівників за кожен рік (середня заробітна плата серед тих, хто працював у звітний період – статистика з початку до 2005 року).
USE employees;
SELECT YEAR (s.to_date) AS 'Period',
	round(AVG(s.salary),2) AS 'AVG_salary'
FROM salaries AS s
GROUP BY 1
ORDER BY 1; 
/*
# Period, AVG_salary
'9999', '72013.57'
'2023', '61722.60'
'2002', '70558.69'
'2001', '68597.54'
'2000', '66550.07'
'1999', '65533.21'
'1998', '64567.47'
'1997', '63616.07'
'1996', '62687.58'
'1995', '61730.12'
'1994', '60756.95'
'1993', '59778.09'
'1992', '58796.79'
'1991', '57844.48'
'1990', '56849.80'
'1989', '55871.65'
'1988', '54967.98'
'1987', '54104.23'
'1986', '53182.99'
'1985', '51542.78'
*/
#2. Покажіть середню зарплату працівників у кожному відділу. Примітка: прийняти в розрахунок лише поточні відділи та поточну заробітну плату.
SELECT dept_name AS 'DEPARTMENT',
	round(AVG(s.salary),2) AS 'AVG_salary_current'
FROM salaries AS s
LEFT JOIN dept_emp AS de ON (s.emp_no = de.emp_no AND curdate() BETWEEN de.from_date AND de.to_date 
                            AND curdate() BETWEEN s.from_date AND s.to_date )    
INNER JOIN departments USING(dept_no)
GROUP BY dept_name;
/*
DEPARTMENT, AVG_salary_current
'Development', '67659.16'
'Customer Service', '67287.43'
'Production', '67847.21'
'Human Resources', '63922.61'
'Research', '67914.18'
'Quality Management', '65442.88'
'Sales', '88852.75'
'Marketing', '80058.85'
'Finance', '78559.94'
*/
# Покажіть середню зарплату працівників по кожному відділу за кожний рік.
# Примітка: для середньої зарплати відділу X року Y нам потрібно взяти середнє значення 
# всіх зарплат у році Y працівників, які були у відділі X у році Y.
SELECT d.dept_name AS 'DEPARTMENT',
	year(s.from_date) AS 'PERIOD',
    round(AVG(s.salary),2) AS 'AVG_Salary'
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no=de.emp_no)
INNER JOIN departments AS d ON (de.dept_no=d.dept_no)
	WHERE s.from_date=de.from_date
GROUP BY 1,2
ORDER BY 1;  
/*
# DEPARTMENT, PERIOD, AVG_Salary
'Customer Service', '1985', '44157.73'
'Customer Service', '1986', '43938.22'
'Customer Service', '1987', '43754.86'
'Customer Service', '1988', '43435.11'
....................................
'Sales',           '2001', '67399.00'
'Sales',           '2023', '76500.00'

*/
# 4. Покажіть для кожного року найбільший відділ (за кількістю співробітників) у цьому року та його середню зарплату.
WITH max_dept_CTE(PERIOD,  DEPARTAMENT, Quantity_emp_no,  AVG_salary )  AS (                          
	SELECT YEAR(de.from_date), de.dept_no, 	COUNT(de.emp_no), ROUND(AVG(s.salary),0)	
    FROM dept_emp AS de 	
	INNER JOIN salaries AS s ON (de.emp_no =s.emp_no  
                        AND YEAR(de.from_date) = YEAR(s.from_date))	
GROUP BY 1,2	
ORDER BY 1 ,3 DESC) /* Кількість співробітників та середня зарплата по відділам за кожен рік*/
SELECT *
FROM max_dept_CTE
GROUP BY 1;
/*
1985	d005	5092	48754
1986	d005	5456	48793
1987	d005	5584	48744
1988	d005	5534	48762
1989	d005	5753	48718
1990	d005	5608	48767
1991	d005	5539	48772
1992	d005	5843	48816
1993	d005	5613	48875
1994	d005	5620	48797
1995	d005	5747	48979
1996	d005	5854	48997
1997	d005	5766	49044
1998	d005	5733	49015
1999	d005	5738	49363
2000	d004	1216	56231
2001	d004	792	61249
2002	d004	253	62697
2023	d006	5	71000
*/

 # 5. Покажіть детальну інформацію про менеджера, який найдовше виконує свої обов'язки зараз.
WITH max_daysCTE AS (SELECT *, timestampdiff(DAY,from_date, curdate()) AS days
	FROM dept_manager 
	WHERE curdate() BETWEEN from_date AND to_date
	ORDER BY days DESC
	LIMIT 1)
SELECT * FROM employees 
INNER JOIN max_daysCTE USING(emp_no);
/*
# emp_no, birth_date, first_name, last_name, gender, hire_date, dept_no, from_date, to_date, days
'110114', '1957-03-28', 'Isamu', 'Legleitner', 'F', '1985-01-14', 'd002', '1989-12-17', '9999-01-01', '12353'
*/
# 6. Покажіть топ-10 нинішніх співробітників компанії з найбільшою різницею між їхньою зарплатою та поточною середньою зарплатою у їхньому відділі.
WITH maxsalary_diffCTE(emp_no, salary, dept_no,avg_salary, diff_avgsal_sal) AS
(SELECT es.emp_no,es.salary, ed.dept_no,
 round(AVG(salary) OVER (PARTITION BY ed.dept_no),2) AS avg_salary, round((es.salary - AVG(es.salary) OVER (PARTITION BY ed.dept_no)),2) AS diff_avgsal_sal
 FROM salaries AS es
 INNER JOIN dept_emp AS ed ON (es.emp_no = ed.emp_no AND curdate() BETWEEN ed.from_date  AND ed.to_date 
 AND curdate() BETWEEN es.from_date  AND es.to_date)
)
SELECT emp_no, dept_no,salary,avg_salary, diff_avgsal_sal
FROM maxsalary_diffCTE
ORDER BY diff_avgsal_sal DESC
LIMIT 10; 
/*
# emp_no, dept_no, salary, avg_salary, diff_avgsal_sal
'421835', 'd003', '141953', '63922.61', '78030.39'
'18006', 'd009', '144866', '67287.43', '77578.57'
'13386', 'd005', '144434', '67659.16', '76774.84'
'96957', 'd009', '143950', '67287.43', '76662.57'
'432583', 'd009', '143937', '67287.43', '76649.57'
'98169', 'd009', '143832', '67287.43', '76544.57'
'485205', 'd009', '141555', '67287.43', '74267.57'
'419748', 'd005', '140784', '67659.16', '73124.84'
'28337', 'd009', '138788', '67287.43', '71500.57'
'235645', 'd009', '138637', '67287.43', '71349.57'
*/












