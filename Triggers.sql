--1.	Чтобы при взятии определенной книги, ее кол-во уменьшалось на 1. 
CREATE TABLE Student(
ID INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(255),
BooksQuantity INT,
FirstBook INT, 
SecondBook INT, 
ThirdBook INT, 
)
GO  
INSERT INTO dbo.Student
(
    Name,
    BooksQuantity,
    FirstBook,
    SecondBook,
    ThirdBook
)
VALUES
(   N'Test2', -- Name - nvarchar(255)
    0,   -- BooksQuantity - int
    0,   -- FirstBook - int
    0,   -- SecondBook - int
    0    -- ThirdBook - int
    )
GO

create trigger TakeBook ON books 
FOR UPDATE AS
Declare @Code FLOAT, @StudID INT, @SBQuantity INT, @BQuantity INT, @TStudID INT = 0
SELECT @Code = Code, @StudID = StudentID, @BQuantity = quantity FROM Inserted
SELECT @TStudID = StudentID FROM Deleted
SELECT @SBQuantity = BooksQuantity FROM dbo.Student WHERE ID = @StudID
IF	(@BQuantity>0)
BEGIN
	 IF	(@SBQuantity < 3) 
	 BEGIN 
		IF(@SBQuantity=0)UPDATE dbo.Student SET FirstBook = @Code WHERE dbo.Student.ID = @StudID
		ELSE IF(@SBQuantity=1)UPDATE dbo.Student SET SecondBook = @Code WHERE dbo.Student.ID = @StudID
		ELSE UPDATE dbo.Student SET ThirdBook = @Code WHERE dbo.Student.ID = @StudID
		UPDATE dbo.Student SET BooksQuantity = BooksQuantity + 1 WHERE ID = @StudID 
		UPDATE books SET quantity = quantity - 1 WHERE books.Code = @Code 
	 END
	 ELSE BEGIN RAISERROR ('Каждый студент может взять не больше трех книг!',0,1) UPDATE dbo.books SET StudentID = 0 WHERE books.Code = @Code  END
END
ELSE 
BEGIN
	RAISERROR('Эта книга на руках!',0,1) 
	UPDATE dbo.books SET StudentID = @TStudID WHERE Code = @Code
END 
GO
--Check1 

--UPDATE dbo.books SET StudentID = 1 WHERE dbo.books.Code = 5110--5110, 4316, 5516,4043
--GO	
--UPDATE dbo.books SET StudentID = 1 WHERE dbo.books.Code = 4316--5110, 4316, 5516,4043
--GO
--UPDATE dbo.books SET StudentID = 1 WHERE dbo.books.Code = 5516--5110, 4316, 5516,4043
--GO
--UPDATE dbo.books SET StudentID = 2 WHERE dbo.books.Code = 4043--5110, 4316, 5516,4043
--GO
--DROP TRIGGER ReturnBooks
--GO 
--DROP TRIGGER TakeBook
--GO 
--UPDATE dbo.Student SET BooksQuantity = 0
--GO 
--UPDATE dbo.Student SET FirstBook = 0
--GO 
--UPDATE dbo.Student SET SecondBook = 0
--GO 
--UPDATE dbo.Student SET ThirdBook = 0
--GO 
--UPDATE dbo.books SET quantity = 1
--GO 
--UPDATE dbo.books SET StudentID = 0
--GO 
--SELECT DISTINCT b.quantity, b.StudentID, s.Name, s.BooksQuantity, s.FirstBook, s.SecondBook, s.ThirdBook 
--FROM books b, dbo.Student s WHERE b.StudentID = s.ID
--GO
--SELECT b.N, b.Code, b.Name,b.quantity, b.StudentID, s.Name,s.BooksQuantity, s.FirstBook, s.SecondBook, s.ThirdBook FROM dbo.books b, dbo.Student s 
--GO 
--GO
--ALTER	TABLE dbo.books
--DROP	CONSTRAINT FK_books_StudentID
--GO 
--ALTER TABLE dbo.books WITH CHECK ADD CONSTRAINT FK_books_StudentID FOREIGN KEY (StudentID) REFERENCES dbo.Student (ID)
--GO 
--INSERT INTO [BooksOnHands] 
--SELECT *FROM dbo.books
--GO 
--UPDATE [BooksOnHands] SET quantity = 0
--GO 
--ALTER TABLE books
--DROP COLUMN Count
--GO
--ALTER TABLE books
--DROP CONSTRAINT FK_books_StudentID
--GO 
--ALTER TABLE dbo.books ADD StudentID int FOREIGN KEY REFERENCES Student(ID) 
--GO 
--DROP TRIGGER TakeBook
--GO 

--alter table books
--add quantity int default 1
--GO 
--UPDATE dbo.books SET quantity = 1
--GO 
--INSERT INTO [BooksOnHands] 
--SELECT * FROM dbo.books
--GO 
--UPDATE [BooksOnHands] SET quantity = 0
--GO 
--ALTER TABLE books
--DROP COLUMN Count
--GO
--ALTER TABLE books
--DROP CONSTRAINT DF__books__Count__46E78A0C
--GO 
--ALTER TABLE dbo.books ADD StudentID int FOREIGN KEY REFERENCES Student(ID) 
--GO 
GO

--2.Чтобы при возврате определенной книги, ее кол-во увеличивалось на 1. 
--3.	Чтобы нельзя было выдать книгу, которой уже нет в библиотеке (по кол-ву). 
--4.	Чтобы нельзя было выдать более трех книг одному студенту. 
DROP TRIGGER TakeBook
GO

CREATE TRIGGER ReturnBooks ON dbo.Student FOR UPDATE AS 
Declare @StudID INT, @First INT, @Second INT, @Third INT,@TFirst INT, @TSecond INT, @TThird INT,  @SBQuantity int
SELECT @StudID = ID,  @First = FirstBook, @Second = SecondBook, @Third = ThirdBook FROM Inserted
SELECT @TFirst = FirstBook, @TSecond = SecondBook, @TThird = ThirdBook, @SBQuantity = BooksQuantity FROM Deleted
IF(@SBQuantity > 0)
BEGIN
	IF(@First=0)
	BEGIN  
		IF	(@TFirst = 0)BEGIN RAISERROR('Эта книга уже была возвращена.',0,1)END
		ELSE 
		BEGIN 
			UPDATE dbo.Student SET BooksQuantity = BooksQuantity - 1 WHERE dbo.Student.ID = @StudID
			UPDATE dbo.books SET quantity = quantity + 1 WHERE dbo.books.Code = @TFirst 
			RAISERROR('Книга была успешно возвращена.',0,1)
		END 
	END
	ELSE IF(@Second= 0) 
	BEGIN
		IF(@TSecond = 0) BEGIN RAISERROR('Эта книга уже была возвращена.',0,1) END 
		ELSE 
		BEGIN	
			UPDATE dbo.Student SET BooksQuantity = BooksQuantity - 1 WHERE dbo.Student.ID = @StudID
			UPDATE dbo.books SET quantity = quantity + 1 WHERE dbo.books.Code = @TSecond 
			RAISERROR('Книга была успешно возвращена.',0,1)
		END 
	END
	ELSE 
	BEGIN 
		IF(@TThird = 0)BEGIN RAISERROR('Эта книга уже была возвращена.',0,1)END
		ELSE 
		BEGIN
			UPDATE dbo.Student SET BooksQuantity = BooksQuantity - 1 WHERE dbo.Student.ID = @StudID
			UPDATE dbo.books SET quantity = quantity + 1 WHERE dbo.books.Code = @TThird
			RAISERROR('Книга была успешно возвращена.',0,1)
		END 
	END
END
ELSE RAISERROR ('Студент вернул все книги!',0,1)
GO 
--Check2
--UPDATE dbo.Student SET FirstBook = 0 WHERE ID = 1
--GO 

--SELECT DISTINCT b.StudentID, s.Name, s.BooksQuantity, s.FirstBook, s.SecondBook, s.ThirdBook 
--FROM books b, dbo.Student s WHERE b.StudentID = s.ID
--GO
--SELECT b.N, b.Code, b.Name,b.quantity, b.StudentID, s.Name,s.BooksQuantity, s.FirstBook, s.SecondBook, s.ThirdBook FROM dbo.books b, dbo.Student s 
--GO 
--DROP TRIGGER dbo.ReturnBooks
GO 

--5.	Чтобы при удалении книги, данные о ней копировались в таблицу Удаленные. 
CREATE TABLE [dbo].[DeletedBooks] (
    [N]           INT            NOT NULL,
    [Code]        FLOAT (53)     NULL,
    [New]         BIT            NOT NULL,
    [Name]        NVARCHAR (255) NULL,
    [Price]       MONEY          NULL,
    [Pages]       FLOAT (53)     NULL,
    [Format]      NVARCHAR (255) NULL,
    [Date]        DATETIME       NULL,
    [Pressrun]    FLOAT (53)     NULL,
    [Id_press]    INT            NULL,
    [Id_theme]    INT            NULL,
    [id_category] INT            NULL,
    [quantity]	  INT            NULL,
    [LastStudID]  INT            NULL,
);
GO 

CREATE TRIGGER DeleteBook on books for delete as
Declare @N int, @Code float, @New Bit, @Name nvarchar(255), @Price money, 
@Pages float,@Format nvarchar(255), @Date datetime, @Pressrun float, 
@Id_press int, @Id_theme int, @Id_category INT, @quatity INT , @StudID INT 
select @N = N, @Code = Code, @New = New, @Name = Name, @Price = Price, @Pages = Pages,
@Date = Date, @Pressrun = Pressrun, @Id_press = Id_press, @Id_theme = Id_theme, @Id_category = id_category,
@Format = Format, @quatity = quantity, @StudID = StudentID FROM Deleted
insert into DeletedBooks values (@N,@Code,@New,@Name,@Price,@Pages,@Format,
@Date,@Pressrun,@Id_press,@Id_theme,@Id_category, @quatity, @StudID)
--Check3
--delete from books
--      where books.n = 3
--go
--select * from dbo.books
--go 
--select * from dbo.deletedbooks
GO 

--6.	Если книга добавляется в базу, она должна быть удалена из таблицы Удаленные.
CREATE TRIGGER DeleteFromArhiveBook on dbo.DeletedBooks for delete as
Declare @N int, @Code float, @New Bit, @Name nvarchar(255), @Price money, 
@Pages float,@Format nvarchar(255), @Date datetime, @Pressrun float, 
@Id_press int, @Id_theme int, @Id_category INT, @quatity INT , @StudID INT 
select @N = N, @Code = Code, @New = New, @Name = Name, @Price = Price, @Pages = Pages,
@Date = Date, @Pressrun = Pressrun, @Id_press = Id_press, @Id_theme = Id_theme, @Id_category = id_category,
@Format = Format, @quatity = quantity, @StudID = Deleted.LastStudID FROM Deleted
insert into books values (@N,@Code,@New,@Name,@Price,@Pages,@Format,
@Date,@Pressrun,@Id_press,@Id_theme,@Id_category, @quatity, @StudID)
GO
--Check4
--DELETE FROM dbo.DeletedBooks
--      WHERE DeletedBooks.N = 3
--GO
--SELECT * FROM dbo.books --WHERE dbo.books.N = 3
--GO 
--SELECT * FROM dbo.DeletedBooks
--GO
--DROP TRIGGER DeleteFromArhiveBook
