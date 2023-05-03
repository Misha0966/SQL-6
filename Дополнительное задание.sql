DELIMITER $$
CREATE PROCEDURE get_random_users(IN user_id INT) -- Cоздание процедуры, которая решает следующую задачу:
-- Выбрать для одного пользователя 5 пользователей в случайной комбинации, которые удовлетворяют хотя бы одному критерию:
-- 1) из одного города
-- 2) состоят в одной группе
-- 3) друзья друзей
BEGIN
    DECLARE city_id INT;
    DECLARE group_id INT;
    DECLARE friend_of_friend_id INT;
    SET city_id = (SELECT hometown FROM profiles WHERE user_id = user_id);
    SET group_id = (SELECT group_id FROM group_members WHERE user_id = user_id);
    SET friend_of_friend_id = (SELECT f2.friend_id
                                FROM friend_requests f1
                                JOIN friend_requests f2 ON f1.target_user_id = f2.initiator_user_id
                                WHERE f1.initiator_user_id = user_id AND f2.friend_id != user_id
                                ORDER BY RAND() LIMIT 1);
    SELECT id, firstname, lastname
    FROM users
    WHERE city_id IS NOT NULL AND city_id = (SELECT hometown FROM profiles WHERE user_id = id) AND id <> user_id
    UNION
    SELECT u.id, u.firstname, u.lastname
    FROM group_members gm
    JOIN users u ON u.id = gm.user_id
    WHERE gm.group_id = group_id AND u.id <> user_id
    UNION
    SELECT friend_id, firstname, lastname
    FROM friends
    WHERE user_id = friend_of_friend_id AND friend_id <> user_id
    ORDER BY RAND() LIMIT 5;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION popularity_coefficient(user_id INT) RETURNS FLOAT -- сохдание функции популярности пользователя
BEGIN
    DECLARE friends_count INT;
    DECLARE mutual_friends_count INT;
    SET friends_count = (SELECT COUNT(*) FROM friend_requests WHERE (initiator_user_id = user_id OR target_user_id = user_id) AND status = 'approved');
    SET mutual_friends_count = (SELECT COUNT(f1.friend_id)
                                FROM friend_requests f1 JOIN friend_requests f2 ON f1.target_user_id = f2.initiator_user_id AND f1.initiator_user_id = f2.target_user_id AND f1.status = 'approved' AND f2.status = 'approved'
                                WHERE f1.initiator_user_id = user_id OR f1.target_user_id = user_id);
    RETURN (mutual_friends_count + friends_count) / (SELECT COUNT(*) FROM users);
END$$
DELIMITER ;