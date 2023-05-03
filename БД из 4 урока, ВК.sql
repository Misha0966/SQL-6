-- Сложные запросы с использованием JOIN
use vk;
-- cross join
SELECT * FROM users, messages;
SELECT count(*) FROM users, messages;

SELECT * FROM users
JOIN messages;

SELECT * FROM users u
JOIN messages m WHERE u.id=m.from_user_id;

-- INNER JOIN
SELECT * FROM users u
JOIN messages m ON u.id=m.from_user_id;


-- подсчитать количество сообщений, написанных каждым пользователем. 
SELECT 
count(*) cnt,
u.firstname as 'имя',
u.lastname as 'ф а м и л и я'
FROM users u
JOIN messages m ON u.id=m.from_user_id
GROUP BY u.id
ORDER BY cnt desc;

-- LEFT JOIN
SELECT * FROM users u
LEFT JOIN messages m ON u.id=m.from_user_id
ORDER BY m.id;

-- RIGHT JOIN
SELECT u.*, m.* FROM messages m
RIGHT JOIN users u ON u.id=m.from_user_id
ORDER BY m.id;

-- FULL JOIN
-- SELECT u.*, m.* FROM users u
-- FULL JOIN messages m ON u.id=m.from_user_id
-- ORDER BY m.id;

SELECT u.*, m.*  FROM users u
LEFT JOIN messages m ON u.id=m.from_user_id
UNION
SELECT u.*, m.*  FROM users u
RIGHT JOIN messages m ON u.id=m.from_user_id;

SELECT u.* FROM messages m
RIGHT JOIN users u ON u.id=m.from_user_id
WHERE m.id is Null;

-- Выборка данных по пользователю
SELECT 
	firstname, 
	lastname, 
	(SELECT hometown FROM profiles WHERE user_id = 1) AS city,
	(SELECT filename FROM media WHERE id = 
	    (SELECT photo_id FROM profiles WHERE user_id = 1)
	) AS main_photo
FROM users 
WHERE id=1;

SELECT 
	u.firstname, 
	u.lastname, 
	p.hometown AS city,
	m.filename AS main_photo
FROM users u
JOIN profiles p ON  u.id=p.user_id 
JOIN media m ON p.photo_id=m.id
WHERE u.id=1;

 
-- Выборка документов пользователя
SELECT m.user_id, m.body, m.created_at
  FROM media m
    JOIN users u ON m.user_id = u.id     
  WHERE m.user_id = 1;

  
-- Сообщения к пользователю
SELECT m.body, firstname, lastname, m.created_at
  FROM messages m
    JOIN users u ON u.id = m.to_user_id
  where u.id = 1;
  
-- Сообщения от пользователя
SELECT  m.body, u.firstname, u.lastname, m.created_at
  FROM messages m
    JOIN users u ON u.id = m.from_user_id
    where u.id = 1;


-- Количество друзей у всех пользователей
SELECT firstname, lastname, COUNT(*) AS total_friends
FROM users
JOIN friend_requests ON (users.id = friend_requests.initiator_user_id OR users.id = friend_requests.target_user_id)
WHERE friend_requests.status = 'approved'
GROUP BY users.id;

 
-- Количество друзей у всех пользователей с сортировкой и псевдонимами
SELECT u.firstname, u.lastname, COUNT(*) AS total_friends
  FROM users u
    JOIN friend_requests fr ON (u.id = fr.initiator_user_id or u.id = fr.target_user_id)
  where fr.status = 'approved'
  GROUP BY u.id
  ORDER BY total_friends DESC;

 
-- Выборка документов друзей пользователя
SELECT 
 m.*
  FROM media m
    JOIN friend_requests fr ON m.user_id = fr.target_user_id
    JOIN users u ON fr.initiator_user_id = u.id -- кому я отправлял заявку в друзья
  WHERE u.id = 1
  	and fr.status = 'approved'
UNION
select 
 m.*
  FROM media m
    JOIN friend_requests fr ON m.user_id = fr.initiator_user_id
    JOIN users u ON fr.target_user_id = u.id   -- кто мне отправлял заявку в друзья
  WHERE u.id = 1
  	and fr.status = 'approved';

 
SELECT 
 m.*
  FROM media m
    JOIN friend_requests fr ON 
    	(fr.initiator_user_id = m.user_id AND fr.target_user_id =1)
    	OR 
    	(fr.target_user_id = m.user_id AND fr.initiator_user_id =1) 
  WHERE fr.status = 'approved';


-- Список медиафайлов пользователя с количеством лайков
SELECT 
	m.filename,
	COUNT(*) AS total_likes,
	CONCAT(u.firstname, ' ', u.lastname) AS owner
	FROM media m
	JOIN likes l ON l.media_id = m.id
	JOIN users u ON u.id = m.user_id
WHERE u.id=1
GROUP BY m.id;


  
-- Количество групп у пользователей
SELECT u.firstname, u.lastname, COUNT(*) AS total_communities
  FROM users u
    JOIN users_communities u_c ON u.id = u_c.user_id
  GROUP BY u.id
  ORDER BY total_communities DESC;

-- Среднее количество групп у всех пользователей    
SELECT AVG(total_communities) AS average_communities
  FROM (
    SELECT u.firstname, u.lastname, COUNT(*) AS total_communities
	  FROM users u
	    JOIN users_communities u_c ON u.id = u_c.user_id
	  GROUP BY u.id
	  ORDER BY total_communities DESC
  ) AS list;
  
-- 3 пользователя с наибольшим количеством лайков за медиафайлы
SELECT 
	firstname, lastname,
	media.filename,
	count(*) as likes_count
  FROM users
    JOIN media ON users.id = media.user_id
    JOIN likes ON media.id = likes.media_id
  GROUP BY users.id
  ORDER BY likes_count DESC
  LIMIT 3;

-- количество пользователей в сообществах
SELECT 
	COUNT(*) AS cnt,
	c.name
FROM users_communities u_c 
	JOIN  communities c ON c.id=u_c.community_id
GROUP BY c.id  
ORDER BY cnt DESC; 



