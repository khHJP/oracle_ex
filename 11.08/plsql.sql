
--====================================================================
-- 11.08 (화)
--====================================================================
-- @ 실습문제

--1. EX_EMPLOYEE테이블에서 사번 마지막번호를 구한뒤, +1한 사번에 
--   사용자로 부터 입력받은 이름, 주민번호, 전화번호, 직급코드(J5), 급여등급(S5)를 등록하는 PLSQL을 작성하세요.
declare
    v_id ex_employee.emp_id%type;
    v_name ex_employee.emp_name%type = '&이름';
    v_no ex_employee.emp_no%type = '&주민번호';
    v_phone ex_employee.phone%type = '&전화번호';
begin
    select 
        emp_id + 1
    into
        v_id
    from 
        (select
            emp_id,
            rownum
         from
            ex_employee
         order by
            emp_id desc) 
    where 
        rownum = 1;

    insert into
        ex_employee (emp_id, emp_name, emp_no, job_code, sal_level)
    values( v_id, v_name, v_no, 'J5', 'S5');
end;

rollback;
select  from ex_employee;
   
-- 2. 동전 앞뒤맞추기 게임 익명블럭을 작성하세요.
-- dbms_random.value api 참고해 난수 생성할 것.

select
    trunc(dbms_random.value(1,3)) from dual; -- 1 ~ 3사이 랜덤 정수  1  2
    
declare
    user_coin number = '&앞_1_뒤_2';
    random_coin number;
begin
    select
        trunc(dbms_random.value(1,3))
    into
        random_coin
    from
        dual;   
    dbms_output.put_line('당신 '  user_coin);
    dbms_output.put_line('컴퓨터 '  random_coin);
    
    if user_coin = random_coin then
        dbms_output.put_line('맞췄습니다. 당신의 승리입니다.');
    else
        dbms_output.put_line('틀렸습니다. 당신의 패배입니다.');
    end if;
end;
