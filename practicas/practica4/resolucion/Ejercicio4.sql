

-- 1. Listar DNI, legajo y apellido y nombre de todos los alumnos que tengan año de ingreso inferior a 2014.

SELECT a.DNI,a.Legajo, p.Apellido ,p.Nombre
FROM alumno a 
INNER JOIN persona p ON a.DNI =  p.DNI
WHERE a.Anio_Ingreso < 2014;


-- 2.Listar DNI, matrícula, apellido y nombre de los profesores que dictan cursos que tengan más de
-- 100 horas de duración. 
-- Ordenar por DNI.

SELECT DISTINCT p.DNI, p.Matricula, per.Apellido, per.Nombre
FROM profesor p 
INNER JOIN persona per ON p.DNI = per.DNI
INNER JOIN profesor_curso pc ON pc.DNI = p.DNI
INNER JOIN curso c ON pc.Cod_Curso = c.Cod_Curso
WHERE c.Duracion > 100
ORDER BY p.DNI;



-- 3.Listar el DNI, Apellido, Nombre, Género y Fecha de nacimiento de los alumnos inscriptos al
-- curso con nombre “Diseño de Bases de Datos” en 2023.

SELECT p.DNI,p.Apellido,p.Nombre,p.Genero,p.Fecha_Nacimiento
FROM persona p
INNER JOIN alumno a ON p.DNI = a.DNI
INNER JOIN alumno_curso ac ON a.DNI = ac.DNI
INNER JOIN curso c ON ac.Cod_Curso= c.Cod_Curso
WHERE c.Nombre= 'Diseño de Bases de Datos' AND ac.Anio = 2023;


-- 4. Listar el DNI, Apellido, Nombre y Calificación de aquellos alumnos que obtuvieron una
-- calificación superior a 8 en algún curso que dicta el profesor “Juan Garcia”. Dicho listado deberá estar ordenado por Apellido y nombre

SELECT a.DNI,p.Apellido,p.Nombre, ac.Calificacion
FROM alumno a 
INNER JOIN persona p ON a.DNI = p.DNI
INNER JOIN alumno_curso ac ON p.DNI = ac.DNI
WHERE ac.Calificacion > 8 
AND EXISTS(
    SELECT 1
    FROM persona pe 
    INNER JOIN profesor_curso pc ON pe.DNI= pc.DNI
    WHERE pc.Cod_Curso = ac.Cod_Curso
    AND pe.Nombre='Juan' AND pe.Apellido='Garcia'
)
ORDER BY p.Nombre , p.Apellido;



-- 5. Listar el DNI, Apellido, Nombre y Matrícula de aquellos profesores que posean más de 3 títulos.
-- Dicho listado deberá estar ordenado por Apellido y Nombre.

SELECT p.DNI, per.Apellido, per.Nombre ,p.Matricula
FROM profesor p 
INNER JOIN persona per ON p.DNI = per.DNI
INNER JOIN titulo_profesor tp ON per.DNI = tp.DNI
GROUP BY p.DNI,per.Apellido,per.Nombre,p.Matricula
HAVING COUNT(tp.Cod_Titulo) > 3 
ORDER BY per.Apellido,per.Nombre;



-- 6. Listar el DNI, Apellido, Nombre, Cantidad de horas y Promedio de horas que dicta cada profesor.
-- La cantidad de horas se calcula como la suma de la duración de todos los cursos que dicta.

SELECT pro.DNI , p.Apellido,p.Nombre, SUM(c.Duracion) AS cantidadHoras , AVG(c.Duracion) AS promedioDeHoras
FROM profesor pro
INNER JOIN persona p ON pro.DNI = p.DNI
INNER JOIN profesor_curso pc ON pro.DNI = pc.DNI
INNER JOIN curso c ON pc.Cod_Curso = c.Cod_Curso
GROUP BY pro.DNI,p.Apellido,p.Nombre;


-- 7. Listar Nombre y Descripción del curso que posea más alumnos inscriptos y del que posea
-- menos alumnos inscriptos durante 2024.

SELECT c.Nombre, c.Descripcion
FROM curso c
INNER JOIN alumno_curso ac ON c.Cod_Curso = ac.Cod_Curso
WHERE ac.Anio = 2024
GROUP BY ac.Cod_Curso,c.Nombre,c.Descripcion
HAVING COUNT(ac.DNI) = ( -- compara la cantidad de alumnos por curso con la cantidad mínima de subconsulta
    SELECT MIN(cantidad)  -- se queda con la cantidad mínima de alumnos de los grupo de cursos.
    FROM(
      SELECT COUNT(ac.DNI) AS cantidad -- agrupa cada curso del 2024 con cantidad de alumnos
      FROM alumno_curso ac
      WHERE ac.Anio = 2024
      GROUP BY ac.Cod_Curso
    ) t1 -- es necesario asignar alias a from (tabla temporal de subconsulta)
)

UNION

SELECT c.Nombre, c.Descripcion
FROM curso c
INNER JOIN alumno_curso ac ON c.Cod_Curso = ac.Cod_Curso
WHERE ac.Anio = 2024
GROUP BY ac.Cod_Curso,c.Nombre,c.Descripcion
HAVING COUNT(ac.DNI) = ( -- compara la cantidad de alumnos por curso con la cantidad maxima de subconsulta
    SELECT MAX(cantidad) -- se queda con la cantidad maxima de alumnos de los grupo de cursos.
    FROM(
      SELECT COUNT(ac.DNI) AS cantidad -- agrupa cada curso del 2024 con cantidad de alumnos
      FROM alumno_curso ac
      WHERE ac.Anio = 2024
      GROUP BY ac.Cod_Curso
    ) t2 -- es necesario asignar alias al from (tabla temporal de subconsulta)
);



-- 8. Listar el DNI, Apellido, Nombre y Legajo de alumnos que realizaron cursos con nombre
-- conteniendo el string ‘BD’ durante 2022 pero no realizaron ningún curso durante 2023.

SELECT p.DNI,p.Apellido,p.Nombre,a.Legajo
FROM alumno a
INNER JOIN persona p ON a.DNI = p.DNI
WHERE EXISTS (
    SELECT 1
    FROM alumno_curso ac 
    INNER JOIN curso c ON ac.Cod_Curso = c.Cod_Curso
    WHERE a.DNI = ac.DNI
    AND ac.Anio = 2022
    AND c.Nombre LIKE '%BD%'
)
AND NOT EXISTS(
 SELECT 1
    FROM alumno_curso ac 
    INNER JOIN curso c ON ac.Cod_Curso= c.Cod_Curso
    WHERE a.DNI = ac.DNI
    AND ac.Anio = 2023
);



-- 9.Agregar un profesor con los datos que prefiera y agregarle el título con código: 25.

INSERT INTO Persona (DNI, Apellido, Nombre, Fecha_Nacimiento, Estado_Civil, Genero)
VALUES (27888555, 'Alonso', 'Carla', '1995-05-10', 'Soltero', 'Femenino');

INSERT INTO Profesor (DNI, Matricula, Nro_Expediente)
VALUES (27888555, 1005, 5005);

INSERT INTO Titulo_Profesor (Cod_Titulo, DNI, Fecha)
VALUES (25, 27888555, '2009-10-21');


-- 10. Modificar el estado civil del alumno cuyo legajo es ‘2020/09’, el nuevo estado civil es divorciado. 

UPDATE persona p
INNER JOIN alumno a ON p.DNI = a.DNI
SET p.Estado_Civil = 'Divorciado'
WHERE a.Legajo = '2020/09';



-- 11.Dar de baja el alumno con DNI 30568989. 
-- Realizar todas las bajas necesarias para no dejar el conjunto de relaciones en un estado inconsistente.

DELETE FROM alumno_curso -- 1) dni fk
WHERE DNI = 30568989;

DELETE FROM alumno -- 2) dni fk
WHERE DNI = 30568989;

DELETE FROM persona -- 3) dni pk
WHERE DNI = 30568989;







