-- LIMIT AND ALIASING

SELECT *
FROM employee_demographics
ORDER BY age 
LIMIT 5 , 2
; 

-- ALIASING
SELECT gender , AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING avg_age > 40
; 