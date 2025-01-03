-- 1---------------------------------------------
WITH ZodiacResults AS (
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
    FROM Customers
)

SELECT 
    ZodiacSign,
    COUNT(*) AS SignCount
FROM ZodiacResults
GROUP BY ZodiacSign;

SELECT 
    ZodiacAnimal,
    COUNT(*) AS AnimalCount
FROM ZodiacResults
GROUP BY ZodiacAnimal;

SELECT 
    ZodiacSign,
    ZodiacAnimal,
    COUNT(*) AS CombinedCount
FROM ZodiacResults
GROUP BY ZodiacSign, ZodiacAnimal;


-- 2---------------------------------------------

DECLARE @UpperLimit INT = 10;

WITH FibonacciCTE (Position, Value1, Value2) AS (
    SELECT 
        1 AS Position, 
        0 AS Value1, 
        1 AS Value2
    UNION ALL
    SELECT 
        Position + 1,
        Value2,
        Value1 + Value2
    FROM FibonacciCTE
    WHERE Position < @UpperLimit
)
SELECT 
    Position AS FibonacciIndex, 
    Value1 AS FibonacciNumber
FROM FibonacciCTE
OPTION (MAXRECURSION 0);


-- 3---------------------------------------------

DECLARE @Number INT = 48;

SELECT COUNT(*) AS DivisorCount
FROM master..spt_values
WHERE type = 'P'
  AND number BETWEEN 1 AND @Number
  AND @Number % number = 0;

  
-- 4---------------------------------------------
WITH TransactionData AS (
    SELECT 
        t.TransactionID, 
        t.TransactionDate, 
        t.Currency, 
        t.TransactionTypeID, 
        t.Amount, 
        t.DebitAccountID, 
        t.CreditAccountID,
        CASE 
            WHEN t.Amount < 1000 THEN 'Low'
            WHEN t.Amount BETWEEN 1000 AND 5000 THEN 'Medium'
            ELSE 'High'
        END AS Segment
    FROM 
        Transactions t
),
CustomerData AS (
    SELECT 
        c.CustomerID,
        c.CustomerAddress,
        c.CustomerFirstName,
        c.CustomerLastName,
        c.IsJuridical,
        c.City,
        c.State,
        c.BirthDate,
        c.EmailAddress,
        c.Phone
    FROM 
        Customers c
)
SELECT 
    c.CustomerID,
    c.CustomerFirstName,
    c.CustomerLastName,
    c.City,
    c.State,
    t.Segment
FROM 
    CustomerData c
JOIN 
    TransactionData t 
    ON c.CustomerID = t.DebitAccountID OR c.CustomerID = t.CreditAccountID
WHERE 
    c.CustomerID = 50;


	
-- 5---------------------------------------------
USE DB_BANK;

CREATE TABLE [loan].[Schedules] (
    Id INT NOT NULL IDENTITY(1,1),
    LoanId INT NOT NULL FOREIGN KEY REFERENCES [loan].[loans]([LoanID]),
    Payment MONEY NOT NULL,
    PaymentDate DATE NOT NULL
);
DECLARE @LoanId INT = 1;  
DECLARE @LoanAmount MONEY;
DECLARE @InterestRate DECIMAL(5,2);
DECLARE @LoanTerm INT;  
DECLARE @PaymentDay INT;  
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @MonthlyPayment MONEY;
DECLARE @CurrentDate DATE;

SELECT 
    @LoanAmount = Amount,
    @InterestRate = InterestRate,
    @LoanTerm = DATEDIFF(MONTH, StartDate, EndDate),
    @PaymentDay = PaymentDay,
    @StartDate = StartDate,
    @EndDate = EndDate
FROM [loan].[loans]
WHERE LoanID = @LoanId;

SET @MonthlyPayment = (@LoanAmount * (1 + @InterestRate / 100)) / @LoanTerm;

SET @CurrentDate = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO [loan].[Schedules] (LoanId, Payment, PaymentDate)
    VALUES (@LoanId, @MonthlyPayment, @CurrentDate);

    SET @CurrentDate = DATEADD(MONTH, 1, @CurrentDate);

    IF DAY(@CurrentDate) < @PaymentDay
    BEGIN
        SET @CurrentDate = DATEADD(DAY, @PaymentDay - DAY(@CurrentDate), @CurrentDate);
    END
    ELSE
    BEGIN
        SET @CurrentDate = DATEADD(DAY, @PaymentDay - DAY(@CurrentDate), @CurrentDate);
    END
END

	
-- 6---------------------------------------------
WITH DepositAndLoan AS (
    SELECT 
        d.CustomerID,
        d.Amount AS DepositAmount,
        l.Amount AS LoanAmount,
        ROW_NUMBER() OVER (PARTITION BY d.CustomerID ORDER BY d.StartDate) AS RowNum
    FROM [dbo].[Deposits] d
    JOIN [loan].[Loans] l
        ON d.CustomerID = l.CustomerID
    WHERE d.Amount > 10000 
    AND l.Amount > 10000    
)
SELECT CustomerID, DepositAmount, LoanAmount
FROM DepositAndLoan
WHERE RowNum = 1; 
