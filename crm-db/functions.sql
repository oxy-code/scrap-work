/* To find member engagment level with their coach touch based intervals like 30day, 60day or more than 60 */
DROP FUNCTION IF EXISTS `func_member_engagement_level`;
DELIMITER $$
CREATE FUNCTION `func_member_engagement_level`(`AssessmentDate` DATE, `LastCallDate` DATE, `UpdatedAt` DATE)
	RETURNS VARCHAR(10)
	DETERMINISTIC READS SQL DATA
BEGIN
	IF (
		(AssessmentDate BETWEEN (CURDATE()-INTERVAL 7 DAY) AND CURDATE()) OR 
		(LastCallDate BETWEEN (CURDATE()-INTERVAL 7 DAY) AND CURDATE()) OR 
		(UpdatedAt BETWEEN (CURDATE()-INTERVAL 7 DAY) AND CURDATE())
	) THEN
		return "highest";
	ELSEIF (
		(AssessmentDate BETWEEN (CURDATE()-INTERVAL 14 DAY) AND CURDATE()) OR 
		(LastCallDate BETWEEN (CURDATE()-INTERVAL 14 DAY) AND CURDATE()) OR 
		(UpdatedAt BETWEEN (CURDATE()-INTERVAL 14 DAY) AND CURDATE())
	) THEN
		return "higher";
	ELSEIF (
		(AssessmentDate BETWEEN (CURDATE()-INTERVAL 30 DAY) AND CURDATE()) OR 
		(LastCallDate BETWEEN (CURDATE()-INTERVAL 30 DAY) AND CURDATE()) OR 
		(UpdatedAt BETWEEN (CURDATE()-INTERVAL 30 DAY) AND CURDATE())
	) THEN
		return "high";
	ELSEIF (
		(AssessmentDate BETWEEN (CURDATE()-INTERVAL 60 DAY) AND (CURDATE()-INTERVAL 30 DAY)) OR 
		(LastCallDate BETWEEN (CURDATE()-INTERVAL 60 DAY) AND (CURDATE()-INTERVAL 30 DAY)) OR 
		(UpdatedAt BETWEEN (CURDATE()-INTERVAL 60 DAY) AND (CURDATE()-INTERVAL 30 DAY))
	) THEN
		return "mid";
	ELSE
		return "low";
	END IF;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS `func_get_last_touch_date`;
DELIMITER $$
CREATE FUNCTION `func_get_last_touch_date`(`AssessmentDate` TIMESTAMP, `LastCallDate` TIMESTAMP, `LastSmsDate` TIMESTAMP, `LastEmailDate` TIMESTAMP)
	RETURNS VARCHAR(25)
	DETERMINISTIC READS SQL DATA
BEGIN
	SET LastSmsDate = IFNULL(LastSmsDate, '0000-00-00 00:00:00');
	SET LastEmailDate = IFNULL(LastEmailDate, '0000-00-00 00:00:00');
	SET AssessmentDate = IFNULL(AssessmentDate, '0000-00-00 00:00:00');
	SET LastCallDate = IFNULL(LastCallDate, '0000-00-00');
	IF (LastEmailDate > LastSmsDate) THEN
		IF (LastEmailDate > AssessmentDate) THEN
			IF (DATE(LastEmailDate) > LastCallDate) THEN
				return DATE_FORMAT(LastEmailDate, '%m/%d/%Y');
			ELSE
				return DATE_FORMAT(LastCallDate, '%m/%d/%Y');
			END IF;
		ELSEIF (DATE(AssessmentDate) > LastCallDate) THEN
			return DATE_FORMAT(AssessmentDate, '%m/%d/%Y');
		ELSE
			return DATE_FORMAT(LastCallDate, '%m/%d/%Y');
		END IF;
	ELSE
		IF (LastSmsDate > AssessmentDate) THEN
			IF (DATE(LastSmsDate) > LastCallDate) THEN
				return DATE_FORMAT(LastSmsDate, '%m/%d/%Y');
			ELSE
				return DATE_FORMAT(LastCallDate, '%m/%d/%Y');
			END IF;
		ELSEIF (DATE(AssessmentDate) > LastCallDate) THEN
			return DATE_FORMAT(AssessmentDate, '%m/%d/%Y');
		ELSE
			return DATE_FORMAT(LastCallDate, '%m/%d/%Y');
		END IF;
	END IF;
END$$
DELIMITER ;