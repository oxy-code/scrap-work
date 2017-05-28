DROP PROCEDURE IF EXISTS `proc_user_checklists`;
DELIMITER $$
CREATE PROCEDURE `proc_user_checklists`(IN `UserId` INT, IN `ProgramId` INT)
BEGIN
	DECLARE x INT;

	SET x = 1;
	SET @crm_checklists_query = CONCAT("SELECT NULL AS id, NULL AS user_id, 0 AS week_number,crm_programs_id AS program_id,title,goals, is_published AS is_active, 0 AS is_completed FROM `crm_checklists` WHERE FIND_IN_SET(0, REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=0))");

	WHILE x <= 52 DO
		SET @crm_checklists_query = CONCAT(@crm_checklists_query, " UNION ALL SELECT NULL AS id, NULL AS user_id,",x," AS week_number,crm_programs_id AS program_id,title,goals, is_published AS is_active, 0 AS is_completed FROM `crm_checklists` WHERE FIND_IN_SET(",x,", REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=",x,"))");
 		SET x = x + 1;
 	END WHILE;

 	SET @crm_checklists_query = CONCAT(@crm_checklists_query," UNION SELECT id, user_id, week_number, program_id, title, goals, is_active, is_completed FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id = ",UserId," AND is_active=1", " ORDER BY week_number");
 	
 	PREPARE stmt FROM @crm_checklists_query;
 	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

/* To get the list of general emails by user weeks */
DROP PROCEDURE IF EXISTS `proc_get_user_specific_general_emails`;
DELIMITER $$
CREATE PROCEDURE `proc_get_user_specific_general_emails`() READS SQL DATA
BEGIN
	SELECT `MembersView`.`id`,`MembersView`.`email`, `MembersView`.`current_week`,`UserEmailView`.`subject`,`UserEmailView`.`content`,IF( `UserEmailView`.`user_id` IS NULL , 0, 1 ) AS `is_user_specific` FROM `MembersView` INNER JOIN `UserEmailView` ON `MembersView`.`current_week`=`UserEmailView`.`week_number` WHERE `MembersView`.`is_active` = 1 AND `MembersView`.`current_week` >0 AND (`UserEmailView`.`user_id` = `MembersView`.`id` OR (`UserEmailView`.`user_id` IS NULL AND `MembersView`.`id` NOT IN (SELECT `UserEmailView`.`user_id` FROM `UserEmailView` WHERE `UserEmailView`.`user_id` IS NOT NULL AND `UserEmailView`.`week_number` = `MembersView`.`current_week`))) AND `UserEmailView`.`is_active` = 1 ORDER BY `MembersView`.`current_week` ASC;
END$$
DELIMITER ;

/* To get the list of general sms by user weeks */
DROP PROCEDURE IF EXISTS `proc_get_user_specific_general_sms`;
DELIMITER $$
CREATE PROCEDURE `proc_get_user_specific_general_sms`() READS SQL DATA
BEGIN
	select `MembersView`.`id`, `MembersView`.`contact_number`, `MembersView`.`current_week`, `UserMessageView`.`day_1`, `UserMessageView`.`day_1_content`, `UserMessageView`.`day_2`, `UserMessageView`.`day_2_content`, `UserMessageView`.`day_3`, `UserMessageView`.`day_3_content` FROM `MembersView` INNER JOIN `UserMessageView` ON `UserMessageView`.`week_number` = `MembersView`.`current_week` AND (`UserMessageView`.`day_1` = DAYNAME(CURRENT_DATE()) OR `UserMessageView`.`day_2` = DAYNAME(CURRENT_DATE()) OR `UserMessageView`.`day_3` = DAYNAME(CURRENT_DATE())) AND (`UserMessageView`.`user_id` = `MembersView`.`id` OR `UserMessageView`.`user_id` IS NULL) WHERE `MembersView`.`is_active` = 1 AND `MembersView`.`contact_number` IS NOT NULL ORDER BY `MembersView`.`current_week` ASC;
END$$
DELIMITER ;

/* To get the list of program sms by user weeks */
DROP PROCEDURE IF EXISTS `proc_get_user_specific_program_sms`;
DELIMITER $$
CREATE PROCEDURE `proc_get_user_specific_program_sms`() READS SQL DATA
BEGIN
	select `MembersView`.`id`, `MembersView`.`contact_number`, `MembersView`.`program_id`, `MembersView`.`program_week`, `programusermessageview`.`day_1`, `programusermessageview`.`day_1_content`, `programusermessageview`.`day_2_memes`, `programusermessageview`.`day_2`, `programusermessageview`.`day_2_content`, `programusermessageview`.`day_1_memes`, `programusermessageview`.`day_3`, `programusermessageview`.`day_3_content`, `programusermessageview`.`day_3_memes`, `programusermessageview`.`day_4`, `programusermessageview`.`day_4_content`, `programusermessageview`.`day_4_memes` from `MembersView` inner join `programusermessageview` on `programusermessageview`.`week_number` = `MembersView`.`program_week` and `programusermessageview`.`crm_programs_id` = `MembersView`.`program_id` and (`programusermessageview`.`user_id` = `MembersView`.`id` or `programusermessageview`.`user_id` is null) and (`programusermessageview`.`day_1` = DAYNAME(CURRENT_DATE()) or `programusermessageview`.`day_2` = DAYNAME(CURRENT_DATE()) or `programusermessageview`.`day_3` = DAYNAME(CURRENT_DATE()) or `programusermessageview`.`day_4` = DAYNAME(CURRENT_DATE())) where `MembersView`.`contact_number` is not null and `MembersView`.`program_id` is not null and `MembersView`.`program_week` is not null and `MembersView`.`program_week` != 0 ORDER BY `MembersView`.`current_week` ASC;
END$$
DELIMITER ;

/*DROP PROCEDURE IF EXISTS `proc_user_checklists_with_specific_intervals`;
DELIMITER $$
CREATE PROCEDURE `proc_user_checklists_with_specific_intervals`(IN `UserId` INT, IN `ProgramId` INT, IN `ChecklistInterval` VARCHAR(20), IN `ChecklistMode` VARCHAR(20))
BEGIN
	DECLARE x INT;

	SET x = 1;
	SET @crm_checklists_query = CONCAT("SELECT NULL AS id, NULL AS user_id, 0 AS week_number,crm_programs_id AS program_id,title, is_published AS is_active, 0 AS is_completed, checklist_interval FROM `crm_checklists` WHERE FIND_IN_SET(0, REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND checklist_interval = '", ChecklistInterval ,"' AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=0))");

	IF ChecklistMode IS NOT NULL THEN
		SET @crm_checklists_query = CONCAT("SELECT NULL AS id, NULL AS user_id, 1 AS week_number,crm_programs_id AS program_id,title, is_published AS is_active, 0 AS is_completed,checklist_interval FROM `crm_checklists` WHERE FIND_IN_SET(1, REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND checklist_interval = '", ChecklistInterval ,"' AND checklist_mode = '", ChecklistMode ,"' AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=1))");
	END IF;

	WHILE x <= 52 DO
		IF ChecklistMode IS NOT NULL THEN
			SET @crm_checklists_query = CONCAT(@crm_checklists_query, " UNION ALL SELECT NULL AS id, NULL AS user_id,",x," AS week_number,crm_programs_id AS program_id,title, is_published AS is_active, 0 AS is_completed, checklist_interval FROM `crm_checklists` WHERE FIND_IN_SET(",x,", REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND checklist_interval = '", ChecklistInterval ,"' AND checklist_mode = '",ChecklistMode,"' AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=",x,"))");
		ELSE
			SET @crm_checklists_query = CONCAT(@crm_checklists_query, " UNION ALL SELECT NULL AS id, NULL AS user_id,",x," AS week_number,crm_programs_id AS program_id,title, is_published AS is_active, 0 AS is_completed,checklist_interval FROM `crm_checklists` WHERE FIND_IN_SET(",x,", REPLACE(REPLACE(weeks, '[', '[,'), ']', ',]')) > 0 AND is_published = 1 AND crm_programs_id =",ProgramId," AND checklist_interval = '", ChecklistInterval ,"' AND (title NOT IN (SELECT title FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id=",UserId," AND (is_active=0 OR is_completed=1) AND week_number=",x,"))");
		END IF;
 		SET x = x + 1;
 	END WHILE;

 	SET @crm_checklists_query = CONCAT(@crm_checklists_query," UNION SELECT id, user_id, week_number, program_id, title, is_active, is_completed, '",ChecklistInterval,"' AS checklist_interval FROM `crm_user_checklist` WHERE program_id = ",ProgramId," AND user_id = ",UserId," AND is_active=1", " ORDER BY week_number");
 	
 	PREPARE stmt FROM @crm_checklists_query;
 	EXECUTE stmt;
 	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;*/

DROP PROCEDURE IF EXISTS `proc_get_users_active_week_program_email`;
DELIMITER $$
CREATE PROCEDURE `proc_get_users_active_week_program_email`() READS SQL DATA
BEGIN
	SELECT 
	`MV`.`id`,
	`MV`.`email`,
	`MV`.`program_week`,
	`MV`.`program_id`,
	`USPE`.`subject`,
	`USPE`.`content`
	FROM `UserSpecificProgramEmails` `USPE` LEFT JOIN `MembersView` `MV` ON `USPE`.`crm_programs_id` = `MV`.`program_id` 
		WHERE `USPE`.`week_number` = `MV`.`program_week` 
		AND `MV`.`program_week` IS NOT NULL 
		AND `MV`.`program_week` != 0 
		AND `MV`.`message_push_type` LIKE 'Automatic'
		AND (
			`USPE`.`user_id` = `MV`.`id` OR (
				`USPE`.`user_id` IS NULL AND `USPE`.`user_id` NOT IN (
					SELECT `user_id` FROM `UserSpecificProgramEmails` WHERE `week_number` = `MV`.`program_week` AND `crm_programs_id` = `MV`.`program_id` AND `user_id` = `MV`.`id`
				)
			)
		)
		ORDER BY `MV`.`program_week` ASC;
END$$
DELIMITER ;

/* proc_get_users_active_week_program_sms */
DROP PROCEDURE IF EXISTS `proc_get_users_active_week_program_sms`;
DELIMITER $$
CREATE PROCEDURE `proc_get_users_active_week_program_sms`() READS SQL DATA
BEGIN
	SELECT 
	`MV`.`id`,
	`MV`.`contact_number`,
	`MV`.`program_week`,
	`MV`.`program_id`,
	`MV`.`lead_coach_id`,
	`MV`.`lead_coach`,
	IF(
		`USPS`.`day_1` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_1`, 
		IF(
			`USPS`.`day_2` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_2`, 
			IF(
				`USPS`.`day_3` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_3`, 
				IF(
					`USPS`.`day_4` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_4`, NULL
				)
			)
		) 
	) AS `day`,
	IF(
		`USPS`.`day_1` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_1_content`, 
		IF(
			`USPS`.`day_2` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_2_content`, 
			IF(
				`USPS`.`day_3` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_3_content`, 
				IF(
					`USPS`.`day_4` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_4_content`, NULL
				)
			)
		) 
	) AS `content`,
	IF(
		`USPS`.`day_1` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_1_memes`, 
		IF(
			`USPS`.`day_2` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_2_memes`, 
			IF(
				`USPS`.`day_3` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_3_memes`, 
				IF(
					`USPS`.`day_4` LIKE DAYNAME(CURRENT_DATE()), `USPS`.`day_4_memes`, NULL
				)
			)
		) 
	) AS `memes`
	FROM `UserSpecificProgramSMS` `USPS` LEFT JOIN `MembersView` `MV` ON `USPS`.`crm_programs_id` = `MV`.`program_id` 
		WHERE `USPS`.`week_number` = `MV`.`program_week` 
		AND `MV`.`program_week` IS NOT NULL 
		AND `MV`.`program_week` != 0 
		AND `MV`.`message_push_type` LIKE 'Automatic'
		AND (
			`USPS`.`user_id` = `MV`.`id` OR (
				`USPS`.`user_id` IS NULL AND `USPS`.`user_id` NOT IN (
					SELECT `user_id` FROM `UserSpecificProgramSMS` WHERE `week_number` = `MV`.`program_week` AND `crm_programs_id` = `MV`.`program_id` AND `user_id` = `MV`.`id`
				)
			)
		)
		/*AND `MV`.`contact_number` NOT IN ('0000000000','1111111111','2222222222','3333333333','4444444444','5555555555','6666666666','7777777777','8888888888','9999999999')*/
		AND (
			`USPS`.`day_1` LIKE DAYNAME(CURRENT_DATE()) OR `USPS`.`day_2` LIKE DAYNAME(CURRENT_DATE()) OR `USPS`.`day_3` LIKE DAYNAME(CURRENT_DATE()) OR `USPS`.`day_4` LIKE DAYNAME(CURRENT_DATE())
		)
		ORDER BY `MV`.`program_week` ASC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `proc_create_or_update_healthadmin_records`;
DELIMITER $$
CREATE PROCEDURE `proc_create_or_update_healthadmin_records`(IN UserIds TEXT, IN Field VARCHAR(255), IN FieldValue VARCHAR(255), IN AdminId INT)
BEGIN
	DECLARE strLen INT DEFAULT 0;
	DECLARE subStrLen INT DEFAULT 0;
	

	IF (UserIds IS NOT NULL AND Field IS NOT NULL AND Field NOT LIKE '' AND FieldValue IS NOT NULL) THEN
		SET @query = CONCAT("INSERT INTO health_admins (admin_id,user_id,", Field, ", created_at, updated_at) VALUES ");

		WHILE (UserIds NOT LIKE '') DO
			SET strLen = CHAR_LENGTH(UserIds);
			SET @query = CONCAT(@query, " (", AdminId, ",", SUBSTRING_INDEX(UserIds, ',', 1), ",'", FieldValue, "', NOW(), NOW()),");
			SET subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(UserIds, ',', 1)) + 2;
    		SET UserIds = MID(UserIds, subStrLen, strLen);
		END WHILE;

		IF (@query NOT LIKE CONCAT("INSERT INTO health_admins (admin_id,user_id,", Field, ")")) THEN
			SET @query = CONCAT(SUBSTRING(@query, 1, CHAR_LENGTH(@query)-1), " ON DUPLICATE KEY UPDATE admin_id = VALUES(admin_id), user_id = VALUES(user_id), ",Field," = VALUES(",Field,"), created_at = VALUES(created_at), updated_at = VALUES(updated_at);");

			/*SELECT @query;*/
			PREPARE stmt FROM @query;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
	END IF;
END$$
DELIMITER ;

/* To find the last active device/api_key of an user requested from Mobile App */
DROP PROCEDURE IF EXISTS `proc_fetch_user_active_api_key`;
DELIMITER $$
CREATE PROCEDURE `proc_fetch_user_active_api_key`(IN UserId INT)
BEGIN
	SET @uid = UserId;
	SET @query = "SELECT * FROM api_keys WHERE user_id = ? ORDER BY last_request_at DESC LIMIT 0,1";

	IF (SELECT last_request_at IS NULL FROM api_keys WHERE user_id = @uid ORDER BY last_request_at DESC LIMIT 0,1) THEN
		SET @query = "SELECT * FROM api_keys WHERE user_id = ? ORDER BY created_at DESC LIMIT 0,1";
	END IF;

	PREPARE stmt FROM @query;
	EXECUTE stmt USING @uid;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

/* App Chat Entries (Single/Bulk) */
DROP PROCEDURE IF EXISTS `proc_insert_appchats`;
DELIMITER $$
CREATE PROCEDURE `proc_insert_appchats`(IN UserIds TEXT, IN Message VARCHAR(255), IN CreateDate VARCHAR(35), IN AdminId INT)
BEGIN
	DECLARE strLen INT DEFAULT 0;
	DECLARE subStrLen INT DEFAULT 0;
	DECLARE UID VARCHAR(20);
	

	IF (UserIds IS NOT NULL AND Message IS NOT NULL AND Message NOT LIKE '' AND CreateDate IS NOT NULL) THEN
		SET @query = CONCAT("INSERT INTO app_chat_messages (thread_id, from_user_id, to_user_id, body, is_coach_read, created_at, updated_at) VALUES ");

		WHILE (UserIds NOT LIKE '') DO
			SET strLen = CHAR_LENGTH(UserIds);
			SET UID = SUBSTRING_INDEX(UserIds, ',', 1);
			SET @query = CONCAT(@query, " (", UID, ",", AdminId, ",", UID, ", '",Message, "', ",1, ", '",CreateDate,"', '",CreateDate,"'),");
			SET subStrLen = CHAR_LENGTH(UID) + 2;
    		SET UserIds = MID(UserIds, subStrLen, strLen);
		END WHILE;
		SET @query = CONCAT(SUBSTRING(@query, 1, CHAR_LENGTH(@query)-1), ";");

		/*SELECT @query;*/
		PREPARE stmt FROM @query;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
END$$
DELIMITER ;