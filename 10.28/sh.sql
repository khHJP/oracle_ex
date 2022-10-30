--====================================================================
-- 10.28 (금)
--====================================================================
--@실습문제
--1. 2020년 12월 25일이 무슨 요일인지 조회하시오.
-- 금요일
select
    to_char(to_date('2020/12/25', 'yyyy/mm/dd'), 'day')
from
    dual; 

--2. 주민번호가 70년대 생이면서 성별이 여자이고, 성이 전씨인 직원들의 사원명, 주민번호, 부서명, 직급명을 조회하시오.
-- 1 전지연
select
    e.emp_name 사원명,
    e.emp_no 주민번호,
    d.dept_title 부서명,
    j.job_name 직급명   
from
    employee e left join job j
        on e.job_code = j.job_code
    left join department d
        on e.dept_code = d.dept_id
where
    substr(emp_no,1,1) = '7'
    and
    substr(emp_no,8,1) in ('2', '4')
    and
    emp_name like '전%'; 

--3. 가장 나이가 적은 직원의 사번, 사원명, 나이, 부서명, 직급명을 조회하시오.
-- 1 송은희
select
    e.emp_id 사번,
    e.emp_name 사원명,
    (extract(year from sysdate)) - (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2)) + 1 나이,
    d.dept_title 부서명,
    j.job_name 직급명
from
    job j join employee e
        on j.job_code = e.job_code
    left join department d
        on e.dept_code = d.dept_id
where
     (extract(year from sysdate)) - (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2)) + 1 
     = (select min((extract(year from sysdate)) - (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2)) + 1) from employee);


--4. 이름에 '형'자가 들어가는 직원들의 사번, 사원명, 부서명을 조회하시오.
-- 1 전형돈
select
    e.emp_id 사번,
    e.emp_name 사원명,
    d.dept_title 부서명
from
    employee e left join department d
        on e.dept_code = d.dept_id
where
    e.emp_name like '%형%'; 


--5. 해외영업팀에 근무하는 사원명, 직급명, 부서코드, 부서명을 조회하시오.
-- 9
select
    e.emp_name 사원명,
    j.job_name 직급명,
    e.dept_code 부서코드,
    d.dept_title 부서명    
from
    employee e left join job j
        on e.job_code = j.job_code
    left join department d
        on e.dept_code = d.dept_id
where
    d.dept_title like '해외영업%';


--6. 보너스포인트를 받는 직원들의 사원명, 보너스포인트, 부서명, 근무지역명을 조회하시오.
-- 9
select
    e.emp_name 사원명,
    e.bonus 보너스포인트,
    nvl(d.dept_title, '미정') 부서명,
    nvl(l.local_name, '미정') 근무지역명
from
    employee e left join department d 
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
where
    bonus is not null;


--7. 부서코드가 D2인 직원들의 사원명, 직급명, 부서명, 근무지역명을 조회하시오.
-- 4
select * from location;
select
    e.dept_code 부서코드,
    e.emp_name 사원명,
    j.job_name 직급명,
    nvl(d.dept_title, '미정') 부서명,
    nvl(l.local_name, '미정') 근무지역명
from
    employee e left join job j
        on e.job_code = j.job_code
    left join department d 
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
where
    e.dept_code = 'D2';


--8. 급여등급테이블의 등급별 최대급여(MAX_SAL)보다 많이 받는 직원들의 사원명, 직급명, 급여, 연봉을 조회하시오.
--(사원테이블과 급여등급테이블을 SAL_LEVEL컬럼기준으로 동등 조인할 것)
-- 1 고두밋
select * from sal_grade;
select
    e.emp_name 사원명,
    j.job_name 직급명,
    to_char(e.salary,'FML999,999,999' ) 급여,
    to_char(12 * (salary + salary * nvl(bonus,0)), 'FML999,999,999,999') 연봉
from
    job j join employee e 
        on j.job_code = e.job_code
    join sal_grade s
        on e.sal_level = s.sal_level
where
    e.salary > s.max_sal;

    
--9. 한국(KO)과 일본(JP)에 근무하는 직원들의 사원명, 부서명, 지역명, 국가명을 조회하시오.
-- 16
select
    e.emp_name 사원명,
    d.dept_title 부서명,
    l.local_name 지역명,
    n.national_name 국가명
from
    employee e left join department d
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
    left join nation n
        on l.national_code = n.national_code
where
    n.national_name in ('한국', '일본');
    

--10. 같은 부서에 근무하는 직원들의 사원명, 부서코드, 동료이름을 조회하시오.
--self join 사용
-- 66
select
    e.emp_name 사원명,
    e.dept_code 부서코드,
    d.emp_name 동료이름
from
    employee e join employee d
        on e.dept_code = d.dept_code
where
    e.emp_name != d.emp_name
order by
    2,1;


--11. 보너스포인트가 없는 직원들 중에서 직급이 차장과 사원인 직원들의 사원명, 직급명, 급여를 조회하시오.
-- 8
select 
    emp_name 사원명,
    job_name 직급명,
    to_char(salary, 'fml999,999,999') 급여
from
    employee e join job j
        on e.job_code = j.job_code
where
    e.bonus is null and
    j.job_name in ('차장', '사원');


--12. 재직중인 직원과 퇴사한 직원의 수를 조회하시오.
-- 퇴사 1, 재직 23
select
    decode(quit_yn, 'Y', '퇴사자', 'N', '재직자'),
    count(*)
from
    employee
group by
    decode(quit_yn, 'Y', '퇴사자', 'N', '재직자');
