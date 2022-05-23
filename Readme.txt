CS F212-Database Management Systems
Project :         Library Management System (DBS_PR_02)
Group No.:         58
Member1:         Satyam Srivastava, 2019B1A70188P
Member2:        Aditya Choraria, 2019B1A70734P
-------------------------------------------------------------------------------------------------------------------------------
To load the Database on the local instance of MySQL
* Execute the SQL query file “DBS_PR_02_SQL_2019B1A70188P”
   * The File contains the SQL queries for creating database, tables and relations in order. It also inserts some demo data in those rellations and executes the functions and procedures so as to store them in the cache memory. 
* To test the functionality of the Library Management System
   * Open a new query page on the MySQL workbench and execute the specific query calls for the operation that needs to be performed. 
   * To get the specific queries, please refer to the section “operations” in the document below.


Assumptions
* This Library Management System emulates the BITS Library.
* The Library opens between 9:00 AM to 5:00 PM on all days.
* The Library records only the entry/exit of students with valid ID and name registered in the Library. 
* Book from  the library can only be issued by the person who is registered as student in the Library database.
* Fine is issued if the book is returned after 20 days of issuing, at the rate of rupees 2 per day, which is deducted from the SWD account.
* The room can be booked for the specific time slot with the respective slotID. The library provide functionality to get the slotID for the respective time slot. 
* To book the room for the extended time then, one needs to book the rooms for continuous time slots, based on availability. 
* Book can only be added/deleted in the database of the library by the person with the admin credentials.
* New employees can only be added to the library by the admin with the postlevel ‘0’.
* New student in the library can be registered by the person with admin credentials.




Operations
* Operations:
   * To add an employee record to the library database.
      * SQL query
         * CALL `bitslibrary`.`AddEmp`(<{IN aid varchar(6)}>, <{IN password varchar(10)}>, <{IN addid varchar(6)}>, <{IN addpassword varchar(10)}>, <{IN addname varchar(20)}>, <{IN addpostlevel int}>);
      * Attribute description
         * Aid -> ID of an employee who is already registered as an employee of postlevel 0 in the library.
         * Password-> Password of the employee of postlevel 0.
         * addid-> ID of the employee to be added.
         * addpassword-> password of the employee to be added.
         * addname -> name of the employee to be added
         * addpostlevel-> postlevel of the employee to be added
   * To add a student to the library database.
      * SQL query
         * CALL `bitslibrary`.`AddStud`(<{IN aid varchar(6)}>, <{IN password varchar(10)}>, <{IN addsid varchar(13)}>, <{IN addsname varchar(20)}>);
      * Attribute description
         * Aid -> ID of an employee who is already registered as an employee in the library.
         * Password-> Password of the employee.
         * addsid-> ID of the student to be added.
         * addsname -> name of the student to be added.
   * To add a book to the library database.
      * SQL Query
         * CALL `bitslibrary`.`InsertBook`(<{IN aid varchar(6)}>, <{IN password varchar(10)}>, <{IN ISBN varchar(13)}>, <{IN title varchar(50)}>, <{IN author varchar(50)}>, <{IN copies int}>);
      * Attribute description
         * Aid -> ID of an employee who is already registered as an employee in the library.
         * Password-> Password of the employee.
         * ISBN-> ISBN no, of the book to be added.
         * Title-> Title of the book to be added.
         * Author-> Author of the book to be added.
         * Copies-> No. of copies of the book to be added.
   * To delete a book from the library database.
      * SQL Query
         * CALL `bitslibrary`.`DeleteBook`(<{IN aid varchar(6)}>, <{IN password varchar(10)}>, <{IN ISBN varchar(13)}>, <{IN title varchar(50)}>, <{IN author varchar(50)}>, <{IN copies int}>);
      * Attribute description
         * Aid -> ID of an employee who is already registered as an employee in the library.
         * Password-> Password of the employee.
         * ISBN-> ISBN no, of the book to be deleted.
         * Title-> Title of the book to be deleted
         * Author-> Author of the book to be deleted.
         * Copies-> No. of copies of the book to be deleted.
   * To get the record of all the books in the library database.
      * SQL query
         * CALL `bitslibrary`.`GetAllBooks`();
      * Attribute description
         * None
   * To search for books using a given string
      * SQL query
         * CALL `bitslibrary`.`QueryBook`(<{IN searchstring VARCHAR(50)}>);
      * Attribute description
         * searchstring-> the string that is to be used for searching
   * To issue a book from the library
      * SQL query
         * CALL `bitslibrary`.`IssueBook`(<{IN ISBNno VARCHAR(13)}>, <{IN sid varchar(13)}>, <{IN password varchar(10)}>);
      * Attribute description
         * ISBNno-> ISBN of the book to be issued
         * sid-> ID of the student who is issuing the book
         * password-> password of the student issuing the book.
   * To get all the books currently in issue by a particular student
      * SQL query
         * CALL `bitslibrary`.`GetIssuedBooks`(<{IN sid varchar(13)}>);
      * Attribute description
         * sid-> ID of the student whose list of books issued is to be determined.
   * To return the book previously issued by a student
      * SQL query
         * CALL `bitslibrary`.`ReturnBook`(<{IN sid varchar(13)}>, <{IN issueID int}>);
      * Attribute description
         * sid-> ID of the student returning the book.
         * issueID-> ID of the issue of the book which he/she is returning.
   * To calculate the fine applicable to a student
      * SQL query
         * Select `bitslibrary`.`CalculateFine`(<{sid varchar(13)}>, <{IssueID int}>)
      * Attribute description
         * sid-> ID of the student whose fine needs to be calculated
         * IssueID-> ID of the issue of the book for which the fine needs to be calculated
   * To register the in-time of a student
      * SQL query
         * CALL `bitslibrary`.`Entry`(<{IN sid varchar(13)}>, <{IN password varchar(10)}>);
      * Attribute description
         * sid-> ID of the student who is coming in the library.
         * password-> password of the student who is coming in the library
   * To register the ou-time of a student
      * SQL query
         * CALL `bitslibrary`.`ExitLibrary`(<{IN sid varchar(13)}>, <{IN password varchar(10)}>);
      * Attribute description
         * sid-> ID of the student who is going out of the library.
         * password-> password of the student who is going out of the library
   * To know the slot number for various time durations
      * SQL query
         * CALL `bitslibrary`.`GetBrainstormingRoomSlots`();
      * Attribute description
         * None
   * To book the brainstorming room
      * SQL query
         * CALL `bitslibrary`.`BrainstormingBooking`(<{IN sid varchar(13)}>, <{IN password varchar(10)}>, <{IN slotno int}>, <{IN bookingdate varchar(10)}>);
      * Attribute description
         * sid-> ID of the student who is booking the room
         * password-> password of the student who is booking the room
         * slotno-> slot no. of the time period for which the room is to be booked
         * bookingdate-> the date for which the room is to be booked.