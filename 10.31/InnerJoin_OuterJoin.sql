--====================================================================
-- 10.31 (월)
--====================================================================
-- @실습문제 : INNER JOIN & OUTER JOIN

--1. 학번, 학생명, 담당교수명을 출력하세요.
--담당교수가 없는 학생은 '없음'으로 표시
select
    s.student_no 학번,
    s.student_name 학생명,
    nvl(p.professor_name, '없음') 담당교수명
from
    tb_student s left join tb_professor p 
        on s.coach_professor_no = p.professor_no;
        

--2. 학과별 교수명과 인원수를 모두 표시하세요.
select
    decode(grouping(d.department_name), 0 , nvl(d.department_name, '학과 미정'), 1, ' ') 학과명,
    decode(grouping( p.professor_name), 0 , nvl(p.professor_name, ' '), 1, '전체 교수 인원') 교수명,
    count(*) 인원수
from
    tb_professor p left join tb_department d -- 학과미정 교수
        on p.department_no = d.department_no      
group by
    rollup(d.department_name, p.professor_name);
    

-- 3. 이름이 [~람]인 학생의 평균학점을 구해서 학생명과 평균학점(반올림해서 소수점둘째자리까지)과 같이 출력.
-- (동명이인일 경우에 대비해서 student_name만으로 group by 할 수 없다.)

select
    s.student_no 학번,
    s.student_name 학생명,
    round(avg(g.point), 2)평균학점
from
    tb_student s right join tb_grade g
        on s.student_no = g.student_no
where
    s.student_name like '%람'
group by
    s.student_name, s.student_no;


--4. 학생별 다음정보를 구하라.
-- (group by 없는 단순 조회)
/*
--------------------------------------------
학생명  학기     과목명    학점
-------------------------------------------
감현제    200702    치과분자약리학    4.5
감현제    200701    구강회복학    4
            .
            .
--------------------------------------------

*/

select
    s.student_name 학생명,
    g.term_no 학기,
    c.class_name 과목명,
    g.point 학점
from 
    tb_student s right join tb_grade g  -- 해당 학생이 아직 성적은 없을 수 있음 
        on s.student_no = g.student_no
        
    join tb_class c -- 점수가 없는 과목까지 알 필요 없음 
        on g.class_no = c.class_no
order by
    s.student_name, g.term_no desc;