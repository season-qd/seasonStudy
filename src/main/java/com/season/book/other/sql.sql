

2、列出各个部门中工资高于本部门的平均工资的员工数和部门号，并按部门号排序
创建表：
       mysql> create table employee921(id int primary key auto_increment,name varchar(5
0),salary bigint,deptid int);

插入实验数据：
mysql> insert into employee921 values(null,'zs',1000,1),(null,'ls',1100,1),(null
,'ww',1100,1),(null,'zl',900,1) ,(null,'zl',1000,2), (null,'zl',900,2) ,(null,'z
l',1000,2) , (null,'zl',1100,2);

编写sql语句：

（）select avg(salary) from employee921 group by deptid;
（）mysql> select employee921.id,employee921.name,employee921.salary,employee921.dep
tid tid from  employee921 where salary > (select avg(salary) from employee921 where  deptid = tid);
   效率低的一个语句，仅供学习参考使用（在group by之后不能使用where，只能使用having，在group by之前可以使用where，即表示对过滤后的结果分组）：
mysql> select employee921.id,employee921.name,employee921.salary,employee921.dep
tid tid from  employee921 where salary > (select avg(salary) from employee921 group by deptid having deptid = tid);
（）select count(*) ,tid 
	from (
		select employee921.id,employee921.name,employee921.salary,employee921.deptid tid 
		from  	employee921 
		where salary >
	 		(select avg(salary) from employee921 where  deptid = tid)
	) as t 
	group by tid ;

另外一种方式：关联查询
select a.ename,a.salary,a.deptid 
 from emp a,
    (select deptd,avg(salary) avgsal from emp group by deptid ) b 
 where a.deptid=b.deptid and a.salary>b.avgsal;
3、存储过程与触发器必须讲，经常被面试到?
create procedure insert_Student (_name varchar(50),_age int ,out _id int)
begin
	insert into student value(null,_name,_age);
	select max(stuId) into _id from student;
end;

call insert_Student('wfz',23,@id);
select @id;

mysql> create trigger update_Student BEFORE update on student FOR EACH ROW
-> select * from student;
触发器不允许返回结果

create trigger update_Student BEFORE update on student FOR EACH ROW  
insert into  student value(null,'zxx',28);
mysql的触发器目前不能对当前表进行操作

create trigger update_Student BEFORE update on student FOR EACH ROW  
delete from articles  where id=8;
这个例子不是很好，最好是用删除一个用户时，顺带删除该用户的所有帖子
这里要注意使用OLD.id

触发器用处还是很多的，比如校内网、开心网、Facebook，你发一个日志，自动通知好友，其实就是在增加日志时做一个后触发，再向通知表中写入条目。因为触发器效率高。而UCH没有用触发器，效率和数据处理能力都很低。
存储过程的实验步骤：
mysql> delimiter |
mysql> create procedure insertArticle_Procedure (pTitle varchar(50),pBid int,out
 pId int)
    -> begin
    -> insert into article1 value(null,pTitle,pBid);
    -> select max(id) into pId from article1;
    -> end;
    -> |
Query OK, 0 rows affected (0.05 sec)

mysql> call insertArticle_Procedure('传智播客',1,@pid);
    -> |
Query OK, 0 rows affected (0.00 sec)

mysql> delimiter ;
mysql> select @pid;
+------+
| @pid |
+------+
| 3    |
+------+
1 row in set (0.00 sec)

mysql> select * from article1;
+----+--------------+------+
| id | title        | bid  |
+----+--------------+------+
| 1  | test         | 1    |
| 2  | chuanzhiboke | 1    |
| 3  | 传智播客     | 1    |
+----+--------------+------+
3 rows in set (0.00 sec)

触发器的实验步骤：
create table board1(id int primary key auto_increment,name varchar(50),ar
ticleCount int);

create table article1(id int primary key auto_increment,title varchar(50)
,bid int references board1(id));

delimiter |

create trigger insertArticle_Trigger after insert on article1 for each ro
w begin
    -> update board1 set articleCount=articleCount+1 where id= NEW.bid;
    -> end;
    -> |

delimiter ;

insert into board1 value (null,'test',0);

insert into article1 value(null,'test',1);
还有，每插入一个帖子，都希望将版面表中的最后发帖时间，帖子总数字段进行同步更新，用触发器做效率就很高。下次课设计这样一个案例，写触发器时，对于最后发帖时间可能需要用declare方式声明一个变量，或者是用NEW.posttime来生成。

4、数据库三范式是什么?
第一范式（1NF）：字段具有原子性,不可再分。所有关系型数据库系统都满足第一范式）
	数据库表中的字段都是单一属性的，不可再分。例如，姓名字段，其中的姓和名必须作为一个整体，无法区分哪部分是姓，哪部分是名，如果要区分出姓和名，必须设计成两个独立的字段。

  第二范式（2NF）：
第二范式（2NF）是在第一范式（1NF）的基础上建立起来的，即满足第二范式（2NF）必须先满足第一范式（1NF）。
要求数据库表中的每个实例或行必须可以被惟一地区分。通常需要为表加上一个列，以存储各个实例的惟一标识。这个惟一属性列被称为主关键字或主键。

第二范式（2NF）要求实体的属性完全依赖于主关键字。所谓完全依赖是指不能存在仅依赖主关键字一部分的属性，如果存在，那么这个属性和主关键字的这一部分应该分离出来形成一个新的实体，新实体与原实体之间是一对多的关系。为实现区分通常需要为表加上一个列，以存储各个实例的惟一标识。简而言之，第二范式就是非主属性非部分依赖于主关键字。
  
 第三范式的要求如下： 
满足第三范式（3NF）必须先满足第二范式（2NF）。简而言之，第三范式（3NF）要求一个数据库表中不包含已在其它表中已包含的非主关键字信息。
所以第三范式具有如下特征：
         1，每一列只有一个值 
         2，每一行都能区分。 
         3，每一个表都不包含其他表已经包含的非主关键字信息。
例如，帖子表中只能出现发帖人的id，而不能出现发帖人的id，还同时出现发帖人姓名，否则，只要出现同一发帖人id的所有记录，它们中的姓名部分都必须严格保持一致，这就是数据冗余。

5、说出一些数据库优化方面的经验?
用PreparedStatement 一般来说比Statement性能高：一个sql 发给服务器去执行，涉及步骤：语法检查、语义分析， 编译，缓存
“inert into user values(1,1,1)”-二进制
“inert into user values(2,2,2)”-二进制
“inert into user values(?,?,?)”-二进制



有外键约束会影响插入和删除性能，如果程序能够保证数据的完整性，那在设计数据库时就去掉外键。（比喻：就好比免检产品，就是为了提高效率，充分相信产品的制造商）
（对于hibernate来说，就应该有一个变化：empleyee->Deptment对象，现在设计时就成了employeedeptid）

看mysql帮助文档子查询章节的最后部分，例如，根据扫描的原理，下面的子查询语句要比第二条关联查询的效率高：
1.  select e.name,e.salary where e.managerid=(select id from employee where name='zxx');

2.   select e.name,e.salary,m.name,m.salary from employees e,employees m where
 e.managerid = m.id and m.name='zxx';

表中允许适当冗余，譬如，主题帖的回复数量和最后回复时间等
将姓名和密码单独从用户表中独立出来。这可以是非常好的一对一的案例哟！

sql语句全部大写，特别是列名和表名都大写。特别是sql命令的缓存功能，更加需要统一大小写，sql语句发给oracle服务器语法检查和编译成为内部指令缓存和执行指令。根据缓存的特点，不要拼凑条件，而是用?和PreparedStatment

还有索引对查询性能的改进也是值得关注的。

备注：下面是关于性能的讨论举例

4航班 3个城市

m*n

select * from flight,city where flight.startcityid=city.cityid and city.name='beijing';

m + n


select * from flight where startcityid = (select cityid from city where cityname='beijing');

select flight.id,'beijing',flight.flightTime from flight where startcityid = (select cityid from city where cityname='beijing')
6、union和union all有什么不同?
假设我们有一个表Student，包括以下字段与数据：
drop table student;
create table student
(
id int primary key,
name nvarchar2(50) not null,
score number not null
);
insert into student values(1,'Aaron',78);
insert into student values(2,'Bill',76);
insert into student values(3,'Cindy',89);
insert into student values(4,'Damon',90);
insert into student values(5,'Ella',73);
insert into student values(6,'Frado',61);
insert into student values(7,'Gill',99);
insert into student values(8,'Hellen',56);
insert into student values(9,'Ivan',93);
insert into student values(10,'Jay',90);
commit;
Union和Union All的区别。 
select *
from student
where id < 4
union
select *
from student
where id > 2 and id < 6
结果将是
1    Aaron    78
2    Bill    76
3    Cindy    89
4    Damon    90
5    Ella    73
如果换成Union All连接两个结果集，则返回结果是：
1    Aaron    78
2    Bill    76
3    Cindy    89
3    Cindy    89
4    Damon    90
5    Ella    73
可以看到，Union和Union All的区别之一在于对重复结果的处理。

　　UNION在进行表链接后会筛选掉重复的记录，所以在表链接后会对所产生的结果集进行排序运算，删除重复的记录再返回结果。实际大部分应用中是不会产生重复的记录，最常见的是过程表与历史表UNION。如：
select * from gc_dfys
union
select * from ls_jg_dfys
　　这个SQL在运行时先取出两个表的结果，再用排序空间进行排序删除重复的记录，最后返回结果集，如果表数据量大的话可能会导致用磁盘进行排序。
　而UNION ALL只是简单的将两个结果合并后就返回。这样，如果返回的两个结果集中有重复的数据，那么返回的结果集就会包含重复的数据了。
　从效率上说，UNION ALL 要比UNION快很多，所以，如果可以确认合并的两个结果集中不包含重复的数据的话，那么就使用UNION ALL， 
7.分页语句
取出sql表中第31到40的记录（以自动增长ID为主键）
sql server方案1：
	select top 10 * from t where id not in (select top 30 id from t order by id ) orde by id
sql server方案2：
	select top 10 * from t where id in (select top 40 id from t order by id) order by id desc

mysql方案：select * from t order by id limit 30,10

oracle方案：select * from (select rownum r,* from t where r<=40) where r>30

--------------------待整理进去的内容-------------------------------------
pageSize=20;
pageNo = 5;

1.分页技术1（直接利用sql语句进行分页，效率最高和最推荐的）

mysql:sql = "select * from articles limit " + (pageNo-1)*pageSize + "," + pageSize;
oracle: sql = "select * from " +
								"(select rownum r,* from " +
									"(select * from articles order by postime desc)" +
								"where rownum<= " + pageNo*pageSize +") tmp " +
							"where r>" + (pageNo-1)*pageSize;
注释：第7行保证rownum的顺序是确定的，因为oracle的索引会造成rownum返回不同的值
简洋提示：没有order by时，rownum按顺序输出，一旦有了order by，rownum不按顺序输出了，这说明rownum是排序前的编号。如果对order by从句中的字段建立了索引，那么，rownum也是按顺序输出的，因为这时候生成原始的查询结果集时会参照索引表的顺序来构建。

sqlserver:sql = "select top 10 * from id not id(select top " + (pageNo-1)*pageSize + "id from articles)"

DataSource ds = new InitialContext().lookup(jndiurl);
Connection cn = ds.getConnection();
//"select * from user where id=?"  --->binary directive
PreparedStatement pstmt = cn.prepareSatement(sql);
ResultSet rs = pstmt.executeQuery()
while(rs.next())
{
	out.println(rs.getString(1));
}

2.不可滚动的游标
pageSize=20;
pageNo = 5;
cn = null
stmt = null;
rs = null;
try
{
sqlserver:sql = "select  * from articles";

DataSource ds = new InitialContext().lookup(jndiurl);
Connection cn = ds.getConnection();
//"select * from user where id=?"  --->binary directive
PreparedStatement pstmt = cn.prepareSatement(sql);
ResultSet rs = pstmt.executeQuery()
for(int j=0;j<(pageNo-1)*pageSize;j++)
{
	rs.next();
}

int i=0;

while(rs.next() && i<10)
{
	i++;
	out.println(rs.getString(1));
}
}
cacth(){}
finnaly
{
	if(rs!=null)try{rs.close();}catch(Exception e){}
	if(stm.........
	if(cn............
}

3.可滚动的游标
pageSize=20;
pageNo = 5;
cn = null
stmt = null;
rs = null;
try
{
sqlserver:sql = "select  * from articles";

DataSource ds = new InitialContext().lookup(jndiurl);
Connection cn = ds.getConnection();
//"select * from user where id=?"  --->binary directive
PreparedStatement pstmt = cn.prepareSatement(sql,ResultSet.TYPE_SCROLL_INSENSITIVE,...);
//根据上面这行代码的异常SQLFeatureNotSupportedException，就可判断驱动是否支持可滚动游标

ResultSet rs = pstmt.executeQuery()
rs.absolute((pageNo-1)*pageSize)
int i=0;
while(rs.next() && i<10)
{
	i++;
	out.println(rs.getString(1));
}
}
cacth(){}
finnaly
{
	if(rs!=null)try{rs.close();}catch(Exception e){}
	if(stm.........
	if(cn............
}
8.用一条SQL语句 查询出每门课都大于80分的学生姓名  
name   kecheng   fenshu 
张三     语文       81
张三     数学       75
李四     语文       76
李四     数学       90
王五     语文       81
王五     数学       100
王五     英语       90

准备数据的sql代码：
create table score(id int primary key auto_increment,name varchar(20),subject varchar(20),score int);
insert into score values 
(null,'张三','语文',81),
(null,'张三','数学',75),
(null,'李四','语文',76),
(null,'李四','数学',90),
(null,'王五','语文',81),
(null,'王五','数学',100),
(null,'王五 ','英语',90);

提示：当百思不得其解时，请理想思维，把小变成大做，把大变成小做，

答案：
A: select distinct name from score  where  name not in (select distinct name from score where score<=80)

B:select distince name t1 from score where 80< all (select score from score where name=t1);

9.所有部门之间的比赛组合
一个叫department的表，里面只有一个字段name,一共有4条纪录，分别是a,b,c,d,对应四个球对，现在四个球对进行比赛，用一条sql语句显示所有可能的比赛组合.

答：select a.name, b.name 
from team a, team b 
where a.name < b.name

10.每个月份的发生额都比101科目多的科目
请用SQL语句实现：从TestDB数据表中查询出所有月份的发生额都比101科目相应月份的发生额高的科目。请注意：TestDB中有很多科目，都有1－12月份的发生额。
AccID：科目代码，Occmonth：发生额月份，DebitOccur：发生额。
数据库名：JcyAudit，数据集：Select * from TestDB
准备数据的sql代码：
drop table if exists TestDB;
create table TestDB(id int primary key auto_increment,AccID varchar(20), Occmonth date, DebitOccur bigint);
insert into TestDB values 
(null,'101','1988-1-1',100),
(null,'101','1988-2-1',110),
(null,'101','1988-3-1',120),
(null,'101','1988-4-1',100),
(null,'101','1988-5-1',100),
(null,'101','1988-6-1',100),
(null,'101','1988-7-1',100),
(null,'101','1988-8-1',100);
--复制上面的数据，故意把第一个月份的发生额数字改小一点
insert into TestDB values 
(null,'102','1988-1-1',90),
(null,'102','1988-2-1',110),
(null,'102','1988-3-1',120),
(null,'102','1988-4-1',100),
(null,'102','1988-5-1',100),
(null,'102','1988-6-1',100),
(null,'102','1988-7-1',100),
(null,'102','1988-8-1',100);
--复制最上面的数据，故意把所有发生额数字改大一点
insert into TestDB values 
(null,'103','1988-1-1',150),
(null,'103','1988-2-1',160),
(null,'103','1988-3-1',180),
(null,'103','1988-4-1',120),
(null,'103','1988-5-1',120),
(null,'103','1988-6-1',120),
(null,'103','1988-7-1',120),
(null,'103','1988-8-1',120);
--复制最上面的数据，故意把所有发生额数字改大一点
insert into TestDB values 
(null,'104','1988-1-1',130),
(null,'104','1988-2-1',130),
(null,'104','1988-3-1',140),
(null,'104','1988-4-1',150),
(null,'104','1988-5-1',160),
(null,'104','1988-6-1',170),
(null,'104','1988-7-1',180),
(null,'104','1988-8-1',140);
--复制最上面的数据，故意把第二个月份的发生额数字改小一点
insert into TestDB values 
(null,'105','1988-1-1',100),
(null,'105','1988-2-1',80),
(null,'105','1988-3-1',120),
(null,'105','1988-4-1',100),
(null,'105','1988-5-1',100),
(null,'105','1988-6-1',100),
(null,'105','1988-7-1',100),
(null,'105','1988-8-1',100);
答案：
select distinct AccID from TestDB 
where AccID not in 
	(select TestDB.AccIDfrom TestDB,
		 (select * from TestDB where AccID='101') as db101 
	where TestDB.Occmonth=db101.Occmonth and TestDB.DebitOccur<=db101.DebitOccur
	);

11.统计每年每月的信息
year  month amount
1991   1     1.1
1991   2     1.2
1991   3     1.3
1991   4     1.4
1992   1     2.1
1992   2     2.2
1992   3     2.3
1992   4     2.4
查成这样一个结果
year m1  m2  m3  m4
1991 1.1 1.2 1.3 1.4
1992 2.1 2.2 2.3 2.4 

提示：这个与工资条非常类似，与学生的科目成绩也很相似。

准备sql语句：
drop table if exists sales;
create table sales(id int auto_increment primary key,year varchar(10), month varchar(10), amount float(2,1));
insert into sales values
(null,'1991','1',1.1),
(null,'1991','2',1.2),
(null,'1991','3',1.3),
(null,'1991','4',1.4),
(null,'1992','1',2.1),
(null,'1992','2',2.2),
(null,'1992','3',2.3),
(null,'1992','4',2.4);

答案一、
select sales.year ,
(select t.amount from sales t where t.month='1' and t.year= sales.year) '1',
(select t.amount from sales t where t.month='1' and t.year= sales.year) '2',
(select t.amount from sales t where t.month='1' and t.year= sales.year) '3',
(select t.amount from sales t where t.month='1' and t.year= sales.year) as '4' 
from sales  group by year;

12.显示文章标题，发帖人、最后回复时间
表：id,title,postuser,postdate,parentid
准备sql语句：
drop table if exists articles;
create table articles(id int auto_increment primary key,title varchar(50), postuser varchar(10), postdate datetime,parentid int references articles(id));
insert into articles values
(null,'第一条','张三','1998-10-10 12:32:32',null),
(null,'第二条','张三','1998-10-10 12:34:32',null),
(null,'第一条回复1','李四','1998-10-10 12:35:32',1),
(null,'第二条回复1','李四','1998-10-10 12:36:32',2),
(null,'第一条回复2','王五','1998-10-10 12:37:32',1),
(null,'第一条回复3','李四','1998-10-10 12:38:32',1),
(null,'第二条回复2','李四','1998-10-10 12:39:32',2),
(null,'第一条回复4','王五','1998-10-10 12:39:40',1);

答案：
select a.title,a.postuser,
	(select max(postdate) from articles where parentid=a.id) reply 
from articles a where a.parentid is null;

注释：子查询可以用在选择列中，也可用于where的比较条件中，还可以用于from从句中。
13.删除除了id号不同,其他都相同的学生冗余信息
2.学生表 如下:
id号   学号   姓名 课程编号 课程名称 分数
1        2005001  张三  0001      数学    69
2        2005002  李四  0001      数学    89
3        2005001  张三  0001      数学    69
A: delete from tablename where id号 not in(select min(id号) from tablename group by 学号,姓名,课程编号,课程名称,分数)
实验：
create table student2(id int auto_increment primary key,code varchar(20),name varchar(20));
insert into student2 values(null,'2005001','张三'),(null,'2005002','李四'),(null,'2005001','张三');

//如下语句，mysql报告错误，可能删除依赖后面统计语句，而删除又导致统计语句结果不一致。

delete from student2 where id not in(select min(id) from student2 group by name);
//但是，如下语句没有问题：
select *  from student2 where id not in(select min(id) from student2 group by name);
//于是，我想先把分组的结果做成虚表，然后从虚表中选出结果，最后再将结果作为删除的条件数据。
delete from student2 where id not in(select mid from (select min(id) mid
from student2 group by name) as t);
或者：
delete from student2 where id not in(select min(id) from (select * from s
tudent2) as t group by t.name);
14.航空网的几个航班查询题：
表结构如下：
flight{flightID,StartCityID ,endCityID,StartTime}
city{cityID, CityName)
实验环境：
create table city(cityID int auto_increment primary key,cityName varchar(20));
create table flight (flightID int auto_increment primary key,
	StartCityID int references city(cityID),
	endCityID  int references city(cityID),
	StartTime timestamp); 
//航班本来应该没有日期部分才好，但是下面的题目当中涉及到了日期
insert into city values(null,'北京'),(null,'上海'),(null,'广州');
insert into flight values
	(null,1,2,'9:37:23'),(null,1,3,'9:37:23'),(null,1,2,'10:37:23'),(null,2,3,'10:37:23');


1、查询起飞城市是北京的所有航班，按到达城市的名字排序


参与运算的列是我起码能够显示出来的那些列，但最终我不一定把它们显示出来。各个表组合出来的中间结果字段中必须包含所有运算的字段。

  select  * from flight f,city c 
	where f.endcityid = c.cityid and startcityid = 
	(select c1.cityid from city c1 where c1.cityname = "北京")
	order by c.cityname asc;

mysql> select flight.flightid,'北京' startcity, e.cityname from flight,city e wh
ere flight.endcityid=e.cityid and flight.startcityid=(select cityid from city wh
ere cityname='北京');

mysql> select flight.flightid,s.cityname,e.cityname from flight,city s,city e wh
ere flight.startcityid=s.cityid and s.cityname='北京' and flight.endCityId=e.cit
yID order by e.cityName desc;


2、查询北京到上海的所有航班纪录（起飞城市，到达城市，起飞时间，航班号）
select c1.CityName,c2.CityName,f.StartTime,f.flightID
from city c1,city c2,flight f
where f.StartCityID=c1.cityID 
and f.endCityID=c2.cityID
and c1.cityName='北京'
and c2.cityName='上海'
3、查询具体某一天（2005-5-8）的北京到上海的的航班次数
select count(*) from 
(select c1.CityName,c2.CityName,f.StartTime,f.flightID
from city c1,city c2,flight f
where f.StartCityID=c1.cityID 
and f.endCityID=c2.cityID
and c1.cityName='北京'
and c2.cityName='上海'
and 查帮助获得的某个日期处理函数(startTime) like '2005-5-8%'

mysql中提取日期部分进行比较的示例代码如下：
select * from flight where date_format(starttime,'%Y-%m-%d')='1998-01-02'
15.查出比经理薪水还高的员工信息：
Drop table if not exists employees;
create table employees(id int primary key auto_increment,name varchar(50)
,salary int,managerid int references employees(id));
insert into employees values (null,' lhm',10000,null), (null,' zxx',15000,1
),(null,'flx',9000,1),(null,'tg',10000,2),(null,'wzg',10000,3);

Wzg大于flx,lhm大于zxx

解题思路：
     根据sql语句的查询特点，是逐行进行运算，不可能两行同时参与运算。
涉及了员工薪水和经理薪水，所有，一行记录要同时包含两个薪水，所有想到要把这个表自关联组合一下。
     首先要组合出一个包含有各个员工及该员工的经理信息的长记录，譬如，左半部分是员工，右半部分是经理。而迪卡尔积会组合出很多垃圾信息，先去除这些垃圾信息。

select e.* from employees e,employees m where e.managerid=m.id and e.sala
ry>m.salary;
16、求出小于45岁的各个老师所带的大于12岁的学生人数
数据库中有3个表 teacher 表，student表，tea_stu关系表。 
teacher 表 teaID name age 
student 表 stuID name age 
teacher_student表 teaID stuID 
要求用一条sql查询出这样的结果 
1.显示的字段要有老师name, age 每个老师所带的学生人数 
2 只列出老师age为40以下，学生age为12以上的记录
预备知识：
      1.sql语句是对每一条记录依次处理，条件为真则执行动作（select,insert,delete,update）
       2.只要是迪卡尔积，就会产生“垃圾”信息，所以，只要迪卡尔积了，我们首先就要想到清除“垃圾”信息
实验准备：
	drop table if exists tea_stu;
	drop table if exists teacher;
	drop table if exists student;
      create table teacher(teaID int primary key,name varchar(50),age int);
      create table student(stuID int primary key,name varchar(50),age int);
      create table tea_stu(teaID int references teacher(teaID),stuID int references student(stuID));
insert into teacher values(1,'zxx',45), (2,'lhm',25) , (3,'wzg',26) , (4,'tg',27);
insert into student values(1,'wy',11), (2,'dh',25) , (3,'ysq',26) , (4,'mxc',27);
insert into tea_stu values(1,1), (1,2), (1,3);
insert into tea_stu values(2,2), (2,3), (2,4);
 insert into tea_stu values(3,3), (3,4), (3,1);
insert into tea_stu values(4,4), (4,1), (4,2) , (4,3);

结果：23,32,43

解题思路：（真实面试答题时，也要写出每个分析步骤，如果纸张不够，就找别人要）
1要会统计分组信息，统计信息放在中间表中：
select teaid,count(*) from tea_stu group by teaid;

2接着其实应该是筛除掉小于12岁的学生，然后再进行统计，中间表必须与student关联才能得到12岁以下学生和把该学生记录从中间表中剔除，代码是：
select tea_stu.teaid,count(*) total from student,tea_stu 
where student.stuid=tea_stu.stuid and student.age>12 group by tea_stu.teaid

3.接着把上面的结果做成虚表与teacher进行关联，并筛除大于45的老师
select teacher.teaid,teacher.name,total from teacher ,(select tea_stu.tea
id,count(*) total from student,tea_stu where student.stuid=tea_stu.stuid and stu
dent.age>12 group by tea_stu.teaid) as tea_stu2 where teacher.teaid=tea_stu2.tea
id and teacher.age<45;


17.求出发帖最多的人：
select authorid,count(*) total from articles 
group by authorid 
having total=
(select max(total2) from (select count(*) total2 from articles group by authorid) as t);

select t.authorid,max(t.total) from
（select authorid,count(*) total from articles ）as t
这条语句不行，因为max只有一列，不能与其他列混淆。

select authorid,count(*) total from articles 
group by authorid having total=max(total)也不行。

18、一个用户表中有一个积分字段，假如数据库中有100多万个用户，若要在每年第一天凌晨将积分清零，你将考虑什么，你将想什么办法解决?
alter table drop column score;
alter table add colunm score int;
可能会很快，但是需要试验，试验不能拿真实的环境来操刀，并且要注意，
这样的操作时无法回滚的，在我的印象中，只有inert update delete等DML语句才能回滚，
对于create table,drop table ,alter table等DDL语句是不能回滚。


解决方案一，update user set score=0; 
解决方案二，假设上面的代码要执行好长时间，超出我们的容忍范围，那我就alter table user drop column score;alter table user add column score int。

下面代码实现每年的那个凌晨时刻进行清零。
Runnable runnable = 
	new Runnable(){
		public void run(){
			clearDb();
			schedule(this,new Date(new Date().getYear()+1,0,0));
			}		
			};

schedule(runnable,
	new Date(new Date().getYear()+1,0,1));

19、一个用户具有多个角色，请查询出该表中具有该用户的所有角色的其他用户。
select count(*) as num,tb.id 
from 
 tb,
 (select role from tb where id=xxx) as t1
where
 tb.role = t1.role and tb.id != t1.id
group by tb.id 
having 
	num = select count(role) from tb where id=xxx;
20. xxx公司的sql面试
Table EMPLOYEES Structure:
EMPLOYEE_ID      NUMBER        Primary Key,
FIRST_NAME       VARCHAR2(25),
LAST_NAME       VARCHAR2(25),
Salary number(8,2),
HiredDate DATE,
Departmentid number(2)
Table Departments Structure:
Departmentid number(2)        Primary Key,
DepartmentName  VARCHAR2(25).

 (2）基于上述EMPLOYEES表写出查询：写出雇用日期在今年的，或者工资在[1000,2000]之间的，或者员工姓名（last_name）以’Obama’打头的所有员工，列出这些员工的全部个人信息。（4分）
select * from employees 
where Year(hiredDate) = Year(date()) 
	or (salary between 1000 and 200)
	or left(last_name,3)='abc';

(3) 基于上述EMPLOYEES表写出查询：查出部门平均工资大于1800元的部门的所有员工，列出这些员工的全部个人信息。（4分）
mysql> select id,name,salary,deptid did from employee1 where (select avg(salary)
 from employee1 where deptid = did) > 1800;

(4) 基于上述EMPLOYEES表写出查询：查出个人工资高于其所在部门平均工资的员工，列出这些员工的全部个人信息及该员工工资高出部门平均工资百分比。（5分）
select employee1.*,(employee1.salary-t.avgSalary)*100/employee1.salary 
from employee1,
	(select deptid,avg(salary) avgSalary from employee1 group by deptid) as t
where employee1.deptid = t.deptid and employee1.salary>t.avgSalary;

21、注册Jdbc驱动程序的三种方式

22、用JDBC如何调用存储过程
代码如下：
package com.huawei.interview.lym;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;

public class JdbcTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Connection cn = null;
		CallableStatement cstmt = null;		
		try {
			//这里最好不要这么干，因为驱动名写死在程序中了
			Class.forName("com.mysql.jdbc.Driver");
			//实际项目中，这里应用DataSource数据，如果用框架，
			//这个数据源不需要我们编码创建，我们只需Datasource ds = context.lookup()
			//cn = ds.getConnection();			
			cn = DriverManager.getConnection("jdbc:mysql:///test","root","root");
			cstmt = cn.prepareCall("{call insert_Student(?,?,?)}");
			cstmt.registerOutParameter(3,Types.INTEGER);
			cstmt.setString(1, "wangwu");
			cstmt.setInt(2, 25);
			cstmt.execute();
			//get第几个，不同的数据库不一样，建议不写
			System.out.println(cstmt.getString(3));
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
		{

			/*try{cstmt.close();}catch(Exception e){}
			try{cn.close();}catch(Exception e){}*/
			try {
				if(cstmt != null)
					cstmt.close();
				if(cn != null)				
					cn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
23、JDBC中的PreparedStatement相比Statement的好处
答：一个sql命令发给服务器去执行的步骤为：语法检查，语义分析，编译成内部指令，缓存指令，执行指令等过程。
select * from student where id =3----缓存--xxxxx二进制命令
select * from student where id =3----直接取-xxxxx二进制命令
select * from student where id =4--- -会怎么干？
如果当初是select * from student where id =?--- -又会怎么干？
 上面说的是性能提高
可以防止sql注入。
24. 写一个用jdbc连接并访问oracle数据的程序代码
25、Class.forName的作用?为什么要用? 
答：按参数中指定的字符串形式的类名去搜索并加载相应的类，如果该类字节码已经被加载过，则返回代表该字节码的Class实例对象，否则，按类加载器的委托机制去搜索和加载该类，如果所有的类加载器都无法加载到该类，则抛出ClassNotFoundException。加载完这个Class字节码后，接着就可以使用Class字节码的newInstance方法去创建该类的实例对象了。
有时候，我们程序中所有使用的具体类名在设计时（即开发时）无法确定，只有程序运行时才能确定，这时候就需要使用Class.forName去动态加载该类，这个类名通常是在配置文件中配置的，例如，spring的ioc中每次依赖注入的具体类就是这样配置的，jdbc的驱动类名通常也是通过配置文件来配置的，以便在产品交付使用后不用修改源程序就可以更换驱动类名。
26、大数据量下的分页解决方法。
答：最好的办法是利用sql语句进行分页，这样每次查询出的结果集中就只包含某页的数据内容。再sql语句无法实现分页的情况下，可以考虑对大的结果集通过游标定位方式来获取某页的数据。
sql语句分页，不同的数据库下的分页方案各不一样，下面是主流的三种数据库的分页sql：
sql server:
	String sql = 
	"select top " + pageSize + " * from students where id not in" +

 "(select top " + pageSize * (pageNumber-1) + " id from students order by id)" + 
 
 "order by id";

mysql:
  
	String sql = 
	"select * from students order by id limit " + pageSize*(pageNumber-1) + "," + pageSize;
	
oracle:
 
	String sql = 
	 "select * from " +  
	 (select *,rownum rid from (select * from students order by postime desc) where rid<=" + pagesize*pagenumber + ") as t" + 
	 "where t>" + pageSize*(pageNumber-1);
27、用 JDBC 查询学生成绩单, 把主要代码写出来（考试概率极大）. 
Connection cn = null;
PreparedStatement pstmt =null;
Resultset rs = null;
try
{
	Class.forname(driveClassName);
	cn =  DriverManager.getConnection(url,username,password);
	pstmt = cn.prepareStatement(“select  score.* from score ,student “ + 
		“where score.stuId = student.id and student.name = ?”);
	pstmt.setString(1,studentName);
	Resultset rs = pstmt.executeQuery();
	while(rs.next())
	{
		system.out.println(rs.getInt(“subject”)  +  “    ” + rs.getFloat(“score”) );
	}
}catch(Exception e){e.printStackTrace();}
finally
{
	if(rs != null) try{ rs.close() }catch(exception e){}
	if(pstmt != null) try{pstmt.close()}catch(exception e){}
	if(cn != null) try{ cn.close() }catch(exception e){}
}


28、这段代码有什么不足之处? 
try {
Connection conn = ...;
Statement stmt = ...;
ResultSet rs = stmt.executeQuery("select * from table1");
while(rs.next()) {
}
} catch(Exception ex) {
} 
答：没有finally语句来关闭各个对象，另外，使用finally之后，要把变量的定义放在try语句块的外面，以便在try语句块之外的finally块中仍可以访问这些变量。

29、说出数据连接池的工作机制是什么? 
J2EE服务器启动时会建立一定数量的池连接，并一直维持不少于此数目的池连接。客户端程序需要连接时，池驱动程序会返回一个未使用的池连接并将其表记为忙。如果当前没有空闲连接，池驱动程序就新建一定数量的连接，新建连接的数量有配置参数决定。当使用的池连接调用完成后，池驱动程序将此连接表记为空闲，其他调用就可以使用这个连接。 
实现方式，返回的Connection是原始Connection的代理，代理Connection的close方法不是真正关连接，而是把它代理的Connection对象还回到连接池中。

30、为什么要用 ORM?  和 JDBC 有何不一样? 
orm是一种思想，就是把object转变成数据库中的记录，或者把数据库中的记录转变成objecdt，我们可以用jdbc来实现这种思想，其实，如果我们的项目是严格按照oop方式编写的话，我们的jdbc程序不管是有意还是无意，就已经在实现orm的工作了。
现在有许多orm工具，它们底层调用jdbc来实现了orm工作，我们直接使用这些工具，就省去了直接使用jdbc的繁琐细节，提高了开发效率，现在用的较多的orm工具是hibernate。也听说一些其他orm工具，如toplink,ojb等。 



