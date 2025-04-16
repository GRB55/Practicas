/*
El problema que nos ocupa es la asignación de horarios a profesores en una
escuela.
No vamos a resolverlo, sólo a construir desde SQL las herramientas de valoración
de una solución propuesta.
Tenemos:
1. Tabla de cursos: (IdCurso, horaDesde, horaHasta)
2. Tabla de asignaturas: (IdAsignatura, titulo)
3. Tabla de curricula (IdCurso, IdAsignatura, IdCarga)
4. Tabla de profesores (IdProfesor, Nombre)
5. Tabla de especialidades (IdProfesor, IdAsignatura)
6. Tabla de posibilidades (IdProfesor, DiaSemana, Desde, Hasta)
7. Tabla de soluciones (IdSolucion, IdProfesor, IdCurso, IdAsignatura, Desde,
Hasta)
Queremos:
1. Crear un procedimiento almacenado que indique cuantas horas tiene un
docente asignadas en una solución.
2. Crear un procedimiento almacenado que indique cuantas horas tiene una
asignatura asignada en una solución
3. Crear un procedimiento almacenado que indique las horas asignadas a un
docente que violan sus posibilidades en una solución.
4. Crear un procedimiento almacenado que indique las horas asignadas a un
curso que violen la currícula en una solución.
5. Crear un procedimiento almacenado que indique las horas asignadas a un
docente fuera de sus especialidades.
6. Crear un procedimiento almacenado que indique las horas libres de un curso
7. Crear una función que cuente la cantidad de horas con problemas en una
solución.
*/
CREATE TABLE cursos(
IdCurso INT PRIMARY KEY,
horaDesde TIME NOT NULL,
horaHasta TIME NOT NULL);

CREATE TABLE asignaturas(
IdAsignatura INT PRIMARY KEY,
titulo VARCHAR(50));

CREATE TABLE curricula(
IdCurso INT,
IdAsignatura INT,
IdCarga INT,
PRIMARY KEY (IdCurso, IdAsignatura),
FOREIGN KEY (IdAsignatura) REFERENCES asignaturas(IdAsignatura),
FOREIGN KEY (IdCurso) REFERENCES cursos(IdCurso));

CREATE TABLE profesores (
IdProfesor INT PRIMARY KEY,
Nombre VARCHAR(50));

CREATE TABLE especialidades(
IdProfesor INT,
IdAsignatura INT,
FOREIGN KEY (IdAsignatura) REFERENCES asignaturas(IdAsignatura),
FOREIGN KEY (IdProfesor) REFERENCES profesores(IdProfesor));

CREATE TABLE posibilidades(
IdProfesor INT,
DiaSemana VARCHAR(50) CHECK(DiaSemana IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')),
Desde TIME,
Hasta TIME,
FOREIGN KEY (IdProfesor) REFERENCES profesores(IdProfesor));

CREATE TABLE soluciones(
IdSolucion INT PRIMARY KEY,
IdProfesor INT,
IdCurso INT,
IdAsignatura INT,
Desde TIME,
Hasta TIME,
FOREIGN KEY (IdProfesor) REFERENCES profesores(IdProfesor),
FOREIGN KEY (IdCurso) REFERENCES cursos(IdCurso),
FOREIGN KEY (IdAsignatura) REFERENCES asignaturas(IdAsignatura));

-- Ejercicio 1
CREATE PROCEDURE sp_HorasAsignadas
@IdSolucion INT,
@IdProfesor INT
AS
BEGIN
	SELECT IdProfesor, SUM(DATEDIFF(HOUR, Desde, Hasta)) AS horas_asignadas
	FROM soluciones
	WHERE IdSolucion = @IdSolucion AND IdProfesor = @IdProfesor
	GROUP BY IdProfesor;
END;

-- Ejercicio 2
CREATE PROCEDURE sp_HorasAsignaturas
@IdSolucion INT,
@IdAsignatura INT
AS
BEGIN
	SELECT IdAsignatura, SUM(DATEDIFF(HOUR, Desde, Hasta)) AS horas_asignadas
	FROM soluciones
	WHERE IdSolucion = @IdSolucion AND IdAsignatura = @IdAsignatura
	GROUP BY IdAsignatura;
END;

-- Ejercicio 3
CREATE PROCEDURE HorasVioladas
@IdSolucion INT,
@IdProfesor INT
AS
BEGIN
	SELECT s.IdProfesor, SUM(DATEDIFF(HOUR, s.Desde, s.Hasta)) AS Horas_violadas
	FROM soluciones s
	JOIN posibilidades p
	ON s.IdProfesor = p.IdProfesor
	WHERE s.IdSolucion = @IdSolucion AND s.IdProfesor = @IdProfesor AND (s.Desde < p.Desde OR s.Hasta > p.Hasta)
	GROUP BY s.IdProfesor;
END;

-- Ejercicio 4
CREATE PROCEDURE HorasVioladas_curricula
@IdSolucion INT,
@IdCurso INT
AS
BEGIN
	SELECT s.IdCurso, SUM(DATEDIFF(HOUR, s.Desde, s.Hasta)) AS Horas_violadas
	FROM soluciones s
	JOIN curricula c
	ON s.IdAsignatura = c.IdAsignatura AND s.IdCurso = c.IdCurso
	WHERE s.IdSolucion = @IdSolucion AND s.IdCurso = @IdCurso
	GROUP BY s.IdCurso;
END;

-- Ejercicio 5
CREATE PROCEDURE HorasVioladas_especialidad
@IdSolucion INT,
@IdProfesor INT
AS
BEGIN
	SELECT s.IdProfesor, SUM(DATEDIFF(HOUR, s.Desde, s.Hasta)) AS Horas_violadas
	FROM soluciones s
	JOIN especialidades e
	ON s.IdProfesor = e.IdProfesor AND s.IdAsignatura = e.IdAsignatura
	WHERE s.IdSolucion = @IdSolucion AND s.IdProfesor = @IdProfesor
	GROUP BY s.IdProfesor;
END;

-- Ejercicio 6
CREATE PROCEDURE HorasLibres
@IdCurso INT
AS
BEGIN
	SELECT c.IdCurso, DATEDIFF(HOUR, c.horaDesde, c.horaHasta) - SUM(DATEDIFF(HOUR, s.Desde, s.Hasta)) AS Horas_Libres
	FROM cursos c
	JOIN soluciones s
	ON c.IdCurso = s.IdCurso
	WHERE c.IdCurso = @IdCurso
	GROUP BY c.IdCurso, c.horaDesde, c.horaHasta
END;

-- Ejercicio 7
CREATE FUNCTION HorasProblemas (@IdSolucion INT)
RETURNS INT
AS
BEGIN
 DECLARE @horasvioladas INT;

 SELECT @horasvioladas = SUM(DATEDIFF(HOUR, s.Desde, s.Hasta))
 FROM soluciones s
 JOIN posibilidades p
 ON s.IdProfesor = p.IdProfesor
 AND (s.Desde < p.Desde OR s.Hasta > p.Hasta)
 JOIN especialidades e
 ON s.IdProfesor = e.IdProfesor AND s.IdAsignatura = e.IdAsignatura
 JOIN curricula c
 ON s.IdCurso = c.IdCurso AND s.IdAsignatura = c.IdAsignatura
 WHERE s.IdSolucion = @IdSolucion ;

 RETURN @horasvioladas
END;



