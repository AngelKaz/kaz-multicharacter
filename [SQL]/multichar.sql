USE `vrpfx`;

CREATE TABLE IF NOT EXISTS vrp_user_identities(
	`user_id` int(11),
	`registration` varchar(100),
	`phone` varchar(100),
	`firstname` varchar(100),
	`name` varchar(100),
	`age` int(11),
	`height` VARCHAR(50),
	`sex` TEXT
);
