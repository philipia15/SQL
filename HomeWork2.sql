--1----------------------------------------------------------
SELECT *
FROM [loan].[Loans] l
JOIN deposits d
ON l.LoanID != d.DepositID;

--ჩვეულებრივი JOIN ოპერაცია ემყარება ტოლობის პრინციპს (=), რაც გვეხმარება ცხრილების კონკრეტულ ჩანაწერებს შორის შესაბამისობების პოვნაში.
--მაგრამ != გამოყენებისას, იქმნება ისეთი პირობა, სადაც თითოეული ჩანაწერი უკავშირდება ყველა იმ ჩანაწერს მეორე ცხრილში, რომელიც მას არ ემთხვევა.

--2----------------------------------------------------------
SELECT 
    t.TransactionID,
    t.TransactionDate,
    t.Currency,
    t.Amount,
    t.Purpose,
    d.CustomerFirstName AS DebitFirstName,
    d.CustomerLastName AS DebitLastName,
    c.CustomerFirstName AS CreditFirstName,
    c.CustomerLastName AS CreditLastName
FROM 
    Transactions t
LEFT JOIN Customers d ON t.DebitAccountID = d.CustomerID
LEFT JOIN Customers c ON t.CreditAccountID = c.CustomerID;



--3----------------------------------------------------------

SELECT c.CustomerID, c.CustomerFirstName, c.CustomerLastName
FROM Customers c
WHERE 
    (c.CustomerID IN (SELECT d.CustomerID FROM [Deposits] d) AND c.CustomerID NOT IN (SELECT l.CustomerID FROM [loan].[Loans] l))
    OR 
    (c.CustomerID IN (SELECT l.CustomerID FROM [loan].[Loans] l) AND c.CustomerID NOT IN (SELECT d.CustomerID FROM [Deposits] d));

--4----------------------------------------------------------
SELECT 
	CustomerID,
	Amount,
	Currency,
    COALESCE(Purpose, 'No Purpose Provided') AS Purpose
FROM [loan].[Loans];


--5----------------------------------------------------------
SELECT 
    CustomerID,
    CustomerFirstName,
    CustomerLastName,
    EmailAddress,
    Phone,
    CASE
        WHEN EmailAddress LIKE '%@gmail%' THEN SUBSTRING(EmailAddress, 1, CHARINDEX('@', EmailAddress) - 1)
        ELSE EmailAddress
    END AS FilteredEmail,

    CASE
        WHEN Phone LIKE '+995%' THEN 'Georgia'
        ELSE 'Other'
    END AS PhoneProvider,
    DATEDIFF(YEAR, BirthDate, GETDATE()) - 
        CASE 
            WHEN MONTH(BirthDate) > MONTH(GETDATE()) OR (MONTH(BirthDate) = MONTH(GETDATE()) AND DAY(BirthDate) > DAY(GETDATE())) 
            THEN 1 
            ELSE 0 
        END AS AgeInYears
FROM Customers
WHERE LEN(CustomerFirstName) <= 10;


--6----------------------------------------------------------

SELECT 
    DATEADD(DAY, 18000, '2001-06-15') AS DateAfter18000Days,
    DATENAME(MONTH, DATEADD(DAY, 18000, '2001-06-15')) AS MonthAfter18000Days,
    DATENAME(YEAR, DATEADD(DAY, 18000, '2001-06-15')) AS YearAfter18000Days,
    DATENAME(WEEKDAY, DATEADD(DAY, 18000, '2001-06-15')) AS DayOfWeekAfter18000Days

--7----------------------------------------------------------

SELECT 
    LoanID,
    DATEDIFF(DAY, StartDate, EndDate) AS LoanDurationDays
FROM 
    [loan].[Loans];
--8----------------------------------------------------------

SELECT 
    REVERSE(SUBSTRING(REVERSE('Diego Armando Maradona'), 1, CHARINDEX(' ', REVERSE('Diego Armando Maradona')) - 1)) AS LastName;

--9----------------------------------------------------------

SELECT State, COUNT(CustomerID) AS CustomerCount
FROM Customers
GROUP BY State;

--10----------------------------------------------------------
DECLARE @usd_to_gel FLOAT = 2.85;  -- USD to GEL
DECLARE @eur_to_gel FLOAT = 3.40;  -- EUR to GEL
DECLARE @gbp_to_gel FLOAT = 3.55;  -- GBP to GEL

SELECT 
    c.CustomerID,
    c.CustomerFirstName + ' ' + c.CustomerLastName AS CustomerFullName,
    MIN(CASE 
            WHEN l.Currency = 'USD' THEN l.Amount * @usd_to_gel
            WHEN l.Currency = 'EUR' THEN l.Amount * @eur_to_gel
            WHEN l.Currency = 'GBP' THEN l.Amount * @gbp_to_gel
            ELSE l.Amount 
        END) AS MinLoanAmountGEL,
    MAX(CASE 
            WHEN l.Currency = 'USD' THEN l.Amount * @usd_to_gel
            WHEN l.Currency = 'EUR' THEN l.Amount * @eur_to_gel
            WHEN l.Currency = 'GBP' THEN l.Amount * @gbp_to_gel
            ELSE l.Amount 
        END) AS MaxLoanAmountGEL,
    COUNT(l.LoanID) AS TotalLoans
FROM 
    Customers c
JOIN 
    [loan].[Loans] l ON c.CustomerID = l.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerFirstName, c.CustomerLastName;


--11----------------------------------------------------------
SELECT 
    d.CustomerID,
    SUM(d.Amount) AS TotalDeposits,
    COALESCE(SUM(o.OverDraftAmount), 0) AS TotalOverdrafts,
    (SUM(d.Amount) - COALESCE(SUM(o.OverDraftAmount), 0)) AS BalanceDifference
FROM 
    Deposits d
LEFT JOIN 
    OverDrafts o ON d.CustomerID = o.AccountID
GROUP BY 
    d.CustomerID
UNION
SELECT 
    o.AccountID AS CustomerID,
    0 AS TotalDeposits,
    SUM(o.OverDraftAmount) AS TotalOverdrafts,
    (-1) * SUM(o.OverDraftAmount) AS BalanceDifference
FROM 
    OverDrafts o
GROUP BY 
    o.AccountID;


--12----------------------------------------------------------
SELECT 
    SUBSTRING(CustomerAddress, 1, CHARINDEX('st', CustomerAddress) + 2) AS StreetName,
    COUNT(*) AS NumberOfPeople
FROM 
    Customers
GROUP BY 
    SUBSTRING(CustomerAddress, 1, CHARINDEX('st', CustomerAddress) + 2)
HAVING 
    COUNT(*) > 1
ORDER BY 
    NumberOfPeople DESC;


--13----------------------------------------------------------

SELECT 
    CustomerID, 
    SUM(Amount) AS TotalDebt
FROM (
    SELECT 
        o.AccountID AS CustomerID, 
        o.OverDraftAmount AS Amount
    FROM OverDrafts o
    
    UNION ALL
    
    SELECT 
        l.CustomerID, 
        l.Amount
    FROM [loan].[Loans] l
) AS CombinedAmounts
GROUP BY CustomerID
HAVING SUM(Amount) > 50000

--14----------------------------------------------------------
SELECT DISTINCT l.CustomerID
FROM [loan].[Loans]  l
WHERE NOT EXISTS (
    SELECT 1
    FROM Deposits d
    WHERE d.CustomerID = l.CustomerID
)