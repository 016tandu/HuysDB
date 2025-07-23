CREATE FUNCTION dbo.bangCuuChuong_WhileLoop (@n INT)
RETURNS @tbl TABLE -- Declare the table variable that the function will return
(
    Product INT -- Define the schema (column name and data type) for the returned table
)
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @p INT = 0;

    WHILE (@i <= 10)
    BEGIN
        SET @p = @n * @i;

        INSERT INTO @tbl (Product)
        VALUES (@p);

        SET @i = @i + 1;
    END;

    -- The table variable @tbl is implicitly returned when the function block ends.
    -- No explicit RETURN statement with a value is needed here, just 'RETURN;' to exit.
    RETURN;
END;
GO

select * from dbo.bangCuuChuong_WhileLoop(800)



--- function nh?p ng�y th�ng v� query ra s?n ph?m b�n ch?y nh?t trong th�ng ?� 





