/*
Tenemos la base de datos del sistema de gestión de alumnos.
Cuenta con las siguientes tablas:
Alumnos (IdAlumno, Nombre)
Asignaturas (IdAsignatura, Nombre)
Notas (IdAsignatura, IdAlumno, Fecha, Nota)
Carreras (IdCarrera)
AsignaturasxCarrera (IdAsignatura, IdCarrera)
1. Cree las tablas poniendo a cada tabla una clave primaria que le parezca
adecuada
2. Cree un procedimiento almacenado que permita obtener todas las materias
aprobadas por un alumno de una carrera (Los Ids del alumno y la carrera se
pasarán como parámetros)
3. Cree un procedimiento almacenado que permita obtener el listado de alumnos
que aprobaron una asignatura. (El Id de la asignatura se pasará como parámetro)
(Asuma que las asignaturas se aprueban con 4)
4. Cree una función que devuelva la nota máxima obtenida por un alumno en una
asignatura (Los Ids de alumno y asignatura se pasarán por parámetro)
5. Cree un procedimiento almacenado que devuelva todos los alumnos que han
completado una carrera satisfactoriamente. (El IdCarrera se pasará como
parámetro)
6. Modifique la función creada en el punto 4 agregando una fecha como parámetro
y obtenga la nota máxima que había sacado un alumno en una asignatura antes
de esa fecha (El Id del Alumno y de la asignatura se pasarán como parámetro)
7. Modifque el procedimiento almacenado creado en el punto 5 para que incluya
como parámetro una fecha de manera de devolver todos los recibidos en una
carrera a una fecha dada.
8. Modifique el procedimiento creado en el punto 7 para que se indiquen dos
fechas y liste así los alumnos que se recibieron de una carrera entre esas dos
fechas.
*/
-- Ejercicio 1
CREATE TABLE Alumnos (
id INT PRIMARY KEY,
Nombre VARCHAR(50));

CREATE TABLE Asignaturas(
id INT PRIMARY KEY,
Nombre VARCHAR(50));

CREATE TABLE Notas (
IdAsignatura INT,
IdAlumno INT,
FOREIGN KEY (IdAsignatura) REFERENCES Asignaturas(id),
FOREIGN KEY (IdAlumno) REFERENCES Alumnos(id),
Fecha DATE,
Nota INT);

CREATE TABLE Carreras (
id INT PRIMARY KEY);

CREATE TABLE AsignaturasxCarrera (
IdAsignatura INT,
IdCarrera INT,
FOREIGN KEY (IdAsignatura) REFERENCES Asignaturas(id),
FOREIGN KEY (IdCarrera) REFERENCES Carreras(id)
);

-- Ejercicio 2
CREATE PROCEDURE materias_aprobadas
@idalumno INT,
@idcarrera INT,
@notaminima DECIMAL(7, 2)
AS
BEGIN
	SELECT al.id, al.Nombre, c.id, asi.Nombre, nt.Nota
	FROM Alumnos al
	JOIN Notas nt
	ON al.id = nt.IdAlumno
	JOIN Asignaturas asi
	ON nt.IdAsignatura = asi.id
	JOIN AsignaturasxCarrera asic
	ON asi.id = asic.IdAsignatura
	JOIN Carreras c
	ON asic.IdCarrera = c.id
	WHERE al.id = @idalumno AND c.id = @idcarrera AND nt.Nota >= @notaminima
END;

-- Ejercicio 3
CREATE PROCEDURE alumnos_aprobados
@idasignatura INT,
@notaminima DECIMAL(4, 2)
AS
BEGIN
	SELECT al.id, al.Nombre, asi.Nombre
	FROM Alumnos al
	JOIN Notas nt
	ON al.id = nt.IdAlumno
	JOIN Asignaturas asi
	ON nt.IdAsignatura = asi.id
	WHERE asi.id = @idasignatura
	AND nt.Nota >= @notaminima
END;

-- Ejercicio 4
CREATE FUNCTION nota_maxima (@idalumno INT, @idasignatura INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
	DECLARE @notamaxima DECIMAL(5, 2)

	SELECT @notamaxima = MAX(Nota)
	FROM Notas
	WHERE IdAlumno = @idalumno AND IdAsignatura = @idasignatura;

	RETURN @notamaxima;
END;

-- Ejercicio 5
CREATE PROCEDURE recibidos
@idcarrera INT
AS
BEGIN
	DECLARE @nota_minima INT = 4;

	SELECT DISTINCT a.id, a.Nombre
	FROM Alumnos a
	JOIN Notas n
	ON a.id = n.IdAlumno
	JOIN AsignaturasxCarrera asic
	ON n.IdAsignatura = asic.IdAsignatura
	WHERE asic.IdCarrera = @idcarrera
	GROUP BY a.id, a.Nombre
	HAVING COUNT(CASE WHEN n.Nota >= @nota_minima THEN 1 ELSE NULL END) = (SELECT COUNT(*) FROM AsignaturasxCarrera WHERE IdCarrera = @idcarrera)
END;

-- Ejercicio 6
CREATE FUNCTION nota_maxima_fecha (@idalumno INT, @idasignatura INT, @fecha DATE)
RETURNS DECIMAL(5, 2)
AS
BEGIN
	DECLARE @notamaxima DECIMAL(5, 2)

	SELECT @notamaxima = MAX(Nota)
	FROM Notas
	WHERE IdAlumno = @idalumno AND IdAsignatura = @idasignatura AND Fecha < @fecha;

	RETURN @notamaxima;
END;

-- Ejercicio 7
CREATE PROCEDURE recibidos
@idcarrera INT,
@fecha DATE
AS
BEGIN
	DECLARE @nota_minima INT = 4;

	SELECT DISTINCT a.id, a.Nombre
	FROM Alumnos a
	JOIN Notas n
	ON a.id = n.IdAlumno
	JOIN AsignaturasxCarrera asic
	ON n.IdAsignatura = asic.IdAsignatura
	WHERE asic.IdCarrera = @idcarrera AND n.Fecha <= @fecha
	GROUP BY a.id, a.Nombre
	HAVING COUNT(CASE WHEN n.Nota >= @nota_minima THEN 1 ELSE NULL END) = (SELECT COUNT(*) FROM AsignaturasxCarrera WHERE IdCarrera = @idcarrera)
END;
-- Ejercicio 8
CREATE PROCEDURE recibidos
@idcarrera INT,
@fecha1 DATE,
@fecha2 DATE
AS
BEGIN
	DECLARE @nota_minima INT = 4;

	SELECT DISTINCT a.id, a.Nombre
	FROM Alumnos a
	JOIN Notas n
	ON a.id = n.IdAlumno
	JOIN AsignaturasxCarrera asic
	ON n.IdAsignatura = asic.IdAsignatura
	WHERE asic.IdCarrera = @idcarrera AND n.Fecha BETWEEN @fecha1 AND @fecha2
	GROUP BY a.id, a.Nombre
	HAVING COUNT(CASE WHEN n.Nota >= @nota_minima THEN 1 ELSE NULL END) = 
	(SELECT COUNT(*) FROM AsignaturasxCarrera WHERE IdCarrera = @idcarrera)
END;