
-- 1.Listar DNI, nombre, apellido,dirección y email de integrantes nacidos entre 1980 y 1990 y que
-- hayan realizado algún recital durante 2023.

SELECT i.DNI,i.nombre,i.apellido,i.direccion,i.email
FROM integrante i
WHERE YEAR(i.fecha_nacimiento) BETWEEN 1980 AND 1990
AND EXISTS(
    SELECT 1
    FROM recital r
    WHERE r.codigoB = i.codigoB
    AND YEAR(r.fecha) = 2023
);



-- 2.Reportar nombre, género musical y año de creación de bandas que hayan realizado recitales
-- durante 2023, pero NO hayan tocado durante 2022.

SELECT b.nombreBanda, b.genero_musical, b.anio_creacion
FROM banda b
WHERE EXISTS( -- algún recital en 2023
    SELECT 1
    FROM recital r
    WHERE b.codigoB = r.codigoB
    AND YEAR(r.fecha) = 2023
) 
AND NOT EXISTS( -- ningún recital en 2022
    SELECT 1
    FROM recital r 
    WHERE b.codigoB = r.codigoB
    AND YEAR(r.fecha) = 2022 
);



-- 3.Listar el cronograma de recitales del día 04/12/2023. 
-- Se deberá listar nombre de la banda que ejecutará el recital, fecha, hora, y el nombre y ubicación del escenario correspondiente.

-- bandas que toquen para la fecha 2023-12-04
-- nombre de la banda // banda
-- fecha hora // recital
-- nombre y ubicacion // escenario

SELECT b.nombreBanda,r.fecha,r.hora, e.nombre_escenario,e.ubicacion
FROM banda b
INNER JOIN recital r ON b.codigoB = r.codigoB
INNER JOIN escenario e ON r.nroEscenario = e.nroEscenario
WHERE r.fecha = '2023-12-04'; -- 'año-mes-dia' 



-- 4.Listar DNI, nombre, apellido,email de integrantes que hayan tocado en el escenario con nombre ‘Gustavo Cerati’ y en el escenario con nombre ‘Carlos Gardel’.

SELECT i.DNI,i.nombre,i.apellido,i.email
FROM integrante i 
WHERE EXISTS(
    SELECT 1
    FROM recital r 
    INNER JOIN escenario e ON r.nroEscenario = e.nroEscenario
    WHERE i.codigoB = r.codigoB
    AND e.nombre_escenario = 'Gustavo Cerati'
)
AND EXISTS(
    SELECT 1
    FROM recital r 
    INNER JOIN escenario e ON r.nroEscenario = e.nroEscenario
    WHERE i.codigoB = r.codigoB
    AND e.nombre_escenario = 'Carlos Gardel'
);



-- 5. Reportar nombre, género musical y año de creación de bandas que tengan más de 5 integrantes.

SELECT b.nombreBanda,b.genero_musical,b.anio_creacion
FROM banda b
INNER JOIN integrante i ON b.codigoB = i.codigoB
GROUP BY  b.nombreBanda,b.genero_musical,b.anio_creacion
HAVING COUNT(i.DNI) > 5;



-- 6.Listar nombre de escenario, ubicación y descripción de escenarios que SOLO tuvieron recitales con el género musical rock and roll. 
-- Ordenar por nombre de escenario.

SELECT e.nombre_escenario,e.ubicacion,e.descripcion
FROM escenario e
WHERE NOT EXISTS(
  SELECT 1
  FROM recital r
  INNER JOIN banda b ON r.codigoB = b.codigoB
  WHERE  e.nroEscenario = r.nroEscenario
  AND b.genero_musical <> 'Rock and Roll'
)
ORDER BY e.nombre_escenario;



-- 7. Listar nombre, género musical y año de creación de bandas que hayan realizado recitales en
-- escenarios cubiertos durante 2023.// cubierto es true, false según corresponda.

SELECT b.nombreBanda,b.genero_musical,b.anio_creacion
FROM banda b
WHERE EXISTS(
  SELECT 1
  FROM recital r 
  INNER JOIN escenario e ON r.nroEscenario= e.nroEscenario
  WHERE b.codigoB = r.codigoB 
  AND YEAR(r.fecha) = 2023 AND e.cubierto= 1 -- 1 = true
);



-- 8.Reportar para cada escenario, nombre del escenario y cantidad de recitales durante 2024.

SELECT e.nombre_escenario, COUNT(r.nroEscenario) AS cantidadRecitales2024
FROM escenario e 
INNER JOIN recital r ON e.nroEscenario = r.nroEscenario
WHERE  YEAR(r.fecha) = 2024 -- otra forma = WHERE r.fecha BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY e.nombre_escenario;



-- 9. Modificar el nombre de la banda ‘Mempis la Blusera’ a: ‘Memphis la Blusera’.

UPDATE banda SET nombreBanda = 'Memphis la Blusera' WHERE  nombreBanda = 'Mempis la Blusera';





