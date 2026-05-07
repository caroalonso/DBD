-- 1. Listar datos personales de clientes cuyo apellido comience con el string ‘Pe’. Ordenar por DNI.

SELECT c.nombre, c.apellido, c.DNI,c.telefono, c.direccion
FROM cliente c
WHERE (c.apellido LIKE 'Pe%');



-- 2.Listar nombre, apellido, DNI, teléfono y dirección de clientes que realizaron compras solamente
-- durante 2024.

SELECT c.nombre, c.apellido , c.DNI, c.telefono , c.direccion
FROM cliente c INNER JOIN factura f 
ON c.idCliente = f.idCliente
WHERE YEAR(f.fecha) = 2024

EXCEPT -- Diferencia A-B (todo lo que este en A que no este en B)

SELECT c.nombre, c.apellido, c.DNI, c.telefono , c.direccion
FROM cliente c INNER JOIN factura f 
ON c.idCliente = f.idCliente
WHERE YEAR(f.fecha) <> 2024;



-- 3.Listar nombre, descripción, precio y stock de productos vendidos al cliente con DNI 45789456,
-- pero que NO fueron vendidos a clientes de apellido ‘Garcia’.

SELECT DISTINCT p.nombreP, p.descripcion, p.precio , p.stock
FROM producto p 
INNER JOIN detalle d ON p.idProducto = d.idProducto
INNER JOIN factura f ON d.nroTicket = f.nroTicket
INNER JOIN cliente c On f.idCliente = c.idCliente
WHERE c.DNI = 45789456 

EXCEPT -- Diferencia A-B (todo lo que este en A que no este en B)

SELECT p.nombreP, p.descripcion, p.precio , p.stock
FROM producto p 
INNER JOIN detalle d ON p.idProducto = d.idProducto
INNER JOIN factura f ON d.nroTicket = f.nroTicket
INNER JOIN cliente c On f.idCliente = c.idCliente
WHERE c.apellido = 'Garcia';



-- 4.Listar nombre, descripción, precio y stock de productos no vendidos a clientes que tengan teléfono con característica 221 (la característica está al comienzo del teléfono). Ordenar por nombre

SELECT p.nombreP , p.descripcion , p.precio , p.stock -- muestra todo los prodcutos
FROM producto p
WHERE NOT EXISTS ( -- donde no existan
  -- productos vendidos a clientes con caracteristicas 221
  SELECT 1
  FROM detalle d 
  INNER JOIN factura f ON d.nroTicket = f.nroTicket
  INNER JOIN cliente c ON f.idCliente = c.idCliente
  WHERE  d.idProducto = p.idProducto
  AND c.telefono LIKE '221%'
)
ORDER BY p.nombreP; -- ordenados por nombre



-- 5.Listar para cada producto nombre, descripción, precio y cuantas veces fue vendido. 
-- Tenga en cuenta que puede no haberse vendido nunca el producto.

SELECT p.nombreP,p.descripcion,p.precio, COUNT(d.idProducto) AS CantidadVedida
FROM producto p
LEFT JOIN detalle d -- todo los productos / posibles null en detalle.
ON p.idProducto = d.idProducto
GROUP BY p.nombreP,p.descripcion,p.precio;
-- En una consulta con GROUP BY, toda columna del SELECT debe estar incluida en el GROUP BY o ser parte de una función de agregación.



-- 6.Listar nombre, apellido, DNI, teléfono y dirección de clientes que compraron 
-- los productos con nombre ‘prod1’ y ‘prod2’ pero nunca compraron el producto con nombre ‘prod3’.

SELECT c.nombre,c.apellido,c.DNI,c.telefono,c.direccion
FROM cliente c
WHERE EXISTS(
  SELECT 1 
  FROM factura f 
  INNER JOIN detalle d ON f.nroTicket = d.nroTicket
  INNER JOIN producto p ON d.idProducto = p.idProducto
  WHERE f.idCliente = c.idCliente 
  AND p.nombreP = 'prod1'  
)
AND EXISTS(
  SELECT 1
  FROM factura f 
  INNER JOIN detalle d ON f.nroTicket = d.nroTicket
  INNER JOIN producto p ON d.idProducto = p.idProducto
  WHERE f.idCliente = c.idCliente
  AND p.nombreP = 'prod2' 
) 
AND NOT EXISTS(
  SELECT 1
  FROM factura f 
  INNER JOIN detalle d ON f.nroTicket = d.nroTicket
  INNER JOIN producto p ON d.idProducto = p.idProducto
  WHERE f.idCliente = c.idCliente
  AND p.nombreP = 'prod3'
);



-- 7.Listar nroTicket, total, fecha, hora y DNI del cliente, de aquellas facturas donde se haya
-- comprado el producto ‘prod38’ o la factura tenga fecha de 2023.

SELECT f.nroTicket,f.total,f.fecha,f.hora,c.DNI
FROM factura f
INNER JOIN cliente c ON f.idCliente = c.idCliente
WHERE YEAR(f.fecha) = 2023 OR 
EXISTS(
    SELECT 1
    FROM detalle d
    INNER JOIN producto p ON d.idProducto = p.idProducto
    WHERE f.nroTicket = d.nroTicket
    AND p.nombreP ='prod38'
);



-- 8. Agregar un cliente con los siguientes datos: 
-- nombre:’Jorge Luis’,
-- apellido:’Castor’, 
-- DNI: 40578999, 
-- teléfono: ‘221-4400789’, 
-- dirección:’11 entre 500 y 501 nro:2587’
-- id de cliente: 500002. 
-- Se supone que el idCliente 500002 no existe.

INSERT INTO cliente (idCliente,nombre,apellido,DNI,telefono,direccion) 
VALUES(500002,'Jorge Luis','Castor','40578999','221-4400789','11 entre 500 y 501 nro:2587');



-- 9.Listar nroTicket, total, fecha, hora para las facturas del cliente ´Juan Perez´ donde NO haya
-- comprado el producto ´Z´.

SELECT f.nroTicket,f.total,f.fecha,f.hora
FROM factura f
INNER JOIN cliente c ON f.idCliente = c.idCliente
WHERE c.nombre = 'Juan' AND c.apellido = 'Perez'
AND NOT EXISTS (
    SELECT 1
    FROM detalle d 
    INNER JOIN producto p ON d.idProducto = p.idProducto
    WHERE f.nroTicket = d.nroTicket
    AND p.nombreP = 'Z'
);



-- 10.Listar DNI, apellido y nombre de clientes donde el monto total comprado, teniendo en cuenta
-- todas sus facturas, supere $100000.

SELECT c.DNI,c.apellido,c.nombre
FROM cliente c
INNER JOIN factura f ON c.idCliente = f.idCliente
GROUP BY c.idCliente , c.DNI, c.apellido , c.nombre -- se agregar los elementos de select
HAVING SUM(f.total) > 100000; 
-- las funciones de agregacion se pueden en el select si queremos proyectar,
-- en el having y en el orden by, NO se pueden usar en el where.









