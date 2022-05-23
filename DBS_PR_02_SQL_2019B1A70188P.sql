-- Database Creation
CREATE DATABASE `BITSLibrary` /*!40100 DEFAULT CHARACTER SET 
utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT 
ENCRYPTION='N' */;
use BITSLibrary;

-- Relations Creation

create table book(ISBN varchar(13) NOT NULL primary key, 
title varchar(50), author varchar(50), 
copies int default 1);

create table student(SID varchar(13) primary key not null,
password varchar(10) default 'BITS1234',
name varchar(20));

create table issue(IssueID INT NOT NULL
AUTO_INCREMENT PRIMARY KEY,
ISBN varchar(13), SID varchar(13),
dateofissue DATE DEFAULT (DATE_FORMAT(NOW(), '%y-%m-%d')),
constraint fk2 foreign key(ISBN) references book(ISBN),
constraint fk1 foreign key(SID) references student(SID));

create table in_out(inID int auto_increment not null
primary key, sid varchar(13),
intime datetime default current_timestamp,
outtime datetime default null,
constraint fk3 foreign key(sid) references student(SID));

create table roomslots(slotno int primary key,
timeduration varchar(20));

create table room(bookingID INT auto_increment not null
primary key, sid varchar(13),
slotno int, 
bookingdate DATE DEFAULT (DATE_FORMAT(NOW(), '%d-%m-%y')),
constraint fk4 foreign key(sid) references student(SID),
constraint fk5 foreign key(slotno) references roomslots(slotno));

create table admindetails(adminid varchar(6) primary key,
password varchar(10), name varchar(20), postlevel int);

-- Data Insertion

insert into book values ("9789332901384", "Database Concepts",
"Henry F. Korth", 3);
insert into book values ("9788131726228", 
"Microprocessors & Interfacing", "Barry B. Brey", 5);
insert into book values ("9788120340077", 
"Introduction to Algorithms", "Thomas H. Cormen", 3);
insert into book values ("9788120340001",
"FUNDAMENTALS OF WAVELETS", "GOSWAMI, JAIDEVA", 2);
insert into book values ("9788120340002",
"DATA SMART", "FOREMAN, JOHN", 4);
insert into book values ("9788120340003",
"GOD CREATED THE INTEGERS", "HAWKING, STEPHEN", 2);
insert into book values ("9788120340004",
"SUPERFREAKONOMICS", "DUBNER, STEPHEN", 2);
insert into book values ("9788120340005",
"ORIENTALISM", "SAID, EDWARD", 1);
insert into book values ("9788120340006",
"NATURE OF STATISTICAL LEARNING THEORY, THE", "VAPNIK, VLADIMIR", 4);
insert into book values ("9788120340007",
"INTEGRATION OF THE INDIAN STATES", "MENON, V P", 2);
insert into book values ("9788120340008",
"DRUNKARD'S WALK", "MLODINOW, LEONARD", 1);
insert into book values ("9788120340009",
 "IMAGE PROCESSING & MATHEMATICAL MORPHOLOGY", "SHIH, FRANK", 4);
insert into book values ("9788120340010",
"HOW TO THINK LIKE SHERLOCK HOLMES", "KONNIKOVA, MARIA", 1);

insert into student values("2019B1A70734P", "library01",
"Aditya Choraria");
insert into student values("2019B1A70188P", "library02",
"Satyam Srivastava");
insert into student values("2019B1A71019P", "library03",
"Swastik Mantry");
insert into student values("2019B1A30901P", "library04",
"Harshit Jain");
insert into student (SID, name) values("2019B1A41025P",
"Aman Bansal");

insert into issue (ISBN, SID)values("9789332901384",
"2019B1A70188P");

insert into roomslots values (1, "9-10");
insert into roomslots values (2, "10-11");
insert into roomslots values (3, "11-12");
insert into roomslots values (4, "12-13");
insert into roomslots values (5, "13-14");
insert into roomslots values (6, "14-15");
insert into roomslots values (7, "15-16");
insert into roomslots values (8, "16-17");

insert into admindetails values("A19001", "admin123", "Rajesh", 1);
insert into admindetails values("A18001", "admin456", "Pankaj", 0);

-- Procedures & Functions

DELIMITER $$
create procedure GetAllBooks()
begin
start transaction;
select * from bitslibrary.book;
commit;
end$$
DELIMITER ;

call GetAllBooks();

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`QueryBook`(IN searchstring VARCHAR(50))
 READS SQL DATA
 SQL SECURITY INVOKER
 COMMENT 'Query a book by its title or author or ISBN'
BEGIN
start transaction;
select ISBN, title, author, copies- (select count(*) 
from issue i where b.ISBN = i.ISBN) as available_copies from book b
where title like concat('%',searchstring,'%') 
or author like concat('%',searchstring,'%')
or ISBN like concat('%',searchstring,'%'); 
commit;
END$$
DELIMITER ;

call QueryBook('978');

-- To get available copies for issuing the book
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`GetAvailableCopies`(ISBNno varchar(13)) RETURNS int
deterministic
BEGIN
 DECLARE count int;
 select copies-(select count(*) from issue
 where ISBN = ISBNno) into count from book where ISBN = ISBNno; 
 return count;
END $$
DELIMITER ;

select GetAvailableCopies("9789332901384") ;

-- To issue a book
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`isIssuable`(ISBNno varchar(13)) RETURNS varchar(3) CHARSET 
utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE sf_value VARCHAR(3);
if GetAvailableCopies(isbnno) > 0
then set sf_value = "YES";
else set sf_value = "NO";
end if;
return sf_value;
end $$
delimiter ;

Select isIssuable("9789332901384");

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`login`(sid varchar(13), password varchar(10)) 
RETURNS varchar(3) CHARSET 
utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE lstatus VARCHAR(3);
 declare recordfound int;
 select count(*) into recordfound from student s
 where s.SID = sid and s.password = password;
if recordfound = 1
then set lstatus = "YES";
else set lstatus = "NO";
end if;
return lstatus;
end $$
delimiter ;

select login("2019B1A41025P", "BITS1234"); 

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`IssueBookProc`(IN ISBNno VARCHAR(13), IN sid varchar(13),
IN password varchar(10), out issueMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To Issue a book from BITS library'
BEGIN
	if login(sid, password) = "YES" 
    and isIssuable(ISBNno) = "YES"
    Then set issueMessage = "ISSUED";
    else set issueMessage = "Book not available for or login id/password does not match the record";
    end if;
    if issueMessage = "ISSUED"
    then insert into issue (ISBN, SID) values (ISBNno, sid);
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`IssueBookFunc`(ISBNno varchar(13), sid varchar(13), password varchar(10)) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @issueMessage = "";    
	call IssueBookProc(ISBNno, sid, password, @issueMessage);
	return @issueMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`IssueBook`(IN ISBNno VARCHAR(13), IN sid varchar(13),
IN password varchar(10))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To Issue a book from BITS library'
BEGIN
start transaction;
	select IssueBookFunc(ISBNno, sid, password) as IssueBook;
    commit;
    end$$
delimiter ;

call IssueBook("9789332901384", "2019B1A41025P", "BITS1234");

-- To get all the issued books
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`GetIssuedBooks`(IN sid varchar(13))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To get all the books issued by this id number'
BEGIN
start transaction;
	select IssueID, i.ISBN, b.title, dateofissue from issue i,
    book b where b.ISBN = i.ISBN and i.SID = sid;
    commit;
    end$$
delimiter ;

call GetIssuedBooks("2019B1A41025P");

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`GetIssueDate`(sid varchar(13), issueID int) 
RETURNS varchar(10) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @issueDate = null;    
	select dateofissue into @issueDate from issue i
    where i.IssueID = issueID and i.SID =sid;
	return @issueDate;
end $$
Delimiter ;

select GetIssueDate("2019B1A41025P",7);

DELIMITER $$
CREATE DEFINER=`root`@`localhost` function
`CalculateFine`(sid varchar(13), IssueID int) returns int
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To calulate the fine'
BEGIN
	Declare datediff int;
    declare fine int;
	select timestampdiff(day, GetIssueDate(sid, IssueID), 
    current_date) into datediff;
    if datediff is null
    then set datediff=0;
    end if;
	select 2*(datediff-20) into fine;
    if fine<0
    then set fine = 0;
    end if;
    return fine;
    end$$
delimiter ;

select CalculateFine("2019B1A71025P", 8);

-- To return a book

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`isReturnable`(sid varchar(13), issueID int) 
RETURNS varchar(3) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE rstatus VARCHAR(3);
 declare recordfound int;
 select count(*) into recordfound from issue i
 where i.SID = sid and i.IssueID = issueID;
if recordfound >0
then set rstatus = "YES";
else set rstatus = "NO";
end if;
return rstatus;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`ReturnBookProc`(IN sid varchar(13), IN issueID int, 
out returnMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To return a book to BITS library'
BEGIN
	Declare fine int;
    if isReturnable(sid, issueID) = "YES"
    Then set returnMessage = "RETURNED";
    else set returnMessage = "You are not allowed to return
    this book";
    end if;
    
    if returnMessage = "RETURNED"
    then set fine = CalculateFine(sid, issueID);
    end if;
    if returnMessage = "RETURNED"
    then delete from issue i where i.IssueID = issueID;
    end if;
    if returnMessage = "RETURNED"
    then select concat(returnMessage, " with fine: ", fine)
    into returnMessage;
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`ReturnBookFunc`(sid varchar(13), issueID int) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @returnMessage = "";    
	call ReturnBookProc(sid, issueID, @returnMessage);
	return @returnMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`ReturnBook`(IN sid varchar(13), IN issueID int)
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To return a book to BITS library'
BEGIN
start transaction;
	select ReturnBookFunc(sid, issueID) as ReturnBook;
    end$$
    commit;
delimiter ;

call ReturnBook("2019B1A41025P", 5);

-- Entry of students

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`isAlreadyIn`(sid varchar(13)) 
RETURNS varchar(3) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE instatus VARCHAR(3);
 declare recordfound int;
 select count(*) into recordfound from in_out i
 where i.SID = sid and i.outtime is null;
if recordfound >0
then set instatus = "YES";
else set instatus = "NO";
end if;
return instatus;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`EntryProc`(IN sid varchar(13), IN password varchar(10), 
out entryMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To record the entry in BITS library'
BEGIN
	if isAlreadyIn(sid) = "YES" and login(sid, password) = "YES"
    then update in_out i
		set i.outtime = current_timestamp where i.sid = sid;
	end if;
	if login(sid, password) = "YES" 
    Then set entryMessage = "ENTRY REGISTERED";
    else set entryMessage = "Incorrect login id/password";
    end if;
    if entryMessage = "ENTRY REGISTERED"
    then insert into in_out (sid) values (sid);
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`EntryFunc`(sid varchar(13), password varchar(10)) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @entryMessage = "";    
	call EntryProc(sid, password, @entryMessage);
	return @entryMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`Entry`(IN sid varchar(13), IN password varchar(10))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To enter into BITS library'
BEGIN
start transaction;
	select EntryFunc(sid, password) as Entry;
    end$$
    commit;
delimiter ;

call Entry("2019B1A41025P", "BITS1234");

-- Exit of students

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`ExitProc`(IN sid varchar(13), IN password varchar(10), 
out exitMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To record exit from BITS library'
BEGIN
	if isAlreadyIn(sid) = "YES" and login(sid, password) = "YES"
    then update in_out i
		set i.outtime = current_timestamp where i.sid = sid;
	end if;
	if login(sid, password) = "YES" 
    Then set exitMessage = "EXIT REGISTERED";
    else
		set exitMessage = "Incorrect login id/password";
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`ExitFunc`(sid varchar(13), password varchar(10)) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @exitMessage = "";    
	call ExitProc(sid, password, @exitMessage);
	return @exitMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`ExitLibrary`(IN sid varchar(13), IN password varchar(10))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To exit from BITS library'
BEGIN
start transaction;
	select ExitFunc(sid, password) as ExitLibrary;
    commit;
    end$$
delimiter ;

call ExitLibrary("2019B1A41025P", "BITS1234");

-- To find the no. of students present in the library

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`StudentsInLibrary`()
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To find total no. of students in BITS library currently'
BEGIN
start transaction;
	select count(*) as StudentsInLibrary from in_out i where i.outtime is null;
    end$$
    commit;
delimiter ;

call StudentsInLibrary();

-- To get brainstorming room slots

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`GetBrainstormingRoomSlots`()
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To get all the slots of the Brainstorming room'
BEGIN
	select * from roomslots;
    end$$
delimiter ;

call GetBrainstormingRoomSlots();

-- To book brainstorming room

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`isRoomAvailable`(slotno int, bookingdate varchar(10)) 
RETURNS varchar(3) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE bookingstatus VARCHAR(3);
 declare recordfound int;
 select count(*) into recordfound from room r
 where r.slotno = slotno and r.bookingdate = bookingdate;
if recordfound > 0
then set bookingstatus = "NO";
else set bookingstatus = "YES";
end if;
return bookingstatus;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`RoomBookingProc`(IN sid varchar(13), IN password varchar(10), 
IN slotno int, IN bookingdate varchar(10), 
out RoomBookingMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To book a brainstorming room in BITS library'
BEGIN
	if isRoomAvailable(slotno, bookingdate) = "YES" and login(sid, password) = "YES"
    then set RoomBookingMessage = "ROOM BOOKED";
    end if;
	if login(sid, password) = "YES" and isRoomAvailable(slotno, bookingdate) = "NO"
    Then set RoomBookingMessage = "Sorry, Brainstorming room is already booked for this time";
    end if;
    if login(sid, password) = "NO"
    then set RoomBookingMessage = "Incorrect login id/password";
    end if;
    if isRoomAvailable(slotno, bookingdate) = "YES" and login(sid, password) = "YES"
    then insert into room (sid, slotno, bookingdate) values (sid, slotno, bookingdate);
	end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`RoomBookingFunc`(sid varchar(13), password varchar(10),
slotno int, bookingdate varchar(10)) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @RoomBookingMessage = "";    
	call RoomBookingProc(sid, password, slotno,
    bookingdate, @RoomBookingMessage);
	return @RoomBookingMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`BrainstormingBooking`(IN sid varchar(13), IN password varchar(10), IN slotno int,
IN bookingdate varchar(10))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To book brainstorming room in BITS library'
BEGIN
start transaction;
	select RoomBookingFunc(sid, password, slotno, bookingdate) as BrainstormingBooking;
    end$$
    commit;
delimiter ;

call BrainstormingBooking("2019B1A41025P", "BITS1234", 3, "2022-04-08");

-- Admin part of the bits library

delimiter $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`isAdmin`(aid varchar(6), password varchar(10)) 
RETURNS varchar(3) CHARSET 
utf8mb4
 DETERMINISTIC
BEGIN
 DECLARE astatus VARCHAR(3);
 declare recordfound int;
 select count(*) into recordfound from admindetails a
 where a.adminid = aid and a.password = password;
if recordfound = 1
then set astatus = "YES";
else set astatus = "NO";
end if;
return astatus;
end $$
delimiter ;

-- To insert a new book record in the book table of the bits library

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`InsertBookProc`(IN aid varchar(6), IN password varchar(10), IN ISBN varchar(13),
IN title varchar(50), IN author varchar(50), IN copies int, 
out InsertBookMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add a new book to the record of BITS library'
BEGIN
	declare bstatus int;
	select count(*) into bstatus from book b where b.ISBN = ISBN;
	if isAdmin(aid, password) = "YES" 
    then if bstatus=1
			then update book b set b.copies = b.copies+copies where
				b.ISBN = ISBN; 
                set InsertBookMessage = "Book was already present and so its copies has been updated";
		else insert into book values(ISBN, title, author, copies);
			set InsertBookMessage = "Book added successfully";
		end if;
	else set InsertBookMessage = "Invalid Id/password combination";
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`InsertBookFunc`(aid varchar(6), password varchar(10), ISBN varchar(13),
title varchar(50), author varchar(50), copies int) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @InsertBookMessage = "";    
	call InsertBookProc(aid, password, ISBN, title, author,
    copies, @InsertBookMessage);
	return @InsertBookMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`InsertBook`(IN aid varchar(6), IN password varchar(10), IN ISBN varchar(13),
IN title varchar(50), IN author varchar(50), IN copies int)
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add a new book to the record of BITS library'
BEGIN
start transaction;
	select InsertBookFunc(aid, password, ISBN, title, author, copies) as InsertBook;
    end$$
    commit;
delimiter ;

call InsertBook("A19001", "admin123", "9788131726228",	"Microprocessors & Interfacing", "Barry B. Brey", 2);

-- To delete a book
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`DeleteBookProc`(IN aid varchar(6), IN password varchar(10), IN ISBN varchar(13),
IN title varchar(50), IN author varchar(50), IN copies int, 
out DeleteBookMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To delete an already present book from the record of BITS library'
BEGIN
	declare bstatus int;
    declare bcount int;
	select count(*) into bstatus from book b where b.ISBN = ISBN;
    select b.copies into bcount from book b where b.ISBN = ISBN;
    
	if isAdmin(aid, password) = "YES" 
    then if bstatus=1 
			then if bcount-copies < 0
				then set bcount = 0;
                else set bcount = bcount-copies;
                end if;
                update book b set b.copies = bcount where
				b.ISBN = ISBN; 
                set DeleteBookMessage = "Respective copies of book has been deleted";
		else 
			set DeleteBookMessage = "Book not present in the record";
		end if;
	else set DeleteBookMessage = "Invalid Id/password combination";
    end if;
    delete from book b where b.copies=0;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`DeleteBookFunc`(aid varchar(6), password varchar(10), ISBN varchar(13),
title varchar(50), author varchar(50), copies int) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @DeleteBookMessage = "";    
	call DeleteBookProc(aid, password, ISBN, title, author,
    copies, @DeleteBookMessage);
	return @DeleteBookMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`DeleteBook`(IN aid varchar(6), IN password varchar(10), IN ISBN varchar(13),
IN title varchar(50), IN author varchar(50), IN copies int)
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To delete an already present book from the record of BITS library'
BEGIN
start transaction;
	select DeleteBookFunc(aid, password, ISBN, title, author, copies) as DeleteBook;
    end$$
    commit;
delimiter ;

call DeleteBook("A19001", "admin123", "9788131726228",	"Microprocessors & Interfacing", "Barry B. Brey", 2);

-- To add an employee to the record of bitslibrary

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`AddEmpProc`(IN aid varchar(6), IN password varchar(10), IN addid varchar(6),
IN addpassword varchar(10), IN addname varchar(20), IN addpostlevel int, 
out AddEmpMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add an employee to the record of BITS library'
BEGIN
	declare astatus int;
    -- declare bcount int;
	select count(*) into astatus from admindetails a where a.adminid = aid and a.password = password
    and a.postlevel = 0;
    -- select b.copies into bcount from book b where b.ISBN = ISBN;
    
	if isAdmin(aid, password) = "YES" 
    then if astatus=1 
			then insert into admindetails values(addid, addpassword, addname, addpostlevel);
                set AddEmpMessage = "The empoyee has been added to the record of BITS library";
		else set AddEmpMessage = "You cannot add an employee";
        end if;
	else set AddEmpMessage = "Invalid Id/password combination";
    end if;
    delete from book b where b.copies=0;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`AddEmpFunc`(aid varchar(6), password varchar(10), addid varchar(6),
addpassword varchar(10), addname varchar(20), addpostlevel int) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @AddEmpMessage = "";    
	call AddEmpProc(aid, password, addid, addpassword, addname,
    addpostlevel, @AddEmpMessage);
	return @AddEmpMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`AddEmp`(IN aid varchar(6), IN password varchar(10), IN addid varchar(6),
IN addpassword varchar(10), IN addname varchar(20), IN addpostlevel int)
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add an employee to the record of BITS library'
BEGIN
	start transaction;
	select AddEmpFunc(aid, password, addid, addpassword, addname, addpostlevel) as AddEmployee;
    end$$
	commit;
delimiter ;

call AddEmp("A18001", "admin456", "A19002",	"admin789", "Barry B. Brey", 0);

-- To add a student record to the bitslibrary

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`AddStudProc`(IN aid varchar(6), IN password varchar(10), IN addsid varchar(13), 
IN addsname varchar(20), out AddStudMessage varchar(100))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add a student to the record of BITS library'
BEGIN
	declare astatus int;
    -- declare bcount int;
	select count(*) into astatus from student s where s.SID = addsid;
    -- select b.copies into bcount from book b where b.ISBN = ISBN;
    
	if isAdmin(aid, password) = "YES" 
    then if astatus > 0 
			then set AddStudMessage = "Student Already Registered";
		else
			insert into student(SID, name) values(addsid, addsname);
                set AddStudMessage = "The student details has been added to the record of BITS library";
		end if;
	else set AddStudMessage = "Invalid Id/password combination";
    end if;
    end$$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION 
`AddStudFunc`(aid varchar(6), password varchar(10), addsid varchar(13), addsname varchar(20)) 
RETURNS varchar(100) CHARSET utf8mb4
 DETERMINISTIC
BEGIN
	set @AddStudMessage = "";    
	call AddStudProc(aid, password, addsid, addsname, @AddStudMessage);
	return @AddStudMessage;
end $$
delimiter ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE 
`AddStud`(IN aid varchar(6), IN password varchar(10), IN addsid varchar(13), IN addsname varchar(20))
 READS SQL DATA
 DETERMINISTIC
 SQL SECURITY INVOKER
 COMMENT 'To add a student record to the BITS library'
BEGIN
	start transaction;
	select AddStudFunc(aid, password, addsid, addsname) as AddStudent;
    end$$
	commit;
delimiter ;

call AddStud("A18001", "admin456", "2019B1A30902P", "Harshit Jain");









