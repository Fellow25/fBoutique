ALTER TABLE `users` ADD  `boutique_coin` int(11) NOT NULL DEFAULT 0;
ALTER TABLE `users` ADD  `boutique_id` int(11) NOT NULL;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('yusuf', 'Skin de luxe', 1, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('grip', 'Poignée', 1, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('flashlight', 'Lampe', 1, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('silencieux', 'Silencieux', 1, 0, 1);