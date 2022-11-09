--====================================================================
-- 11.09 (수)
--====================================================================
--@실습문제 - pl/sql 제어문, function, procedure
/*
1. 사번을 입력받고, 관리자에 대한 성과급을 지급하려하는 익명블럭 작성
    - 관리하는 사원이 5명이상은 급여의 15% 지급 : '성과급은 ??원입니다.'
    - 관리하는 사원이 5명미만은 급여의 10% 지급 : ' 성과급은 ??원입니다.'
    - 관리하는 사원이 없는 경우는 '대상자가 아닙니다.'
*/

declare
    v_emp_id employee.emp_id%type := '&사번';
    v_cnt_manage number;
    v_sal employee.salary%type;
begin
    select -- 관리하는사원수
        count(*)
    into
        v_cnt_manage
    from
        employee
    where
        manager_id = v_emp_id;
    
    select -- 월급
        salary
    into 
        v_sal
    from
        employee
    where
        emp_id = v_emp_id;
        
    case
        when v_cnt_manage >= 5 then
            dbms_output.put_line('성과급은 ' || v_sal * 0.15 || '원 입니다.');
        when v_cnt_manage < 5 and v_cnt_manage > 0 then
            dbms_output.put_line('성과급은 ' || v_sal * 0.1 || '원 입니다.');
        else dbms_output.put_line('대상자가 아닙니다.');
    end case;
end;
/


-- self-join으로 select구문 한개만 사용
declare
    v_emp_id employee.emp_id%type := '&사번';
    v_cnt_manage number;
    v_sal employee.salary%type;
begin
    select
        count(*), e.salary
    into
        v_cnt_manage, v_sal
    from
        employee e join employee m
            on e.emp_id = m.manager_id
    where
        e.emp_id = v_emp_id
    group by
        e.emp_id, e.salary;
        
    case
        when v_cnt_manage >= 5 then
            dbms_output.put_line('성과급은 ' || v_sal * 0.15 || '원 입니다.');
        when v_cnt_manage < 5 and v_cnt_manage > 0 then
            dbms_output.put_line('성과급은 ' || v_sal * 0.1 || '원 입니다.');
        else dbms_output.put_line('대상자가 아닙니다.');
    end case;
end;
/


--2. TBL_NUMBER 테이블에 0~99사이의 난수를 100개 저장하고, 입력된 난수의 합계를 출력하는 익명블럭을 작성하세요.
/*
    TBL_NUMBER테이블(sh 계정)을 먼저 생성후 작업하세요.
    - id number pk : sequence객체 생성후 채번할것.
    - num number : 난수
    - reg_date date : 기본값 현재시각
*/
create sequence seq_tbl_number_id;

create table TBL_NUMBER(
    id number,
    num number,
    reg_date date default sysdate,  
    constraint pk_tbl_number_id primary key(id)
);

--drop table TBL_NUMBER;

-- @ while 반복문 + 반복문 내에서 합 계산
declare
    i number := 1;
    ran_no number;
    sum_no number := 0;
begin
    while i <= 100 loop
        ran_no := trunc(dbms_random.value(-1,100));
        
        insert into TBL_NUMBER(id, num) 
            values (seq_tbl_number_id.nextval, ran_no);
        i := i + 1;
        sum_no := sum_no + ran_no;
    end loop;
--    commit;
    dbms_output.put_line('합계: ' || sum_no);   
end;
/


-- @ for..in 반복문 + 테이블에서 합 가져오기
declare
    sum_no number;
begin
    for i in 1..100 loop
        insert into TBL_NUMBER(id, num) values(seq_tbl_number_id.nextval, trunc(dbms_random.value(-1,100)));
    end loop;
--    commit;
    select
        sum(num)
    into
        sum_no
    from
        TBL_NUMBER;
     dbms_output.put_line('합계: ' || sum_no);   
end;
/


--3.주민번호를 입력받아 나이를 리턴하는 저장함수 fn_age를 사용해서 사번, 이름, 성별, 연봉, 나이를 조회
create or replace function fn_age (
    f_emp_no employee.emp_no%type
)
return number
is
    birth_yr number;
    age number;
begin
    if substr(f_emp_no, 8, 1) = 1 or substr(f_emp_no, 8, 1) = 2 then
        birth_yr := 1900;
    else birth_yr := 2000;
    end if;
    
    age := (extract(year from sysdate)) - (birth_yr + substr(f_emp_no, 1, 2)) + 1;
    
    return age;
end;
/

select 
    emp_id 사번,
    emp_name 이름,
    fn_gender(emp_no) 성별,
    to_char(fn_calc_annual_pay(salary, bonus), 'FML999,999,999,999') 연봉,
    fn_age(emp_no) 나이
from
    employee;


--4. 특별상여금을 계산하는 함수 fn_calc_incentive(salary, hire_date)를 생성하고, 사번, 사원명, 입사일, 근무개월수(n년 m월), 특별상여금 조회
        --* 입사일 기준 10년이상이면, 급여 150%
        --* 입사일 기준 10년 미만 3년이상이면, 급여 125%
        --* 입사일 기준 3년미만, 급여 50%
create or replace function fn_calc_incentive (
    f_salary employee.salary%type,
    f_hire_date employee.hire_date%type
)
return varchar2
is
    incentive varchar2(15);
    work_yr number;
begin
    work_yr := trunc(months_between(sysdate, f_hire_date) / 12);
    if work_yr >= 10 then
        incentive := to_char(f_salary * 1.5, 'FML999,999,999');
    elsif work_yr < 10 then
        incentive := to_char(f_salary * 1.25, 'FML999,999,999');
    else
        incentive := to_char(f_salary * 0.5, 'FML999,999,999');
    end if;
    return incentive;
end;
/

select
    emp_id 사번,
    emp_name 사원명,
    hire_date 입사일,
    trunc(months_between(sysdate, hire_date) / 12) || '년' || trunc(mod(months_between(sysdate, hire_date), 12)) || '개월' 근무개월수,
    fn_calc_incentive(salary, hire_date) 특별상여금
from
    employee;
