-- 1. Создайте функцию, которая принимает кол-во сек и формат их в кол-во дней часов.

DELIMITER $$
CREATE FUNCTION format_time(seconds INT, format_type VARCHAR(50))
RETURNS VARCHAR(255)
BEGIN
    DECLARE formatted_time VARCHAR(255);
    IF format_type = 'days_hours_minutes_seconds' THEN
        SET formatted_time = CONCAT(FLOOR(seconds / 86400), ' days ',
            FLOOR((seconds % 86400) / 3600), ' hours ',
            FLOOR(((seconds % 86400) % 3600) / 60), ' minutes ',
            MOD(seconds, 60), ' seconds');
    ELSEIF format_type = 'hours_minutes_seconds' THEN
        SET formatted_time = CONCAT(FLOOR(seconds / 3600), ' hours ',
            FLOOR((seconds % 3600) / 60), ' minutes ',
            MOD(seconds, 60), ' seconds');
    ELSEIF format_type = 'minutes_seconds' THEN
        SET formatted_time = CONCAT(FLOOR(seconds / 60), ' minutes ',
            MOD(seconds, 60), ' seconds');
    ELSEIF format_type = 'seconds' THEN
        SET formatted_time = CONCAT(seconds, ' seconds');
    END IF;
    RETURN formatted_time;
END$$
DELIMITER ;

-- 2. Выведите только четные числа от 1 до 10.

SELECT * FROM (
     SELECT 1 as number UNION ALL
     SELECT 2 as number UNION ALL
     SELECT 3 as number UNION ALL
     SELECT 4 as number UNION ALL
     SELECT 5 as number UNION ALL
     SELECT 6 as number UNION ALL
     SELECT 7 as number UNION ALL
     SELECT 8 as number UNION ALL
     SELECT 9 as number UNION ALL
     SELECT 10 as number
 ) numbers
 WHERE number % 2 = 0;