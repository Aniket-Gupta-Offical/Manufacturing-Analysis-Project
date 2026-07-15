CREATE DATABASE ManufacturingDB;
use ManufacturingDB;
select * from prod_data;
desc prod_data;

--  
ALTER TABLE `manufacturingdb`.`prod_data` 
CHANGE COLUMN `ï»¿Buyer` `Buyer` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Cust Code` `Cust_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Cust Name` `Cust_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Department Name` `Department_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Doc Num` `Doc_Num` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `EMP Code` `EMP_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Emp Name` `Emp_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `EMPCode (MEMP)` `EMPCode_(MEMP)` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `End Time` `End_Time` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Fiscal DateTime` `Fiscal_DateTime` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `In Active` `In_Active` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Is Final Process` `Is_Final_Process` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Item Code` `Item_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Item Name` `Item_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Machine Code` `Machine_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Machine Code (EMP)` `Machine_Code_EMP` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Machine Name` `Machine_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Machine Name (EMP)` `Machine_Name_EMP` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Operation Code` `Operation_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Operation Name` `Operation_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `SAP So Num` `SAP_So_Num` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Shift Code` `Shift_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `SO Del Date` `SO_Del_Date` INT NULL DEFAULT NULL ,
CHANGE COLUMN `SO Delivery Date` `SO_Delivery_Date` INT NULL DEFAULT NULL ,
CHANGE COLUMN `SO Docdate` `SO_Docdate` INT NULL DEFAULT NULL ,
CHANGE COLUMN `SO DocDate F` `SO_DocDate_F` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `SO Expected Delivery F` `SO_Expected_Delivery_F` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `SO Num` `SO_Num` INT NULL DEFAULT NULL ,
CHANGE COLUMN `So Posting Date` `So_Posting_Date` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Start Time` `Start_Time` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `User Id` `User_Id` INT NULL DEFAULT NULL ,
CHANGE COLUMN `User Id1` `User_Id1` INT NULL DEFAULT NULL ,
CHANGE COLUMN `User Name` `User_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Variant Name` `Variant_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `WO Date` `WO_Date` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `WO Status` `W_ Status` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Work Centre Code` `Work_Centre_Code` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Work Centre Name` `Work_Centre_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Balance Qty` `Balance_Qty` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Press Qty` `Press_Qty` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Produced Qty` `Produced_Qty` INT NULL DEFAULT NULL ,
CHANGE COLUMN `today Manufactured qty` `today_Manufactured_qty` INT NULL DEFAULT NULL ;









/* loaded csv file - cc column names not normalized */

-- 1. Date Rejected Qty
-- Total rejected quantity for today's date
CREATE OR REPLACE VIEW manufacturing_date_rejected_qty AS
SELECT 
    SUM(`rejected_qty`) AS date_rejected_qty
FROM prod_data
WHERE `doc_date` = CURDATE();

-- 2. Estimated Days
-- Estimate production days based on WO Qty and average production time
CREATE OR REPLACE VIEW manufacturing_estimated_days AS
SELECT 
    `WO Number`,
    (SUM(`WO Qty`) / AVG(`TotalQty`)) * 
    AVG(TIMESTAMPDIFF(DAY, `Start Time`, `End Time`)) AS estimated_days
FROM prod_data
GROUP BY `WO Number`;

-- 3. Final Processed Qty
-- Only count processed quantity if final process is marked true
CREATE OR REPLACE VIEW manufacturing_final_processed_qty AS
SELECT 
    `WO Number`,
    SUM(CASE WHEN `Is Final Process` = 1 THEN `Processed Qty` ELSE 0 END) AS final_processed_qty
FROM prod_data
GROUP BY `WO Number`;

-- 4. Rejected Qty F
-- Total rejected quantity grouped by WO number and form type
CREATE OR REPLACE VIEW manufacturing_rejected_qty_f AS
SELECT 
    `WO Number`,
    `Form Type`,
    SUM(`Rejected Qty`) AS rejected_qty_f
FROM prod_data
GROUP BY `WO Number`, `Form Type`;

-- 5. Total Wastage %
-- Ratio of rejected to manufactured (excluding rejected portion)
CREATE OR REPLACE VIEW manufacturing_total_wastage_percent AS
SELECT 
    `WO Number`,
    ROUND(SUM(`rejected_qty`) / NULLIF(SUM(`manufactured_qty`) - SUM(`rejected_qty`),0), 4) AS total_wastage_percent
FROM prod_data
GROUP BY `WO Number`;

-- 6. Delivery Percentage
-- Count distinct WO numbers per delivery period
CREATE OR REPLACE VIEW manufacturing_delivery_percentage AS
SELECT 
    `Delivery Period`,
    COUNT(DISTINCT `WO Number`) AS delivery_percentage
FROM prod_data
GROUP BY `Delivery Period`;

-- 7. Total Manufactured Qty
-- Provide YTD, MTD, and Today totals for manufactured quantity
CREATE OR REPLACE VIEW manufacturing_total_manufactured_qty AS
SELECT 
    `Fiscal Year`,
    SUM(`Manufactured Qty`) AS ytd_man_qty,
    SUM(CASE WHEN MONTH(`Fiscal Date`) = MONTH(CURDATE()) THEN `Manufactured Qty` ELSE 0 END) AS mtd_man_qty,
    SUM(CASE WHEN `Doc Date` = CURDATE() THEN `Manufactured Qty` ELSE 0 END) AS date_man_qty
FROM prod_data
GROUP BY `Fiscal Year`;

-- 8. Total Manufacturing Cost
-- Sum of per-day machine costs per WO
CREATE OR REPLACE VIEW manufacturing_total_cost AS
SELECT 
    `WO Number`,
    SUM(`Per day Machine Cost ma`) AS total_manufacturing_cost
FROM prod_data
GROUP BY `WO Number`;

-- 9. Wastage %
-- Ratio of rejected to processed quantity
CREATE OR REPLACE VIEW manufacturing_wastage_percent AS
SELECT 
    `WO Number`,
    ROUND(SUM(`Rejected Qty`) / NULLIF(SUM(`Processed Qty`),0), 4) AS wastage_percent
FROM prod_data
GROUP BY `WO Number`;

-- 10. Processed Qty
-- Manufactured minus rejected
CREATE OR REPLACE VIEW manufacturing_processed_qty AS
SELECT 
    `WO Number`,
    SUM(`Manufactured Qty` - `Rejected Qty`) AS processed_qty
FROM prod_data
GROUP BY `WO Number`;














