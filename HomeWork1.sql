--1 . გავაკეთოთ Where-ის მაგალითები კავშირებით

--ყველა აქტიური ანგარიში, რომელიც არის EUR ვალუტაში და AccountTypeID არის 1 და IsActive = 0;
SELECT * 
FROM Accounts
WHERE Currency = 'EUR' AND AccountTypeID = 1 AND IsActive = 0;

-- ყველა ანგარიში, რომელიც არ არის EUR ვალუტაში ან არ არის აქტიური
SELECT AccountID, AccoutNumber, Currency, IsActive 
FROM Accounts
WHERE Currency != 'EUR' OR IsActive = 0;

-- ანგარიშები, რომელთა კლიენტის ID არის 100 და 300-ის შორის
SELECT * 
FROM Accounts
WHERE CustomerID >= 100 AND CustomerID <= 110;

--ყველა ანგარიში, სადაც ვალუტა არის EUR ან GPB, მაგრამ სტატუსი აქტიური არ არის
SELECT * 
FROM Accounts
WHERE (Currency = 'EUR' OR Currency = 'GPB') AND NOT IsActive = 1;

--ყველა ანგარიშის შერჩევა, რომლებიც გაიხსნა 2017 წელს და არ არის GPB ვალუტაში
SELECT * 
FROM Accounts
WHERE OpenDate >= '2017-01-01' AND OpenDate < '2018-01-01' AND Currency != 'GPB';

--ყველა აქტიური ანგარიში, რომელიც USD ან EUR ვალუტაშია და CustomerID მეტია 200-ზე
SELECT AccountID, AccoutNumber, Currency, CustomerID, IsActive 
FROM Accounts
WHERE IsActive = 1 AND (Currency = 'USD' OR Currency = 'EUR') AND CustomerID > 200;


--2 .გავაკეთოთ Where-ში რთული პირობა, მინიმუმ 4 გამონათქვამით

SELECT * 
FROM Customers
WHERE 
    (City = 'Los Angeles' OR City = 'San Antonio') 
    AND (State = 'California' OR State = 'Texas')
    AND NOT (BirthDate < '1990-01-01')
    AND NOT (IsJuridical = 0);

--OR: მომხმარებელი უნდა იყოს Los Angeles-ში ან San Antonio-ში.
--AND: შტატი უნდა იყოს California ან Texas.
--NOT: მომხმარებელი არ უნდა იყოს დაბადებული 1990 წლამდე.
--NOT: მომხმარებელი არ უნდა იყოს ფიზიკური პირი (IsJuridical = 0)

SELECT *
FROM Customers
WHERE 
    (City = 'Los Angeles' OR City = 'San Diego') 
    AND State = 'California'
    AND NOT IsJuridical = 1
    AND (BirthDate < '1995-01-01' OR BirthDate > '2001-01-01');

--OR: მომხმარებელი უნდა იყოს Los Angeles-ში ან San Diego-ში.
--AND: შტატი უნდა იყოს California.
--NOT: მომხმარებელი არ უნდა იყოს იურიდიული პირი
--დაბადებული უნდა იყოს 1995-დან 2001 წლამდე

--3. გავაკეთოთ სელექთი ჩვეულებრივი IN-ოპერატორით და BETWEEN ით 

SELECT LoanID, CustomerID, Amount, Currency
FROM [loan].[Loans]
WHERE Currency IN ('USD', 'EUR');

SELECT LoanID, CustomerID, Amount, Currency
FROM [loan].[Loans]
WHERE FilialID NOT IN (1, 2, 3, 7, 8);

SELECT LoanID, CustomerID, Amount, InterestRate
FROM [loan].[Loans]
WHERE Amount BETWEEN 70000 AND 80000;

SELECT LoanID, CustomerID, Amount, Currency, StartDate
FROM [loan].[Loans]
WHERE Currency IN ('USD', 'EUR')
  AND FilialID NOT IN (1, 2, 3, 7, 8)
  AND Amount BETWEEN 40000 AND 50000
  AND StartDate BETWEEN '2019-01-01' AND '2024-01-01';

--4. გავაკეთოთ IN-ში ჩადგმული Select-ით

SELECT *
FROM Deposits
WHERE Amount > (
    SELECT AVG(Amount)
    FROM Deposits
);

--Nested SELECT: SELECT მოაქვს დეპოზიტების საშუალო თანხა AVG(Amount).
--Outer SELECT: ძირითად SELECT ოპერაციაში იფილტრება ყველა ის ჩანაწერი, რომლის Amount საშუალოზე მეტია.
--ჩვენ ვიღებთ ცხრილიდან იმ დეპოზიტარების ინფორმაციას, რომლებიც საშუალოზე მეტი თანხის დეპოზიტს ფლობენ.

--5
SELECT *
FROM 
    Customers c
WHERE 
    LEFT(CustomerFirstName, 1) IN ('A', 'B', 'C') 
    AND LEN(CustomerFirstName) >= 5
    AND CustomerID IN (
        SELECT DISTINCT CustomerID 
        FROM Deposits
    )
ORDER BY 
    CustomerID DESC;


--6. დავწეროთ სელექთი რომელიც უნიკალურ ჩანაწერებს მოგვცემს მომხმარებლის სახელი და გვარი-ს ჭრილში.

SELECT DISTINCT CustomerFirstName, CustomerLastName
FROM Customers;

--7. დავადგინოთ თითოეული მომხმარებელი რის წელიწადშია დაბადებული და რა არის ზოდიაქოთი. წელიც და თვეც. 2 ვე ერთ სელექთში

SELECT 
    CustomerID,
    CustomerFirstName,
    CustomerLastName,
    YEAR(BirthDate) AS BirthYear,
    MONTH(BirthDate) AS BirthMonth,
    CASE 
        WHEN (MONTH(BirthDate) = 1 AND DAY(BirthDate) >= 20) OR (MONTH(BirthDate) = 2 AND DAY(BirthDate) <= 18) THEN 'Aquarius'
        WHEN (MONTH(BirthDate) = 2 AND DAY(BirthDate) >= 19) OR (MONTH(BirthDate) = 3 AND DAY(BirthDate) <= 20) THEN 'Pisces'
        WHEN (MONTH(BirthDate) = 3 AND DAY(BirthDate) >= 21) OR (MONTH(BirthDate) = 4 AND DAY(BirthDate) <= 19) THEN 'Aries'
        WHEN (MONTH(BirthDate) = 4 AND DAY(BirthDate) >= 20) OR (MONTH(BirthDate) = 5 AND DAY(BirthDate) <= 20) THEN 'Taurus'
        WHEN (MONTH(BirthDate) = 5 AND DAY(BirthDate) >= 21) OR (MONTH(BirthDate) = 6 AND DAY(BirthDate) <= 20) THEN 'Gemini'
        WHEN (MONTH(BirthDate) = 6 AND DAY(BirthDate) >= 21) OR (MONTH(BirthDate) = 7 AND DAY(BirthDate) <= 22) THEN 'Cancer'
        WHEN (MONTH(BirthDate) = 7 AND DAY(BirthDate) >= 23) OR (MONTH(BirthDate) = 8 AND DAY(BirthDate) <= 22) THEN 'Leo'
        WHEN (MONTH(BirthDate) = 8 AND DAY(BirthDate) >= 23) OR (MONTH(BirthDate) = 9 AND DAY(BirthDate) <= 22) THEN 'Virgo'
        WHEN (MONTH(BirthDate) = 9 AND DAY(BirthDate) >= 23) OR (MONTH(BirthDate) = 10 AND DAY(BirthDate) <= 22) THEN 'Libra'
        WHEN (MONTH(BirthDate) = 10 AND DAY(BirthDate) >= 23) OR (MONTH(BirthDate) = 11 AND DAY(BirthDate) <= 21) THEN 'Scorpio'
        WHEN (MONTH(BirthDate) = 11 AND DAY(BirthDate) >= 22) OR (MONTH(BirthDate) = 12 AND DAY(BirthDate) <= 21) THEN 'Sagittarius'
        WHEN (MONTH(BirthDate) = 12 AND DAY(BirthDate) >= 22) OR (MONTH(BirthDate) = 1 AND DAY(BirthDate) <= 19) THEN 'Capricorn'
    END AS ZodiacSign, 
	CASE 
        WHEN YEAR(BirthDate) % 12 = 0 THEN 'Rooster'
        WHEN YEAR(BirthDate) % 12 = 1 THEN 'Dog'
        WHEN YEAR(BirthDate) % 12 = 2 THEN 'Pig'
        WHEN YEAR(BirthDate) % 12 = 3 THEN 'Chicken'
        WHEN YEAR(BirthDate) % 12 = 4 THEN 'Ox'
        WHEN YEAR(BirthDate) % 12 = 5 THEN 'Tiger'
        WHEN YEAR(BirthDate) % 12 = 6 THEN 'Rabbit'
        WHEN YEAR(BirthDate) % 12 = 7 THEN 'Snake'
        WHEN YEAR(BirthDate) % 12 = 8 THEN 'Horse'
        WHEN YEAR(BirthDate) % 12 = 9 THEN 'Sheep'
        WHEN YEAR(BirthDate) % 12 = 10 THEN 'Dragon'
        WHEN YEAR(BirthDate) % 12 = 11 THEN 'Monkey'
    END AS ZodiacAnimal
FROM Customers;

