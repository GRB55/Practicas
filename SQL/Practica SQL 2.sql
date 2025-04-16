-- 10 productos más vendidos

SELECT *
FROM [Order Details];

SELECT *
FROM Products;

SELECT TOP 10 p.ProductName, SUM(od.Quantity) AS Total_quantity_sold
FROM [Order Details] od
JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY Total_quantity_sold DESC;

-- Categorías con mayor cantidad de ventas (en términos de ingresos)

SELECT *
FROM Categories;

SELECT *
FROM Products;

SELECT c.CategoryName,  SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS Total_sold
FROM [Order Details] od
JOIN Products p
ON od.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY Total_sold DESC;

-- Clientes más valiosos

SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT TOP 5 c.CompanyName,  SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS Total_sold
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY Total_sold DESC;

-- Promedio de pedidos realizados por cliente

SELECT c.CompanyName, AVG(od.Quantity) AS Promedio_pedidos
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY c.CompanyName;

-- Cantidad de pedidos realizados por cliente

SELECT c.CompanyName, AVG(PedidosClientes.Total_pedidos) AS Cantidad_pedidos
FROM Customers c
JOIN (
	SELECT o.CustomerID, COUNT(o.OrderID) AS Total_pedidos
	FROM Orders o
	GROUP BY o.CustomerID
) PedidosClientes
ON c.CustomerID = PedidosClientes.CustomerID
GROUP BY c.CompanyName;

-- Países con mayor cantidad de clientes

SELECT Country, COUNT(*) AS Total_clientes
FROM Customers
GROUP BY Country
ORDER BY Total_clientes DESC;

-- Meses con mayores ingresos

SELECT DATENAME(MONTH, o.OrderDATE) AS Mes, SUM(od.Quantity * od.UnitPrice * (1-od.Discount)) AS Total_sold
FROM Orders o
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY DATENAME(MONTH, o.OrderDATE)
ORDER BY Total_sold DESC;

-- Tiempo de entrega promedio por región

SELECT ShipRegion, AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS Tiempo_promedio
FROM Orders
WHERE ShipRegion IS NOT NULL
GROUP BY ShipRegion
ORDER BY Tiempo_promedio;

-- Productos en los meses del año

SELECT DATENAME(MONTH, o.OrderDate) AS Mes, p.ProductName AS Producto, SUM(Quantity) AS Cantidad
FROM Products p
JOIN [Order Details] od
ON p.ProductID = od.ProductID
JOIN Orders o
ON od.OrderID = o.OrderID
GROUP BY DATENAME(MONTH, o.OrderDate), p.ProductName
ORDER BY Producto, Cantidad;

-- Rendimiento de empleados

SELECT e.EmployeeID AS Empleado, COUNT(o.OrderID) AS Cantidad_de_pedidos
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
ORDER BY Cantidad_de_pedidos DESC;

SELECT e.EmployeeID AS Empleado, SUM(od.Quantity * od.UnitPrice * (1-od.Discount)) AS Total_sold
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID
ORDER BY Total_sold DESC;

SELECT e.EmployeeID, t.TerritoryDescription, r.RegionDescription
FROM Employees e
JOIN EmployeeTerritories et
ON e.EmployeeID = et.EmployeeID
JOIN Territories t
ON et.TerritoryID = t.TerritoryID
JOIN Region r
ON t.RegionID = r.RegionID;

-- Proveedores con mayor cantidad de productos vendidos

SELECT  s.SupplierID, s.CompanyName AS Proveedor, SUM(od.Quantity) AS Cantidad_vendida
FROM Suppliers s
JOIN Products p
ON s.SupplierID = p.SupplierID
JOIN [Order Details] od
ON od.ProductID = p.ProductID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY Cantidad_vendida DESC;

-- Clientes con mayores descuentos

SELECT c.CompanyName, COUNT(od.Discount) AS Conteo_de_descuentos
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY c.CompanyName
ORDER BY Conteo_de_descuentos DESC;

-- Cantidad de pedidos por país

SELECT ShipCountry, COUNT(OrderID) AS Cantidad_pedidos
FROM Orders
GROUP BY ShipCountry
ORDER BY Cantidad_pedidos DESC;

-- Ventas por país

SELECT o.ShipCountry, SUM(od.quantity * od.unitprice * (1-od.discount)) AS total_sold
FROM Orders o
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.ShipCountry
ORDER BY total_sold DESC;

-- Proporción de clientes por país

SELECT Country, COUNT(*) AS Cantidad_Clientes
FROM Customers
GROUP BY Country
ORDER BY Cantidad_Clientes DESC;

-- Ingreso promedio por pedido

SELECT OrderID, AVG(Quantity * UnitPrice * (1-Discount)) AS Promedio_ingresos
FROM [Order Details]
GROUP BY OrderID
ORDER BY Promedio_ingresos DESC;

-- Pedidos grandes

SELECT TOP 10 OrderID, SUM(Quantity) AS Cantidad, SUM(UnitPrice * Quantity) AS Ventas
FROM [Order Details]
GROUP BY OrderID
ORDER BY Ventas DESC;

-- Practicar vistas

-- Crea una vista que muestre los pedidos con un monto total mayor a $5000. Incluye los detalles del pedido, el cliente y el monto total.
CREATE VIEW High_sales AS
SELECT o.OrderID, c.CompanyName, p.ProductName, SUM(od.Quantity*od.UnitPrice * (1-od.Discount)) AS Total_sales
FROM [Order Details] od
JOIN Products p
ON od.ProductID = p.ProductID
JOIN Orders o
ON od.OrderID = o.OrderID
JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CompanyName, p.ProductName
HAVING SUM(od.Quantity*od.UnitPrice * (1-od.Discount)) > 5000;

SELECT *
FROM High_sales;

-- Crea una vista que liste los 10 productos más vendidos, incluyendo el nombre del producto, la cantidad total vendida y la categoría.

CREATE VIEW top_sales AS
SELECT TOP 10 p.ProductName, od.Quantity, c.CategoryName
FROM Products p
JOIN [Order Details] od
ON p.ProductID = od.ProductID
JOIN Categories c
ON c.CategoryID = p.CategoryID
ORDER BY od.Quantity DESC;

SELECT *
FROM top_sales;

-- Crea una vista que calcule el total de ventas por región y por empleado. Incluye el nombre del empleado, la región y el monto total de ventas.

CREATE VIEW Ventas_region_empleado AS
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Nombre_empleado, r.RegionDescription AS Region, SUM(od.Quantity * od.UnitPrice * (1-od.Discount)) AS Total_sales
FROM Employees e
JOIN EmployeeTerritories et
ON e.EmployeeID = et.EmployeeID
JOIN Territories t
ON et.TerritoryID = t.TerritoryID
JOIN Region r
ON t.RegionID = r.RegionID
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName, r.RegionDescription;

SELECT *
FROM Ventas_region_empleado
ORDER BY Total_sales DESC;