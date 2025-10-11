gitCREATE TABLE book(
/* тип данных для book_id автоматическая нумерация, где дается значение +1 для каждой последующей строки */
book_id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(50),
author VARCHAR(30),
price DECIMAL(8, 2),
amount INT
);

INSERT INTO book 
VALUES ('Belaya gvardia', 'Bulgakov M.A.', 540.50, 5),
('Idiot', 'Dostoevsky F.M.', 460.00, 10),
('Bratya Karamazovy', 'Dostoevsky F.M.', 799.01, 2);

SELECT * FROM book;

SELECT author, title, price FROM book;

/* даем свой псевдоним существующим колонкам в таблице*/
SELECT author AS Автор, title AS Название, price AS Цена
FROM book;

SELECT title, author, price, amount,
/* цену умножаем на кол-во и представляем в колонке total*/
price * amount AS total
FROM book;

SELECT title, author, price,
/* округляем значение до целого числа до запятой*/
ROUND (price * (1+30/100), 0) AS new_price
FROM book;

SELECT *,
ROUND(
/*условия, при которых будет выводиться определенное значение в колонке new_price*/
CASE 
WHEN price > 600 THEN price * 0.8 
WHEN price > 500 THEN price * 0.9
ELSE price END, 2) AS new_price
FROM book;  

SELECT author = author, price * amount 
FROM book
WHERE price * amount > 5000;

/* открыть БД */
use bulochka

/* выборка определенных строк из таблицы, Приоритеты операций:
1. круглые скобки
2. умножение  (*),  деление (/)
3. сложение  (+), вычитание (-)
4. операторы сравнения (=, >, <, >=, <=, <>), BETWEEN, IN
5. NOT
6. AND
7. OR */

SELECT author, price, amount
FROM book
WHERE amount >= 5 AND amount <= 10 AND price * amount > 3000;

SELECT author, title
FROM book
WHERE amount BETWEEN 3 AND 15 AND author IN ('Dostoevsky F.M.', 'Esenin S.A.');

SELECT author AS Автор, title AS Название
FROM book
WHERE amount BETWEEN 2 AND 14 
/* сортировка по столбцам, ACS - по возрастанию, DESC - по убыванию */
ORDER BY author DESC, title;

SELECT title, author
FROM book
/* поиск по совпадению: '%' - любые значения от 0 символов, '_' - 1 любой символ */
WHERE title LIKE '_% _%' AND author LIKE '% %M.%'
ORDER BY title; 

/* выбирает уникальные значения в столбце amount */
SELECT DISTINCT amount 
FROM book;

SELECT amount 
FROM book
/* группирует одинаковые значения в столбце amount в одну строку */
GROUP BY amount;

/* COUNT - считает количество строк (записей) у группы, SUM - суммирует значения в определенном столбце для группы */
SELECT author AS Автор, COUNT(title) AS Количество_произведений, SUM(amount) AS Всего_книг, SUM(price*amount) AS Общая_цена 
FROM book
GROUP BY author;

/* MIN - вычисляет минимальное значение в столбце у группы, MAX - максимальное, AVG - среднее */
SELECT author, MIN(price) AS min_price, MAX(price) AS max_price, AVG(price) AS average_price, MIN(amount) AS min_amount, MAX(amount) AS max_amount
FROM book
GROUP BY author;

SELECT author,
SUM(price * amount) AS Стоимость
FROM book
WHERE title NOT IN ("Идиот", "Белая гвардия")
GROUP BY author
порядок выполнения  SQL запроса на выборку на СЕРВЕРЕ:

/* порядок выполнения  SQL запроса на выборку на СЕРВЕРЕ:
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY */

SELECT author,
SUM(price * amount) AS Стоимость
FROM book
WHERE title NOT IN ("Идиот", "Белая гвардия")
GROUP BY author
/* Сначала определяется таблица, из которой выбираются данные (FROM), затем из этой таблицы отбираются записи в соответствии с условием  WHERE, выбранные данные агрегируются (GROUP BY), из агрегированных записей выбираются те, которые удовлетворяют условию после HAVING */
HAVING Стоимость > 5000
ORDER BY Стоимость DESC;

SELECT author, title, price
FROM book
/* Вложенный запрос (поскольку мы не можем использовать оператор AVG в WHERE)- делаем выборку тех книг, цены которых меньше или равны средней цене книг на складе */
WHERE price <= (SELECT AVG(price) FROM book)
ORDER BY price DESC;

SELECT author, title, price
FROM book
/* выборка книг, цены которых превышают минимальную цену книги на складе не более чем на 150 рублей  */
WHERE price <= (SELECT MIN(price) FROM book)+150
ORDER BY price ASC;

SELECT author, title, price
FROM book
/* Оператор ANY возвращает true (истина), если какое-либо из значений подзапроса удовлетворяет условию */
WHERE price < ANY (
    SELECT  MIN(price)
    FROM book
    GROUP BY author
);

SELECT title, author, amount, price
FROM book
/* Оператор ALL возвращает true (истина), если все значения подзапроса удовлетворяют условию */
WHERE amount < ALL (
        SELECT AVG(amount) 
        FROM book 
        GROUP BY author 
      );

/* Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы на складе стало одинаковое количество экземпляров каждой книги, 
равное значению самого большего количества экземпляров одной книги на складе. Вывести название книги, ее автора, текущее количество экземпляров 
на складе и количество заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.*/
SELECT title, author, amount, 
    ((SELECT MAX(amount) FROM book) - amount) AS Заказ
FROM book
WHERE ((SELECT MAX(amount) FROM book)- amount) > 0;