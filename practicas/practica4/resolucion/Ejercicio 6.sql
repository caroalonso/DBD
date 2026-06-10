

-- 1. Listar los repuestos, informando el nombre, stock y precio. 
-- Ordenar el resultado por precio.

SELECT rep.nombre , rep.stock , rep.precio
FROM repuesto rep
ORDER BY rep.precio;

--2. Listar nombre, stock y precio de repuestos QUE se usaron en reparaciones durante 2023 
y que no se usaron en reparaciones del técnico ‘José Gonzalez’.

opción 1)

SELECT r.nombre, r.stock,r.precio 
FROM repuesto r
INNER JOIN repuestoreparacion rp ON r.codRep= rp.codRep
INNER JOIN reparacion re ON rp.nroReparac = re.nroReparac
INNER JOIN tecnico t ON re.codTec = t.codTec
WHERE YEAR (re.fecha) = 2023

EXCEPT 

SELECT r.nombre, r.stock,r.precio 
FROM repuesto r
INNER JOIN repuestoreparacion rp ON r.codRep= rp.codRep
INNER JOIN reparacion re ON rp.nroReparac = re.nroReparac
INNER JOIN tecnico t ON re.codTec = t.codTec
WHERE t.nombre = 'Jose Gonzalez';

opción 2)

SELECT r.nombre, r.stock, r.precio
FROM repuesto r
WHERE EXISTS (
SELECT 1
FROM repuestoreparacion rr
INNER JOIN reparacion re ON rr.nroReparac = re.nroReparac
WHERE r.codRep = rr.codRep
AND YEAR(re.fecha) = 2023
)
AND NOT EXISTS(
SELECT 1
FROM repuestoreparacion rr
INNER JOIN reparacion re ON rr.nroReparac = re.nroReparac
INNER JOIN tecnico t ON re.codTec = t.codTec
WHERE r.codRep = rr.codRep
AND t.nombre = 'Jose Gonzalez'
);


-- 3. Listar el nombre y especialidad de técnicos que no participaron en ninguna reparación.
-- Ordenar por nombre ascendentemente.

SELECT t.nombre, t.especialidad
FROM tecnico t
LEFT JOIN reparacion r ON t.codTec=r.codTec
WHERE r.codTec IS NULL
ORDER by t.nombre ASC;



-- 4. Listar el nombre y especialidad de los técnicos que SOLAMENTE participaron en reparaciones durante 2022.

opción 1)

SELECT t.codTec, t.nombre, t.especialidad
FROM tecnico t 
INNER JOIN reparacion r ON t.codTec=r.codTec
WHERE YEAR (r.fecha) = 2022

EXCEPT 

SELECT t.codTec,t.nombre, t.especialidad
FROM tecnico t 
INNER JOIN reparacion r ON t.codTec=r.codTec
WHERE YEAR (r.fecha) <> 2022;

-- NOTA : es necesario en except proyectar también la pk del técnico  
-- podría darse el caso de tener 2 técnicos con mismo nombre y con cual se quedaría?

opción 2)

SELECT t.nombre, t.especialidad
FROM tecnico t 
WHERE EXISTS (
    SELECT 1
    FROM reparacion r
    WHERE r.codTec = t.codTec
   AND YEAR(r.fecha) = 2022
)
AND NOT EXISTS (
    SELECT 1
    FROM reparacion r 
    WHERE r.codTec = t.codTec
    AND YEAR(r.fecha) <> 2022
);



-- 5. Listar PARA CADA REPUESTO nombre, stock y cantidad de técnicos distintos que lo utilizaron. 
-- Si un repuesto no participó en alguna reparación igual debe aparecer en dicho listado.

SELECT r.nombre,r.stock,COUNT(DISTINCT repa.codTec) AS cantidadtecnicos 
FROM repuesto r
LEFT JOIN repuestoreparacion rp ON r.codRep= rp.codRep
LEFT JOIN reparacion repa ON rp.nroReparac= repa.nroReparac
GROUP BY r.codRep, r.nombre, r.stock;


-- 6.Listar nombre y especialidad del técnico con mayor cantidad de reparaciones realizadas y el
-- técnico con menor cantidad de reparaciones. // su usa left join técnico podría tener 0 reparacion

SELECT t.nombre,t.especialidad, COUNT(r.nroReparac) AS cantidad -- no se usa COUNT(*) por que cuenta los nulls
FROM tecnico t                                                  -- ideal usar columna con pk
LEFT JOIN reparacion r ON t.codTec=r.codTec
GROUP BY t.codTec, t.nombre, t.especialidad

HAVING COUNT(r.nroReparac) = (
SELECT MAX(cantmax)
FROM(
    SELECT COUNT(r2.nroReparac) AS cantmax
    FROM tecnico t2
    LEFT JOIN reparacion r2 ON t2.codTec=r2.codTec
    GROUP BY t2.codTec
    )ta1
)

OR COUNT(r.nroReparac) = (  
SELECT MIN (cantmin)
FROM(
    SELECT COUNT(r3.nroReparac) AS cantmin
    FROM tecnico t3
    LEFT JOIN reparacion r3 ON t3.codTec=r3.codTec
    GROUP BY t3.codTec
)ta2
);



-- 7. Listar nombre, stock y precio de todos los repuestos con stock mayor a 0 y que dicho repuesto
-- no haya estado en reparaciones con un precio total superior a $10000.

SELECT r.nombre, r.stock , r.precio
FROM repuesto r
WHERE r.stock > 0
AND NOT EXISTS(
    SELECT 1
    FROM repuestoreparacion rr
    INNER JOIN reparacion repa ON rr.nroReparac=repa.nroReparac
    WHERE rr.codRep = r.codRep
    AND repa.precio > 10000
);


-- 8. Proyectar número, fecha y precio total de aquellas reparaciones donde se utilizó algún repuesto
-- con precio en el momento de la reparación mayor a $10000 y menor a $15000.

opcion1)
SELECT DISTINCT repa.nroReparac,repa.fecha, repa.precio_total
FROM reparacion repa
INNER JOIN repuestoreparacion rr ON repa.nroReparac = rr.nroReparac
WHERE rr.precio > 10000 AND rr.precio < 15000;


opcion 2)
SELECT repa.nroReparac,repa.fecha,repa.precio_total
FROM reparacion repa
WHERE EXISTS (
SELECT 1
FROM repuestoreparacion rr
WHERE rr.nroReparac = repa.nroReparac
AND rr.precio > 10000
AND rr.precio < 15000
);

-- 9. Listar nombre, stock y precio de repuestos que hayan sido utilizados por todos los técnicos.

SELECT r.nombre,r.stock, r.precio
FROM repuesto r 
WHERE NOT EXISTS(
  SELECT 1
  FROM tecnico t  
  WHERE NOT EXISTS( 
    SELECT 1
    FROM reparacion repa
    INNER JOIN repuestoreparacion rr ON  repa.nroReparac=rr.nroReparac
    WHERE t.codTec= repa.codTec
    AND rr.codRep= r.codRep
  )
);   


-- 10. Listar fecha, técnico y precio total de aquellas reparaciones que necesitaron al menos 4
-- repuestos distintos.

SELECT r.fecha, r.codTec, r.precio_total
FROM reparacion r
INNER JOIN repuestoreparacion rr ON rr.nroReparac = r.nroReparac
GROUP BY r.nroReparac, r.fecha, r.codTec, r.precio_total
HAVING COUNT(DISTINCT rr.codRep) >= 4;












