CREATE DATABASE friendbook;

use friendbook;

CREATE TABLE user (
	id INT NOT NULL AUTO_INCREMENT,
    full_name varchar(255) NOT NULL,
    username varchar(255) NOT NULL,
    bio varchar(255) NOT NULL DEFAULT '',
	date_of_birth Date NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE (username)
);

CREATE TABLE post (
    id INT NOT NULL AUTO_INCREMENT,
    fk_poster_id INT NOT NULL,
    text_body TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    FOREIGN KEY (fk_poster_id) REFERENCES user(id) ON DELETE CASCADE
);


CREATE TABLE likes (
    id INT NOT NULL AUTO_INCREMENT,
    fk_user_id INT NOT NULL,
    fk_post_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE KEY (fk_user_id, fk_post_id),
    FOREIGN KEY (fk_user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (fk_post_id) REFERENCES post(id) ON DELETE CASCADE
);

CREATE TABLE friendship (
	id INT NOT NULL AUTO_INCREMENT,
    fk_friend_one_id INT NOT NULL,
    fk_friend_two_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE KEY (fk_friend_one_id, fk_friend_two_id),
    FOREIGN KEY (fk_friend_one_id) REFERENCES user(id),
    FOREIGN KEY (fk_friend_two_id) REFERENCES user(id)
);