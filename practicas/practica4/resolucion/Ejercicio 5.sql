-- 1. Listar razón social, dirección y teléfono de agencias que realizaron viajes desde la ciudad de ‘La Plata’ (ciudad origen) y que el cliente tenga apellido ‘Roma’. 
-- Ordenar por razón social y luego por teléfono.

SELECT a.razon_social,a.direccion,a.telef
FROM agencia a
WHERE EXISTS(
  SELECT 1
  FROM viaje v 
  INNER JOIN cliente c ON v.dni = c.dni
  INNER JOIN ciudad ciu ON v.cpOrigen = ciu.codigo_postal 
  WHERE a.razon_social = v.razon_social 
  AND c.apellido = 'Roma'
  AND ciu.nombreCiudad = 'La Plata'
)
ORDER BY a.razon_social,a.telef;



-- 2.Listar fecha, hora, datos personales del cliente, nombres de ciudades origen y destino de viajes realizados en enero de 2019 donde la descripción del viaje contenga el String ‘demorado’

SELECT v.fecha,v.hora,c.dni,c.nombre,c.apellido,c.telefono,c.direccion,
origen.nombreCiudad AS CiudadOrigen , destino.nombreCiudad AS CiudadDestino

FROM viaje v
INNER JOIN cliente c ON v.dni = c.dni
INNER JOIN ciudad origen ON v.cpOrigen = origen.codigo_postal
INNER JOIN ciudad destino ON v.cpDestino = destino.codigo_postal
WHERE v.fecha BETWEEN '2019-01-01' AND '2019-01-31'
AND v.descripcion LIKE '%demorado%';



-- 3.Reportar información de agencias que realizaron viajes durante 2019 o que tengan dirección de mail que termine con ‘@jmail.com’.

SELECT DISTINCT a.razon_social,a.direccion,a.telef,a.email
FROM agencia a
INNER JOIN viaje v ON a.razon_social = v.razon_social
WHERE YEAR(v.fecha) = 2019 
OR a.email LIKE '%@jmail.com';

-- la agencia podría no tener viajes pero si tiene un email para evaluar , asi que debe mostrarse (LEFT JOIN)



-- 4. Listar datos personales de clientes que viajaron solo con destino a la ciudad de ‘Coronel
-- Brandsen’.

SELECT c.dni,c.nombre,c.apellido,c.telefono,c.direccion
FROM cliente c
WHERE NOT EXISTS(
  SELECT 1
  FROM viaje v 
  INNER JOIN ciudad ciu ON v.cpDestino = ciu.codigo_postal
  WHERE c.dni = v.dni
  AND ciu.nombreCiudad <> 'Coronel Brandsen'
);



-- 6.Listar nombre, apellido, dirección y teléfono de clientes que viajaron con todas las agencias.

SELECT c.nombre,c.apellido,c.direccion,c.telefono
FROM cliente c
WHERE NOT EXISTS(
  SELECT 1
  FROM agencia a
  WHERE NOT EXISTS(
      SELECT 1
      FROM viaje v
      WHERE v.razon_social = a.razon_social
      AND v.dni  = c.dni
  )
);



-- 7.Modificar el cliente con DNI 38495444 actualizando el teléfono a ‘221-4400897’.

UPDATE cliente SET telefono='221-4400897' WHERE dni=38495444;


-- 8. Listar razón social, dirección y teléfono de la/s agencias que tengan mayor cantidad de viajes
realizados.

SELECT a.razon_social,a.direccion,a.telef,COUNT(*) AS cantidad
FROM agencia a
INNER JOIN viaje j ON a.razon_social = j.razon_social
GROUP BY a.razon_social, a.direccion, a.telef
HAVING COUNT(*) = (
    SELECT MAX(cantidad)
    FROM (
        SELECT COUNT(*) AS cantidad
        FROM viaje
        GROUP BY razon_social
    ) t
);



-- 9. Reportar nombre, apellido, dirección y teléfono de clientes con al menos 5 viajes.

SELECT c.nombre,c.apellido,c.direccion,c.telefono
FROM cliente c
INNER JOIN viaje v ON c.dni=v.dni
GROUP BY c.dni,c.nombre,c.apellido,c.direccion,c.telefono
HAVING COUNT(*) >= 5;


-- 10. Borrar al cliente con DNI 40325692.

DELETE FROM viaje WHERE dni=40325692;

DELETE FROM cliente WHERE dni=40325692;
