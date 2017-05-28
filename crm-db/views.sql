/* MembersView */
DROP VIEW IF EXISTS `MembersView`;
CREATE ALGORITHM=UNDEFINED VIEW `MembersView` AS 
	SELECT 
		`u`.`id` AS `id`,
		`u`.`username` AS `username`,
		CONCAT_WS(' ',`u`.`first_name`,`u`.`last_name`) AS `name`,
		`u`.`email` AS `email`,
		(SELECT id FROM `crm_programs` WHERE id = `u`.`program_id` AND is_active = 1) AS `program_id`,
		`u`.`message_push_type` AS `message_push_type`,
		REPLACE(REPLACE(REPLACE(REPLACE(`u`.`contact_number`, ' ', ''), '-', ''), ')', ''), '(', '') AS `contact_number`,
		`u`.`second_phone_no` AS `second_phone_no`,
		`u`.`role` AS `role`,
		`u`.`avatar` AS `avatar`,
		`u`.`date_of_birth` AS `date_of_birth`,
		IF(COALESCE(`u`.`package`, '') = '', IF(COALESCE(`u`.`department`, '')='','',`u`.`department`), `u`.`package`) AS `detail`,
		`u`.`location` AS `location`,
		`u`.`body_comp` AS `body_comp`,
		`u`.`waist` AS `waist`,
		`c`.`name` AS `client_name`,
		`u`.`client_id` AS `client_id`,
		`u`.`partner_id` AS `partner_id`,
		`ha`.`lead_coach` AS `lead_coach_id`,
		(SELECT CONCAT_WS(' ',`first_name`,`last_name`) FROM `users` WHERE `id` = `ha`.`lead_coach`) AS `lead_coach`,
		`func_get_last_touch_date`(`ha`.`assessment_date`,`ha`.`lastcall_date`,`ha`.`last_sms_date`,`ha`.`last_email_date`) AS `last_touch_date`,
		CASE (`func_get_last_touch_date`(`ha`.`assessment_date`,`ha`.`lastcall_date`,`ha`.`last_sms_date`,`ha`.`last_email_date`)) COLLATE latin1_swedish_ci
			WHEN DATE_FORMAT(`ha`.`last_email_date`, '%m/%d/%Y') THEN 'last_email_date'
			WHEN DATE_FORMAT(`ha`.`last_sms_date`, '%m/%d/%Y') THEN 'last_sms_date'
			WHEN DATE_FORMAT(`ha`.`lastcall_date`,  '%m/%d/%Y' ) THEN 'lastcall_date'
			WHEN (SELECT DATE_FORMAT(`app_chat_messages`.`created_at`, '%m/%d/%Y') FROM `app_chat_messages` WHERE `thread_id` = `u`.`id` ORDER BY `app_chat_messages`.`created_at` DESC LIMIT 0,1) THEN 'last_appchat_date'
			WHEN DATE_FORMAT(`ha`.`assessment_date`,  '%m/%d/%Y' ) THEN 'assessment_date'
			ELSE NULL
		END AS `last_touch_field`,
		DATE_FORMAT(`ha`.`lastcall_date`,  '%m/%d/%Y' ) AS `lastcall_date`,
		DATE_FORMAT(`ha`.`assessment_date`,  '%m/%d/%Y' ) AS `assessment_date`,
		`ha`.`last_email_date` AS `last_email_date`,
		`ha`.`last_sms_date` AS `last_sms_date`,
		`u`.`last_login` AS `last_login`,
		/*(SELECT IF(FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(created_at), INTERVAL (9-DAYOFWEEK(DATE(created_at)))%7 DAY))/7)+1 != 52, (FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(created_at), INTERVAL (9-DAYOFWEEK(DATE(created_at)))%7 DAY))/7)+1)%52, 52) FROM `crm_user_program_history` WHERE user_id = u.id ORDER BY created_at DESC LIMIT 1) AS program_week,*/
		IF(`u`.`message_push_type` LIKE 'Manual', (SELECT manual_week_no FROM `crm_user_program_history` WHERE user_id = `u`.`id` AND program_id = `u`.`program_id` AND is_active = 1 ORDER BY id DESC LIMIT 1), (SELECT IF(FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(created_at), INTERVAL (9-DAYOFWEEK(DATE(created_at)))%7 DAY))/7)+1 != 52, (FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(created_at), INTERVAL (9-DAYOFWEEK(DATE(created_at)))%7 DAY))/7)+1)%52, 52) FROM `crm_user_program_history` WHERE user_id = `u`.`id` AND program_id = `u`.`program_id` AND is_active = 1 ORDER BY created_at DESC LIMIT 1)) AS program_week,
		`u`.`is_active` AS `is_active`,
		`u`.`is_via` AS `is_via`,
		`u`.`replenish` AS `replenish`,
		IF(FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(`u`.`created_at`), INTERVAL (9-DAYOFWEEK(DATE(`u`.`created_at`)))%7 DAY))/7)+1 != 52, (FLOOR(DATEDIFF(CURDATE(),DATE_ADD(DATE(`u`.`created_at`), INTERVAL (9-DAYOFWEEK(DATE(`u`.`created_at`)))%7 DAY))/7)+1)%52, 52) as `current_week`,
		`func_member_engagement_level`(CAST(DATE_FORMAT(STR_TO_DATE(`func_get_last_touch_date`(`ha`.`assessment_date`,`ha`.`lastcall_date`,`ha`.`last_sms_date`,`ha`.`last_email_date`), '%m/%d/%Y'), '%Y-%m-%d') as date),CAST(`ha`.`lastcall_date` as date),CAST(`u`.`updated_at` as date)) AS `engaged`,
		`u`.`created_at` AS `created_at`,
		`u`.`updated_at` AS `updated_at` 
	FROM ( `users` `u` LEFT JOIN `clients` `c` ON `u`.`client_id` = `c`.`id` LEFT JOIN `health_admins` `ha` ON `u`.`id` = `ha`.`user_id`) 
	WHERE `u`.`role` LIKE 'UE' AND `u`.`client_id` IS NOT NULL AND `u`.`partner_id` = 13 AND 
		SUBSTR( `u`.`email`, INSTR( `u`.`email`,  '@' ) +1 ) NOT LIKE '%\_%';

/* UserEmailView */

DROP VIEW IF EXISTS `UserEmailView`;
CREATE ALGORITHM = UNDEFINED VIEW `UserEmailView` AS 
(
	SELECT 
		`weekly_emails`.`subject` AS `subject`,
		`weekly_emails`.`content` AS `content`,
		NULL AS `user_id`,
		`weekly_emails`.`week_number` AS `week_number`,
		`weekly_emails`.`is_active` AS `is_active`,
		`weekly_emails`.`created_at` AS `created_at`,
		`weekly_emails`.`updated_at` AS `updated_at`,
		`weekly_emails`.`deleted_at` AS `deleted_at`		
	FROM `weekly_emails`
) UNION (
	SELECT 
		`uwe`.`subject` AS `subject`,
		`uwe`.`content` AS `content`,
		`uwe`.`user_id` AS `user_id`,
		`uwe`.`week_number` AS `week_number`,
		`uwe`.`is_active` AS `is_active`,
		`uwe`.`created_at` AS `created_at`,
		`uwe`.`updated_at` AS `updated_at`,
		`uwe`.`deleted_at` AS `deleted_at`
	FROM (`user_weekly_emails` `uwe` LEFT JOIN `users` `u` ON((`uwe`.`user_id` = `u`.`id`))) 
	WHERE ((`u`.`role` = 'UE') AND (`u`.`is_active` = 1))
);

/* UserMessageView */

DROP VIEW IF EXISTS `UserMessageView`;
CREATE ALGORITHM = UNDEFINED VIEW `UserMessageView`AS 
(
	SELECT 
		week_number,
		day_1, 
		day_1_content, 
		day_2, 
		day_2_content, 
		day_3, 
		day_3_content, 
		is_active,
		NULL AS user_id, 
		deleted_at,
		created_at, 
		updated_at 
	FROM weekly_messages
) UNION (
	SELECT 
		`uwm`.`week_number` AS `week_number`,
		`uwm`.`day_1` AS `day_1`,
		`uwm`.`day_1_content` AS `day_1_content`,
		`uwm`.`day_2` AS `day_2`,
		`uwm`.`day_2_content` AS `day_2_content`, 
		`uwm`.`day_3` AS `day_3`,
		`uwm`.`day_3_content` AS `day_3_content`,
		`uwm`.`is_active` AS `is_active`, 
		`uwm`.`user_id` AS `user_id`,
		`uwm`.`deleted_at` AS `deleted_at`,
		`uwm`.`created_at` AS `created_at`,
		`uwm`.`updated_at` AS `updated_at` 
	FROM (`user_weekly_messages` `uwm` LEFT JOIN `users` `u` ON((`uwm`.`user_id` = `u`.`id`))) 
	WHERE ((`u`.`role` = 'UE') AND (`u`.`is_active` = 1))
);

DROP VIEW IF EXISTS `UserSpecificProgramEmails`;
CREATE ALGORITHM = UNDEFINED VIEW `UserSpecificProgramEmails` AS 
(
	SELECT 
		NULL AS `user_id`,
		`crm_program_weekly_emails`.`crm_programs_id` AS `crm_programs_id`,
		`crm_program_weekly_emails`.`subject` AS `subject`,
		`crm_program_weekly_emails`.`content` AS `content`,
		`crm_program_weekly_emails`.`week_number` AS `week_number`,
		NULL AS `user_response`,
		NULL AS `user_message`,
		`crm_program_weekly_emails`.`is_active` AS `is_active`,
		NULL AS `deleted_at`,
		`crm_program_weekly_emails`.`updated_at` AS `updated_at`,
		`crm_program_weekly_emails`.`created_at` AS `created_at` 
	FROM `crm_program_weekly_emails`
)
UNION
(
	SELECT 
		`uwe`.`user_id` AS `user_id`,
		`uwe`.`crm_programs_id` AS `crm_programs_id`,
		`uwe`.`subject` AS `subject`,
		`uwe`.`content` AS `content`,
		`uwe`.`week_number` AS `week_number`,
		`uwe`.`user_response` AS `user_response`,
		`uwe`.`user_message` AS `user_message`,
		`uwe`.`is_active` AS `is_active`,
		`uwe`.`deleted_at` AS `deleted_at`,
		`uwe`.`updated_at` AS `updated_at`,
		`uwe`.`created_at` AS `created_at` 
	FROM (`crm_user_program_weekly_emails` `uwe` LEFT JOIN `users` `u` ON((`uwe`.`user_id` = `u`.`id`))) 
	WHERE ((`u`.`role` = 'UE') AND (`u`.`is_active` = 1))
);

DROP VIEW IF EXISTS `UserSpecificProgramSMS`;
CREATE ALGORITHM = UNDEFINED VIEW `UserSpecificProgramSMS` AS 
(
	SELECT 
		NULL AS `user_id`,
		`crm_program_weekly_messages`.`crm_programs_id` AS `crm_programs_id`,
		`crm_program_weekly_messages`.`week_number` AS `week_number`,
		`crm_program_weekly_messages`.`day_1` AS `day_1`,
		`crm_program_weekly_messages`.`day_1_content` AS `day_1_content`,
		`crm_program_weekly_messages`.`day_1_memes` AS `day_1_memes`,
		`crm_program_weekly_messages`.`day_2` AS `day_2`,
		`crm_program_weekly_messages`.`day_2_content` AS `day_2_content`,
		`crm_program_weekly_messages`.`day_2_memes` AS `day_2_memes`,
		`crm_program_weekly_messages`.`day_3` AS `day_3`,
		`crm_program_weekly_messages`.`day_3_content` AS `day_3_content`,
		`crm_program_weekly_messages`.`day_3_memes` AS `day_3_memes`,
		`crm_program_weekly_messages`.`day_4` AS `day_4`,
		`crm_program_weekly_messages`.`day_4_content` AS `day_4_content`,
		`crm_program_weekly_messages`.`day_4_memes` AS `day_4_memes`,
		`crm_program_weekly_messages`.`is_active` AS `is_active`,
		NULL AS `deleted_at`,
		`crm_program_weekly_messages`.`updated_at` AS `updated_at`,
		`crm_program_weekly_messages`.`created_at` AS `created_at` 
	FROM `crm_program_weekly_messages`
)
UNION
(
	SELECT 
		`uwm`.`user_id` AS `user_id`,
		`uwm`.`crm_programs_id` AS `crm_programs_id`,
		`uwm`.`week_number` AS `week_number`,
		`uwm`.`day_1` AS `day_1`,
		`uwm`.`day_1_content` AS `day_1_content`,
		`uwm`.`day_1_memes` AS `day_1_memes`,
		`uwm`.`day_2` AS `day_2`,
		`uwm`.`day_2_content` AS `day_2_content`,
		`uwm`.`day_2_memes` AS `day_2_memes`,
		`uwm`.`day_3` AS `day_3`,
		`uwm`.`day_3_content` AS `day_3_content`,
		`uwm`.`day_3_memes` AS `day_3_memes`,
		`uwm`.`day_4` AS `day_4`,
		`uwm`.`day_4_content` AS `day_4_content`,
		`uwm`.`day_4_memes` AS `day_4_memes`,
		`uwm`.`is_active` AS `is_active`,
		`uwm`.`deleted_at` AS `deleted_at`,
		`uwm`.`updated_at` AS `updated_at`,
		`uwm`.`created_at` AS `created_at` 
	FROM (`crm_user_program_weekly_messages` `uwm` LEFT JOIN `users` `u` ON((`uwm`.`user_id` = `u`.`id`))) 
	WHERE ((`u`.`role` = 'UE') AND (`u`.`is_active` = 1))
);