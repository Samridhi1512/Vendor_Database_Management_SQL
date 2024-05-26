/*Tables*/
Select * from rawmaterial;
describe rawmaterial;
select * from inventory;
select * from vendor;
select * from shipping;
select * from product;
select * from rawmaterial_product;
select * from orders;

/*Update the column name of Material_Code in RawMaterial table*/
ALTER TABLE rawmaterial
CHANGE COLUMN `ï»¿Material_Code` Material_Code VARCHAR(255);

Alter table rawmaterial
ADD primary key (material_code); 

ALTER TABLE vendor
CHANGE COLUMN `ï»¿Vendor_ID` Vendor_ID VARCHAR(255); 

Alter table vendor
ADD primary key (vendor_id); 

ALTER TABLE product
CHANGE COLUMN Vendor_ID Product_ID VARCHAR(255); 

Alter table product
ADD primary key (Product_ID); 

ALTER TABLE rawmaterial_product
CHANGE COLUMN `ï»¿Product_ID` Product_ID VARCHAR(255); 

Alter table orders
CHANGE COLUMN `ï»¿Invoice_No` Invoice_No VARCHAR(255);

ALTER TABLE orders
ADD PRIMARY KEY (Invoice_No);


/* 1. Query to measure stock_out products*/
SELECT i.Material_Code, rm.Material_Name, SUM(i.Quantity_In_Hand) AS Total_Quantity, rm.stock_out_level, round(rm.stock_out_level - SUM(i.Quantity_In_Hand), 2) as Min_Reorder_required, rm.qty_unit
FROM Inventory AS i
INNER JOIN RawMaterial AS rm ON i.Material_Code = rm.Material_Code
GROUP BY i.Material_Code, rm.Material_Name, rm.Stock_Out_Level, rm.qty_unit
HAVING SUM(i.Quantity_In_Hand) < rm.Stock_Out_Level;

/* 2.Select the vendors supplying perishable raw materials..*/
SELECT v.vendor_id, v.vendor_name, Material_Name
FROM vendor AS v
INNER JOIN rawmaterial_vendor AS rmv ON rmv.supplier_id = v.vendor_id
INNER JOIN rawmaterial AS rm ON rm.material_code = rmv.material_code
WHERE rm.Material_type = 'perishable';

/* 3.Find the names of vendors and shippers operating in the same region supplying perishable raw materials.*/
SELECT v.vendor_name, s.shipping_company, Material_Name
FROM vendor AS v
INNER JOIN rawmaterial_vendor AS rmv ON v.vendor_id = rmv.Supplier_ID
INNER JOIN rawmaterial AS rm ON rm.material_code = rmv.material_code
INNER JOIN shipping AS s ON s.Company_city = v.Vendor_City
WHERE rm.Material_type = 'perishable';

/*4.Find the name of the vendor supplying maximum number of raw materials.*/
SELECT v.vendor_name, COUNT(rm.material_name) AS counts
FROM vendor AS v
INNER JOIN rawmaterial_vendor AS rmv ON v.vendor_id = rmv.Supplier_ID
INNER JOIN rawmaterial AS rm ON rm.material_code = rmv.material_code
GROUP BY v.vendor_name
ORDER BY counts DESC
LIMIT 1;

/*5. Find the products that require 3 or more raw materials.*/
SELECT p.product_name, COUNT(rm.material_name) AS counts
FROM product AS p
INNER JOIN rawmaterial_product AS rmp ON p.product_id = rmp.product_id
INNER JOIN rawmaterial AS rm ON rmp.material_code = rm.material_code
GROUP BY p.product_name
HAVING COUNT(DISTINCT rm.material_code) > 3;

/*6. Raw Materials listed on the basis of use by date */
SELECT rm.material_name, o.vendor_id, datediff(o.expiration_date, current_date())/365 as use_by from rawmaterial as rm
INNER JOIN orders AS o ON rm.material_code = o.material_code
where o.Manufacturing_Date >  '2023-02-01';

/* 7. Find the names of all Madhya Pradesh vendors who have the word “enterprises” or “traders” in their name.*/
select v.vendor_name from vendor as v
where (v.vendor_name like "%enterprises%" or v.vendor_name like "%traders%") and  v.Vendor_State like "M%"

/* 8. Find the states in which shippers having “fast” in their names are located. */;
Select s.company_state, s.shipping_company from shipping as s
where s.shipping_company like "%fast%"

/* 9.Query to list all manufactured products along with their raw materials.*/;
SELECT p.product_name AS manufactured_product, rm.material_name AS raw_material
FROM product AS p
INNER JOIN rawmaterial_product AS rmp ON p.product_id = rmp.product_id
INNER JOIN rawmaterial AS rm ON rmp.material_code = rm.material_code
GROUP BY p.product_name, rm.material_name
ORDER BY p.product_name;

/* 10.Arrange all the orders in descending order based on the Order Value.*/
select rm.material_name, rm.material_code, o.quantity_ordered * (o.Price_per_Unit) as order_value from rawmaterial as rm
inner join orders as o on o.Material_Code = rm.material_code
order by order_value desc;

/* 11.Which storage location is storing the maximum “quantity-value” of raw materials*/
SELECT i.storage_location, i.Inventory_number, rm.material_name, i.quantity_in_hand AS quantity_value
FROM inventory AS i
INNER JOIN rawmaterial AS rm ON rm.Material_Code = i.Material_Code
WHERE (i.storage_location, i.Inventory_number, i.quantity_in_hand) IN
    (SELECT storage_location, Inventory_number, MAX(quantity_in_hand) AS max_quantity FROM inventory
        GROUP BY storage_location, Inventory_number)
ORDER BY quantity_value DESC ;

/* 12.Check the data if there is any particular month in which most vendors have signed up.*/
SELECT month(vendor_startdate) AS start_month, COUNT(vendor_id) AS vendor_count
FROM vendor 
where month(Vendor_StartDate) is not null 
GROUP BY month(vendor_startdate)
ORDER BY count(vendor_id) DESC;


/* 13. Current storage quantity of each unit in both the storage locations */
Select round(sum(i.Quantity_in_hand),2) as current_storage , i.Storage_location , rm.qty_unit from Inventory as i
inner join rawmaterial as rm
on rm.material_code = i.material_code
group by i.storage_location , rm.qty_unit;

/* 14. Most cost efficient vendor for Raw Material - Sugar (ITM00550)*/
SELECT DISTINCT v.vendor_id, v.vendor_name, o.Price_per_Unit, o.Ship_price_per_unit, (o.price_per_unit + o.ship_price_per_unit) AS total_cost
FROM orders AS o
INNER JOIN vendor AS v ON v.vendor_id = o.vendor_id
WHERE o.material_code = 'ITM00550'
GROUP BY v.vendor_id, v.vendor_name, o.Price_per_Unit, o.Ship_price_per_unit;
# From the below table we can conclude that most cost efficient vendor is Meethas Agency Pvt.Ltd 

/* 15. List of vendors not supplying any raw materials as of now*/
SELECT vendor_id, vendor_name FROM vendor AS a
WHERE a.vendor_id NOT IN ( SELECT DISTINCT o.vendor_id FROM orders AS o
Inner JOIN vendor AS v ON v.vendor_id = o.vendor_id);









 

