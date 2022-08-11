use friendbook;

INSERT INTO user (full_name, username, bio, date_of_birth)
VALUES
('Johnny Appleseed', 'johnny_appleseed', 'This is John\'s bio!', '1993-10-19');

INSERT INTO user (full_name, username, bio, date_of_birth)
VALUES
('Dexter', 'dexter', 'I love technology!', '1995-10-01');

INSERT INTO user (full_name, username, bio, date_of_birth)
VALUES
('Ron Macdonald', 'ron_mac', 'Ron. CEO. Father.', '1969-01-01');

INSERT INTO user (full_name, username, bio, date_of_birth)
VALUES
('Chad Thunder', 'chad_thunder', 'This is Chad!', '1980-10-10');

SELECT id INTO @johnny_id FROM user WHERE full_name = 'Johnny Appleseed' LIMIT 1;
SELECT id INTO @dexter_id FROM user WHERE full_name = 'Dexter' LIMIT 1;
SELECT id INTO @ron_id FROM user WHERE full_name = 'Ron Macdonald' LIMIT 1;
SELECT id INTO @chad_id FROM user WHERE full_name = 'Chad Thunder' LIMIT 1;

# friendship between Johnny Appleseed and Dexter
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@johnny_id, @dexter_id);
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@dexter_id, @johnny_id);

# friendship between Johnny Appleseed and Ron Macdonald
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@johnny_id, @ron_id);
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@ron_id, @johnny_id);

# friendship between Johnny Appleseed and Chad Thunder
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@johnny_id, @chad_id);
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@chad_id, @johnny_id);

# friendship between Dexter and Chad Thunder
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@dexter_id, @chad_id);
INSERT INTO friendship (fk_friend_one_id, fk_friend_two_id) VALUES (@chad_id, @dexter_id);

# posts by Johnny
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@johnny_id, 'Hello, world!', NOW() - INTERVAL 3 DAY);
SELECT LAST_INSERT_ID() INTO @first_post_id;
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@johnny_id, 'I love the weather in Singapore.', NOW() - INTERVAL 2 DAY);
SELECT LAST_INSERT_ID() INTO @second_post_id;
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@johnny_id, 'Can\'t wait for the holidays...', NOW() - INTERVAL 1 DAY);
SELECT LAST_INSERT_ID() INTO @third_post_id;

# posts by Dexter
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@dexter_id, 'I would go out tonight, but I haven\'t got a stitch to wear.', NOW() - INTERVAL 3 DAY);
SELECT LAST_INSERT_ID() INTO @fourth_post_id;
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@dexter_id, 'We can go for a walk where it\'s quiet and dry.', NOW() - INTERVAL 2 DAY);
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@dexter_id, 'I listen to The Smiths btw.', NOW() - INTERVAL 1 DAY);

# posts by Ron
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@ron_id, 'I can recite pi to the 50th decimal place.', NOW() - INTERVAL 1 DAY);

# posts by Chad
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@chad_id, 'Work hard play hard!', NOW() - INTERVAL 1 DAY);
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@chad_id, 'Stay hungry my friends!', NOW() - INTERVAL 2 DAY);
INSERT INTO post (fk_poster_id, text_body, created_at) VALUES (@chad_id, 'I need a job.', NOW() - INTERVAL 3 DAY);

# insert likes
INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@dexter_id, @first_post_id);
INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@chad_id, @first_post_id);
INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@ron_id, @first_post_id);

INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@dexter_id, @second_post_id);
INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@chad_id, @second_post_id);

INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@ron_id, @third_post_id);

INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@ron_id, @fourth_post_id);
INSERT INTO likes (fk_user_id, fk_post_id) VALUES (@johnny_id, @fourth_post_id);
