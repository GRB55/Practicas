-- PRACTICA WINDOW FUNCTIONS

/*
Lista los productos junto con el total de ventas (Quantity * UnitPrice) y 
un ranking de ventas dentro de cada categoría de producto.
*/
SELECT p.ProductName, c.CategoryName, SUM(o.Quantity * o.UnitPrice) AS Total_sales,
		DENSE_RANK() OVER (PARTITION BY c.CategoryName ORDER BY SUM(o.Quantity * o.UnitPrice) DESC) AS sales_rank
FROM [Order Details] o
JOIN Products p
ON o.ProductID = P.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY p.ProductName, c.CategoryName
ORDER BY c.CategoryName, sales_rank;

/*
Calcula el promedio móvil de las ventas (Freight) para cada empleado 
en un período de 3 pedidos consecutivos, ordenados por fecha (OrderDate).
*/
SELECT e.EmployeeID,o.OrderDate,
		AVG(o.Freight) OVER (PARTITION BY e.EmployeeID 
							ORDER BY o.OrderDate 
							ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS promedio_movil
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID;

/*
Muestra el CustomerID, el total de ventas por pedido y 
el porcentaje que cada pedido representa respecto al total de ventas de ese cliente.
*/
SELECT c.CustomerID, od.OrderID, SUM(od.Quantity * od.UnitPrice) AS total_sold_order,
		(SUM(od.Quantity * od.UnitPrice) * 100 / SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY c.CustomerID)) AS pct_total_sales
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY od.OrderID, c.CustomerID
ORDER BY c.CustomerID, od.OrderID;

/*
Para cada producto, calcula el total acumulado de ventas y
la diferencia entre las ventas acumuladas y el total de ventas hasta el pedido anterior.
*/
SELECT p.ProductName,
		SUM(od.Quantity * od.UnitPrice) OVER (PARTITION BY p.ProductName ORDER BY o.OrderDate) AS cummulative_sales,
		SUM(od.Quantity * od.UnitPrice) OVER (PARTITION BY  p.ProductName ORDER BY o.OrderDate ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) -
		SUM(od.Quantity * od.UnitPrice) OVER (PARTITION BY  p.ProductName ORDER BY o.OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS diff
FROM [Order Details] od
JOIN Products p
ON od.ProductID = p.ProductID
JOIN Orders o
ON od.OrderID = o.OrderID
GROUP BY p.ProductName, o.OrderDate
ORDER BY p.ProductName, o.OrderDate;

/*
Encuentra para cada empleado la fecha de su primer y último pedido, 
y calcula la diferencia en días entre ambos.
*/
SELECT e.EmployeeID, MIN(o.OrderDate) AS primer_pedido, MAX(o.OrderDate) AS ultimo_pedido,
			DATEDIFF(DAY, MIN(o.OrderDate), MAX(o.OrderDate)) AS dif
FROM Employees e
JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
ORDER BY dif DESC;

-- PRACTICA CTEs

/*
Usa un CTE para calcular el total de ventas (Quantity) por producto y
luego selecciona los 5 productos más vendidos.
*/
WITH ventas_por_producto AS (
SELECT p.ProductName, SUM(od.Quantity) AS total_ventas
FROM Products p
JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY p.ProductName)
SELECT TOP 5 *
FROM ventas_por_producto
ORDER BY total_ventas DESC;

/*
Crea un CTE para obtener el número total de pedidos por cliente.
Luego, utiliza esta información para listar a los clientes que tienen más de 20 pedidos.
*/
WITH pedidos_por_clientes AS (
SELECT c.CompanyName, COUNT(o.OrderID) AS total_pedidos
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName)
SELECT *
FROM pedidos_por_clientes
WHERE total_pedidos > 20;

/*
Usa un CTE para calcular el precio promedio de los productos dentro de cada categoría y 
luego lista aquellos productos cuyo precio está por encima de este promedio.
*/
WITH promedio_categoria AS (
SELECT c.CategoryID, AVG(p.UnitPrice) AS promediocategoria
FROM Products p
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID)
SELECT c.CategoryName, p.ProductName, p.UnitPrice, pc.promediocategoria
FROM Products p
JOIN Categories c
ON p.CategoryID = c.CategoryID
JOIN promedio_categoria pc
ON c.CategoryID = pc.CategoryID
WHERE p.UnitPrice > pc.promediocategoria
GROUP BY c.CategoryName, p.ProductName, p.UnitPrice, pc.promediocategoria
ORDER BY CategoryName, ProductName;

/*
Crea un CTE para calcular la diferencia en días entre la fecha requerida (RequiredDate) y la fecha de envío (ShippedDate).
Lista solo los pedidos que se enviaron tarde.
*/
WITH envios_tardios AS (
SELECT RequiredDate, ShippedDate, DATEDIFF(DAY, RequiredDate, ShippedDate) AS dias_atrasado
FROM Orders)
SELECT *
FROM envios_tardios
WHERE dias_atrasado > 0
ORDER BY dias_atrasado DESC;

/*
Utiliza un CTE recursivo para crear una jerarquía que muestre a cada empleado junto con su gerente directo.
*/
WITH empleado_gerente AS (
SELECT em.EmployeeID, CONCAT(em.FirstName, ' ', em.LastName) AS Fullname, em.ReportsTo, CONCAT(emp.FirstName, ' ',emp.LastName) AS Managername
FROM Employees em
JOIN Employees emp
ON em.ReportsTo = emp.EmployeeID)
SELECT *
FROM empleado_gerente;

-- PRACTICA COMBINADA

/*
Usa un CTE para calcular el total de ventas por categoría. 
Luego, dentro de cada categoría, asigna un ranking acumulativo a los productos basándote en el total de ventas.
*/
WITH total_ventas_categoria AS (
SELECT c.CategoryName, p.ProductName,SUM(od.Quantity) AS total_venta
FROM Categories c
JOIN Products p
ON c.CategoryID = p.CategoryID
JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY c.CategoryName, p.ProductName
)
SELECT CategoryName, ProductName, total_venta,
		SUM(total_venta) OVER (PARTITION BY CategoryName
								ORDER BY totaL_venta DESC
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS venta_acumulativa,
		RANK() OVER (PARTITION BY CategoryName
						ORDER BY total_venta DESC) AS ranking_en_cat
FROM total_ventas_categoria

/*
Crea un CTE para listar los pedidos de cada cliente. 
Usa una función de ventana para calcular el intervalo de días entre pedidos consecutivos por cliente.
*/
WITH pedidos AS (
SELECT CustomerID, OrderID, OrderDate, 
		LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrder
FROM Orders
)
SELECT CustomerID, OrderID, OrderDate, NextOrder, DATEDIFF(DAY, OrderDate, NextOrder) AS DayDiff
FROM pedidos
WHERE NextOrder IS NOT NULL;

/*
Usa un CTE para agregar las ventas mensuales por producto y
luego calcula el porcentaje de cambio en ventas mes a mes utilizando una función de ventana.
*/
WITH ventas_mensuales AS (
SELECT p.ProductName, YEAR(o.OrderDate) AS año_venta, MONTH(o.OrderDate) AS mes_venta, SUM(od.Quantity) AS cantidad_mensual
FROM Products p
JOIN [Order Details] od
ON p.ProductID = od.ProductID
JOIN Orders o
ON od.OrderID = od.OrderID
GROUP BY p.ProductName,  YEAR(o.OrderDate), MONTH(o.OrderDate)
)
SELECT ProductName, año_venta, mes_venta, cantidad_mensual,
		LAG(cantidad_mensual) OVER (PARTITION BY ProductName ORDER BY año_venta, mes_venta) AS ventas_anteriores,
		CASE
			WHEN LAG(cantidad_mensual) OVER (PARTITION BY ProductName ORDER BY año_venta, mes_venta) IS NOT NULL THEN
			((cantidad_mensual - LAG(cantidad_mensual) OVER (PARTITION BY ProductName ORDER BY año_venta, mes_venta)) * 100 /
			LAG(cantidad_mensual) OVER (PARTITION BY ProductName ORDER BY año_venta, mes_venta))
			ELSE 0
		END AS cambio_porcentual
FROM ventas_mensuales;