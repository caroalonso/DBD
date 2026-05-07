-- 1.Listar especie, años, calle, nro y localidad de árboles podados por el podador ‘Juan Perez’ y  por el podador ‘Jose Garcia’.

SELECT DISTINCT a.especie, a.anios, a.calLe, a.nro, l.codigoPostal
FROM arbol a
INNER JOIN Localidad l ON a.codigoPostal = l.codigoPostal
WHERE EXISTS (
    SELECT 1
    FROM poda po
    INNER JOIN podador p ON po.DNI = p.DNI
    WHERE a.nroArbol = po.nroArbol
    AND p.nombre = 'Juan' AND p.apellido = 'Perez'
)AND EXISTS(
    SELECT 1
    FROM poda po 
    INNER JOIN podador p ON po.DNI = p.DNI
    WHERE a.nroArbol = po.nroArbol
    AND p.nombre = 'Jose' AND p.apellido= 'Garcia'
);



-- 2.Reportar DNI, nombre, apellido, fecha de nacimiento y localidad donde viven aquellos
-- podadores que tengan podas realizadas durante 2023.

SELECT p.DNI, p.nombre, p.apellido, p.fnac, l.nombreL
FROM podador p
INNER JOIN localidad l 
ON p.codigoPostalVive = l.codigoPostal
WHERE EXISTS (
  SELECT 1
  FROM poda po
  WHERE po.DNI= p.DNI 
  AND YEAR (po.fecha) = 2023
);



-- 3.Listar especie, años, calle, nro y localidad de árboles que no fueron podados nunca

SELECT a.especie,a.anios,a.calle,a.nro, l.nombreL
FROM arbol a
INNER JOIN localidad l
ON a.codigoPostal= l.codigoPostal
LEFT JOIN poda p
ON a.nroArbol = p.nroArbol
WHERE p.nroArbol IS NULL



-- 4.Reportar especie, años,calle, nro y localidad de árboles que fueron podados durante 2022 y no
-- fueron podados durante 2023.

-- OPCION 1 PUNTO 4:
SELECT a.especie,a.anios,a.calle,a.nro, l.nombreL
FROM arbol a
INNER JOIN localidad l ON a.codigoPostal= l.codigoPostal
INNER JOIN poda p  ON a.nroArbol = p.nroArbol
WHERE YEAR(p.fecha) = 2022

EXCEPT 

SELECT a.especie,a.anios,a.calle,a.nro, l.nombreL
FROM arbol a
INNER JOIN localidad l ON a.codigoPostal= l.codigoPostal
INNER JOIN poda p  ON a.nroArbol = p.nroArbol
WHERE YEAR(p.fecha) = 2023;


-- OPCION 2 PUNTO 4:
SELECT a.especie, a.anios, a.calle, a.nro, l.nombreL
FROM arbol a
INNER JOIN localidad l ON a.codigoPostal = l.codigoPostal

WHERE EXISTS (
  SELECT 1
  FROM poda p
  WHERE p.nroArbol = a.nroArbol
  AND YEAR(p.fecha) = 2022
)
AND NOT EXISTS (
  SELECT 1
  FROM poda p
  WHERE p.nroArbol = a.nroArbol
  AND YEAR(p.fecha) = 2023
);



-- 5. Reportar DNI, nombre, apellido, fecha de nacimiento y localidad donde viven de aquellos
-- podadores con apellido terminado con el string ‘ata’ y que tengan al menos una poda durante
-- 2024. Ordenar por apellido y nombre.

SELECT p.DNI,p.nombre,p.apellido,p.fnac,l.nombreL
FROM podador p
INNER JOIN localidad l ON p.codigoPostalVive = l.codigoPostal
WHERE p.apellido LIKE '%ata' 
AND EXISTS (
  SELECT 1
  FROM poda po
  WHERE po.DNI = p.DNI
  AND YEAR (po.fecha) = 2024  
)
ORDER BY p.apellido, p.nombre;



-- 6. Listar DNI, apellido, nombre, teléfono y fecha de nacimiento de podadores que SOLO podaron
-- árboles de especie ‘Coníferas’.


-- OPCION 1 PUNTO 6:
SELECT p.DNI, p.apellido, p.nombre, p.telefono, p.fnac
FROM podador p
WHERE EXISTS (
  SELECT 1
  FROM poda po
  INNER JOIN arbol a 
  ON po.nroArbol = a.nroArbol
  WHERE po.DNI = p.DNI
  AND a.especie = 'Coníferas'
)
AND NOT EXISTS (
  SELECT 1
  FROM poda po
  INNER JOIN arbol a 
  ON po.nroArbol = a.nroArbol
  WHERE po.DNI = p.DNI
  AND a.especie <> 'Coníferas'
);


-- OPCION 2 PUNTO 6:
SELECT p.DNI, p.apellido, p.nombre, p.telefono, p.fnac
FROM podador p
INNER JOIN poda po
ON po.DNI = p.DNI
INNER JOIN arbol a
ON po.nroArbol = a.nroArbol
WHERE a.especie = 'Coníferas'

EXCEPT 

SELECT p.DNI, p.apellido, p.nombre, p.telefono, p.fnac
FROM podador p
INNER JOIN poda po
ON po.DNI = p.DNI
INNER JOIN arbol a
ON po.nroArbol = a.nroArbol
WHERE a.especie <> 'Coníferas';



-- 7. Listar especies de árboles que se encuentren en la localidad de ‘La Plata’ y también en la
-- localidad de ‘Salta’.

SELECT DISTINCT a.especie -- distinct por que tabla arbol puede tener especies repetidas.
FROM arbol a
WHERE EXISTS(
  SELECT 1
  FROM arbol a1
  INNER JOIN localidad l ON a1.codigoPostal= l.codigoPostal
  WHERE a.especie = a1.especie
  AND l.nombreL = 'La Plata'
) 
AND EXISTS(
  SELECT 1
  FROM arbol a1
  INNER JOIN localidad l ON a1.codigoPostal= l.codigoPostal
  WHERE a.especie = a1.especie
  AND l.nombreL = 'Salta'
);



-- 8. Eliminar el podador con DNI 22234566.
DELETE FROM podador
WHERE DNI = '22234566';



-- 9.Reportar nombre, descripción y cantidad de habitantes de localidades que tengan menos de 5
-- árboles.

SELECT l.nombreL,l.descripcion,l.nroHabitantes
FROM localidad l
INNER JOIN arboL a
ON a.codigoPostal= l.codigoPostal
GROUP BY l.codigoPostal,l.nombreL,l.descripcion,l.nroHabitantes
HAVING COUNT(a.nroArbol) < 5;


