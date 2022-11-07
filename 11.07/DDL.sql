-------------------------------------------------------------------
-- @ DDL
-------------------------------------------------------------------

/*
1. 계열 정보를 저장할 카테고리 테이블을 만들려고 한다. 다음과 같은 테이블을 작성하시오.
    테이블 이름
    TB_CATEGORY
    컬럼
    NAME, VARCHAR2(10)
    USE_YN, CHAR(1), 기본값은 Y 가 들어가도록
*/
create table TB_CATEGORY(
    NAME VARCHAR2(10),
    USE_YN CHAR(1) default 'Y'
);


/*
2. 과목 구분을 저장할 테이블을 만들려고 한다. 다음과 같은 테이블을 작성하시오.
    테이블이름
    TB_CLASS_TYPE
    컬럼
    NO, VARCHAR2(5), PRIMARY KEY
    NAME , VARCHAR2(10) 
*/
create table TB_CLASS_TYPE(
    NO VARCHAR2(5),
    NAME VARCHAR2(10),
    constraint pk_CLASS_TYPE_NO primary key(NO)
);


-- 3. TB_CATEGORY 테이블의 NAME 컬럼에 PRIMARY KEY 를 생성하시오. 
-- (KEY 이름을 생성하지 않아도 무방함. 만일 KEY 이를 지정하고자 한다면 이름은 본인이 알아서 적당한 이름을 사용한다.)
alter table
    TB_CATEGORY
add constraint
    pk_TB_CATEGORY_NAME primary key (NAME);

desc TB_CATEGORY;


-- 4. TB_CLASS_TYPE 테이블의 NAME 컬럼에 NULL 값이 들어가지 않도록 속성을 변경하시오.
alter table
    TB_CLASS_TYPE
modify
    NAME not null;

desc TB_CLASS_TYPE;


-- 5. 두 테이블에서 컬럼 명이 NO 인 것은 기존 타입을 유지하면서 크기는 10 으로, 
 --   컬럼명이 NAME 인 것은 마찬가지로 기존 타입을 유지하면서 크기 20 으로 변경하시오.
alter table
    TB_CATEGORY
modify
    NAME VARCHAR2(20);

alter table
    TB_CLASS_TYPE
modify
    (NO VARCHAR2(10), NAME VARCHAR2(20)); 


-- 6. 두 테이블의 NO 컬럼과 NAME 컬럼의 이름을 각 각 TB_ 를 제외한 테이블 이름이 앞에 붙은 형태로 변경한다. (ex. CATEGORY_NAME)
alter table
    TB_CATEGORY 
rename column NAME to CATEGORY_NAME;

alter table
    TB_CLASS_TYPE
rename column NAME to CLASS_TYPE_NAME;

alter table
    TB_CLASS_TYPE
rename column NO to CLASS_TYPE_NO;


-- 7. TB_CATAGORY 테이블과 TB_CLASS_TYPE 테이블의 PRIMARY KEY 이름을 다음과 같이 변경하시오.
    -- Primary Key 의 이름은 ‚PK_ + 컬럼이름‛으로 지정하시오. (ex. PK_CATEGORY_NAME )
alter table
    TB_CATEGORY
rename constraint pk_TB_CATEGORY_NAME to PK_CATEGORY_NAME;

alter table
    TB_CLASS_TYPE
rename constraint pk_CLASS_TYPE_NO to PK_CLASS_TYPE_NO;
    
    
-- 8. 다음과 같은 INSERT 문을 수행한다.
INSERT INTO TB_CATEGORY VALUES ('공학','Y');
INSERT INTO TB_CATEGORY VALUES ('자연과학','Y');
INSERT INTO TB_CATEGORY VALUES ('의학','Y');
INSERT INTO TB_CATEGORY VALUES ('예체능','Y');
INSERT INTO TB_CATEGORY VALUES ('인문사회','Y');
COMMIT;


-- 9.TB_DEPARTMENT 의 CATEGORY 컬럼이 TB_CATEGORY 테이블의 CATEGORY_NAME 컬럼을 부모값으로 참조하도록 FOREIGN KEY 를 지정하시오. 
--    이 때 KEY 이름은 FK_테이블이름_컬럼이름으로 지정한다. (ex. FK_DEPARTMENT_CATEGORY )
alter table
    TB_DEPARTMENT
add constraint
    FK_DEPARTMENT_CATEGORY foreign key(CATEGORY) references TB_CATEGORY(CATEGORY_NAME);

-- 확인
select
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition,
    uc.r_constraint_name 
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'TB_DEPARTMENT';



-- 10. 춘 기술대학교 학생들의 정보만이 포함되어 있는 학생일반정보 VIEW 를 만들고자 한다. 아래 내용을 참고하여 적절한 SQL 문을 작성하시오.
    -- 뷰 이름 :VW_학생일반정보
    -- 컬럼 :학번, 학생이름, 주소

grant create view to chun; -- system
    
create or replace view VW_학생일반정보
as
select
    student_no 학번, student_name 학생이름, student_address 주소
from
    tb_student;

select * from VW_학생일반정보;



/*
11. 춘 기술대학교는 1 년에 두 번씩 학과별로 학생과 지도교수가 지도 면담을 진행한다. 이를 위해 사용할 학생이름, 학과이름, 담당교수이름 으로 구성되어 있는 VIEW 를 만드시오.
    이때 지도 교수가 없는 학생이 있을 수 있음을 고려하시오 (단, 이 VIEW 는 단순 SELECT만을 할 경우 학과별로 정렬되어 화면에 보여지게 만드시오.)
    뷰 이름
        VW_지도면담
    컬럼
        학생이름
        학과이름
        지도교수이름
*/
create or replace view VM_지도면담
as
select
    s.student_name 학생이름,
    d.department_name 학과이름,
    p.professor_name 담당교수이름
from 
    tb_department d join tb_student s
        on d.department_no = s.department_no
    left join tb_professor p
        on s.coach_professor_no = p.professor_no
group by
    department_name, student_name, professor_name
order by
    2, 1;

select * from "VM_지도면담";


-- 12. 모든 학과의 학과별 학생 수를 확인핛 수 있도록 적절한 VIEW 를 작성해 보자.
    -- 뷰 이름 VW_학과별학생수
    -- 컬럼 DEPARTMENT_NAME, STUDENT_COUNT
create view VW_학과별학생수
as
select
    (select department_name from tb_department where department_no = s.department_no) DEPARTMENT_NAME,
    count(*) STUDENT_COUNT
from
    tb_student s
group by
    department_no
order by
    1;

select * from VW_학과별학생수;


-- 13. 위에서 생성한 학생일반정보 View 를 통해서 학번이 A213046 인 학생의 이름을 본인 이름으로 변경하는 SQL 문을 작성하시오.

select 학생이름 from VW_학생일반정보 where 학번 = 'A213046'; -- 서가람

update
    VW_학생일반정보
set
    학생이름 = '박효정'
where
    학번 = 'A213046';
    
select * from VW_학생일반정보;


-- 14. 13 번에서와 같이 VIEW 를 통해서 데이터가 변경될 수 있는 상황을 막으려면 VIEW 를 어떻게 생성해야 하는지 작성하시오.
create or replace view VW_학생일반정보
as
select
    student_no 학번, student_name 학생이름, student_address 주소
from
    tb_student
with read only; -- 읽기 전용뷰 옵션 추가 


/*
15. 춘 기술대학교는 매년 수강신청 기간만 되면 특정 인기 과목들에 수강 신청이 몰려 문제가 되고 있다. 
    최근 3 년을 기준으로 수강인원이 가장 많았던 3 과목을 찾는 구문을 작성해보시오.
    
    과목번호   과목이름                       누적수강생수(명)
    ---------- ------------------------------ ----------------
    C1753800   서어방언학                      29
    C1753400   서어문체론                      23
    C2454000   원예작물번식학특론              22
*/
-- 최근3년    
create or replace view VW_최근3년
as
select 
    *
from(
    select distinct
        dense_rank() over(order by substr(term_no, 1, 4 ) desc) rnum,
        substr(term_no, 1, 4 ) 년도       
    from
        tb_grade
    order by
    2 desc
    )
where
    rnum <=3
with read only;

select * from VW_최근3년; -- 2009, 2008, 2007

----------------

select
    과목번호, 과목이름, "누적수강생수(명)"
from (
select 
    class_no 과목번호,
    (select class_name from tb_class where class_no = g.class_no) 과목이름,
    count(*) "누적수강생수(명)",
    dense_rank() over(order by count(*) desc) rnum
from
    tb_grade g
where
     substr(term_no, 1, 4) in (select 년도 from VW_최근3년)
group by
    class_no
)
where
    rnum <= 3;
    