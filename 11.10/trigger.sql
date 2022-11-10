--====================================================================
-- 11.10 (목)
--====================================================================
--@ TRIGGER 
/*
1. EMPLOYEE테이블의 퇴사자관리를 별도의 테이블 TBL_EMP_QUIT에서 하려고 한다.
다음과 같이 TBL_EMP_JOIN, TBL_EMP_QUIT테이블을 생성하고, 
TBL_EMP_JOIN에서 DELETE시 자동으로 퇴사자 데이터가 TBL_EMP_QUIT에 INSERT되도록 트리거를 생성하라.
- DELETE 처리는 사번으로! 보통 PK값으로 행을 찾음 !
*/
-- TBL_EMP_JOIN 테이블 생성 : QUIT_DATE, QUIT_YN 제외
    CREATE TABLE TBL_EMP_JOIN
    AS
    SELECT EMP_ID, EMP_NAME, EMP_NO, EMAIL, PHONE, DEPT_CODE, JOB_CODE, SAL_LEVEL, SALARY, BONUS, MANAGER_ID, HIRE_DATE
    FROM EMPLOYEE
    WHERE QUIT_YN = 'N';

    SELECT * FROM TBL_EMP_JOIN;

-- TBL_EMP_QUIT : EMPLOYEE테이블에서 QUIT_YN 컬럼 제외하고 복사
    CREATE TABLE TBL_EMP_QUIT
    AS
    SELECT EMP_ID, EMP_NAME, EMP_NO, EMAIL, PHONE, DEPT_CODE, JOB_CODE, SAL_LEVEL, SALARY, BONUS, MANAGER_ID, HIRE_DATE, QUIT_DATE
    FROM EMPLOYEE
    WHERE QUIT_YN = 'Y';

    SELECT * FROM TBL_EMP_QUIT;   
----------------------------------------------------------

-- @@ 트리거 : TBL_EMP_JOIN에서 DELETE시 자동으로 퇴사자 데이터가 TBL_EMP_QUIT에 INSERT
create or replace trigger trig_tbl_emp_quit
    after
    delete on tbl_emp_join 
    for each row
begin
    insert into
        tbl_emp_quit
        values(:old.EMP_ID, :old.EMP_NAME, :old.EMP_NO, :old.EMAIL, :old.PHONE, 
                :old.DEPT_CODE, :old.JOB_CODE, :old.SAL_LEVEL, :old.SALARY, 
                :old.BONUS, :old.MANAGER_ID, :old.HIRE_DATE, sysdate); -- 오늘날짜로 퇴사일 설정
end;
/

-- @@ '200' 선동일 삭제 
delete from 
    tbl_emp_join
where
    emp_id = '200';

-- @@ 트리거 작동 확인    
SELECT * FROM TBL_EMP_JOIN;
SELECT * FROM TBL_EMP_QUIT;   

rollback;


/*
2. 사원변경내역을 기록하는 emp_log테이블을 생성하고, ex_employee 사원테이블의 insert, update가 있을 때마다 신규데이터를 기록하는 트리거를 생성하라.
* 로그테이블명 emp_log : 컬럼 log_no(시퀀스객체로부터 채번함. pk), log_date(기본값 sysdate, not null), ex_employee테이블의 모든 컬럼
* 트리거명 trg_emp_log
*/

-- @@ ex_employee에서 컬럼만 가져와 emp_log 테이블 생성
    -- 제약조건 새로 걸어줄 필요 없음 -> ex_employee에서 걸러진 데이터를 가져와 쓰는거기 때문에! 
create table emp_log 
as
(select * from ex_employee where 1 = 0);


-- @@ emp_log 테이블에 log_no, log_date 컬럼 추가
alter table
    emp_log
add (
    log_no number constraint pk_emp_log_no primary key,
    log_date date default sysdate not null
);
    
-- @@ 시퀀스 생성
create sequence seq_emp_log_no;

-- @@ 트리거 생성: ex_employee 사원테이블의 insert, update가 있을 때마다 신규데이터를 기록
create or replace trigger trg_emp_log
    before
    insert or update on ex_employee
    for each row
begin
    if inserting then
    insert into
        emp_log
    values (:new.emp_id, :new.emp_name, :new.emp_no, :new.email, :new.phone, :new.dept_code, :new.job_code, 
            :new.sal_level, :new.salary, :new.bonus, :new.manager_id, :new.hire_date, :new.quit_date, :new.quit_yn, 
            seq_emp_log_no.nextval, default);
    
    elsif updating then
    insert into
        emp_log
    values (:new.emp_id, :new.emp_name, :new.emp_no, :new.email, :new.phone, :new.dept_code, :new.job_code, 
            :new.sal_level, :new.salary, :new.bonus, :new.manager_id, :new.hire_date, :new.quit_date, :new.quit_yn, 
            seq_emp_log_no.nextval, default);   
    end if;
end;
/

-- @@ ex_employee INSERT
insert into
    ex_employee(emp_id, emp_name, emp_no, job_code, sal_level)
values(303, '홍길동', '991102-1145234', 'J6', 'S3');

-- @@ ex_employee UPDATE
update
    ex_employee
set
    emp_name = '홍길동길동'
where
    emp_id = '303';

select * from emp_log;

rollback;
