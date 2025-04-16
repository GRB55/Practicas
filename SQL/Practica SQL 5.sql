/*
Queremos gestionar un campeonato de Fórmula 1.
Tenemos las siguientes tablas:
1. Circuitos (IdCircuito, Nombre)
2. Corredores (IdCorreder, Nombre)
3. Carreras (IdCarrera, IdCircuito, Fecha)
4. Posiciones(IdCarrera, IdCorredor, Posicion)
5. Puntuaciones (Posicion, Puntos)
6. Campeonatos (IdCampeonato, Inicio, Fin)

Queremos:
1. Crear un procedimiento almacenado que liste las posiciones obtenidas por un
corredor (el Id del corredor se pasa como parámetro)
2. Modificar el procedimiento almacenado de 1 para que tome sólo las carreras
entre dos fechas que se pasarán también como parámetros.
3. Crear una función para calcular los puntos ganados por un corredor (El
IdCorredor se pasa como parámetro)
4. Modificar la función hecha en 3 para que se limite a los puntos obtenidos entre
dos fechas que se pasarán como parámetros
5. Modificar el procedimiento hecho en 2 para que se tomen en consideración sólo
las carreras de un campeonato (el IdCampeonato se pasará en lugar de las
fechas)
6. Modificar la función hecha en 4 para que se tomen en consideración los puntos
obtenidos en un campeonato.
7. Crear un procedimiento almacenado que liste las posiciones de un campeonato.
(El IdCampeonato se pasa como parámetro)
8. Crear un procedimiento almacenado que liste el podio de un campeonato (3
primeras posiciones, el IdCampeonato se pasa como parámetro)
9. Cree un procedimiento almacenado con la lista de los campeones de todos los
campeonatos.
10. Modifique el procedimiento creado en 9 para que incluya a todo el podio.
*/
CREATE TABLE Circuitos (
IdCircuito INT PRIMARY KEY,
Nombre VARCHAR(50));

CREATE TABLE Corredores(
IdCorredor INT PRIMARY KEY, 
Nombre VARCHAR(50));

CREATE TABLE Carreras(
IdCarrera INT PRIMARY KEY,
IdCircuito INT NOT NULL,
Fecha DATE NOT NULL,
FOREIGN KEY (IdCircuito) REFERENCES Circuitos(IdCircuito));

CREATE TABLE Posiciones(
Posicion INT NOT NULL,
IdCarrera INT NOT NULL,
IdCorredor INT NOT NULL,
PRIMARY KEY (IdCarrera, IdCorredor),
FOREIGN KEY (IdCarrera) REFERENCES Carreras(IdCarrera),
FOREIGN KEY (IdCorredor) REFERENCES Corredores(IdCorredor));

CREATE TABLE Puntuaciones(
Posicion INT,
Puntos DECIMAL(5, 2) NOT NULL);

CREATE TABLE Campeonatos(
IdCampeonato INT PRIMARY KEY,
Fecha_inicio DATE NOT NULL,
Fecha_fin DATE NOT NULL);

-- Ejercicio 1
CREATE PROCEDURE posiciones_corredor
@idcorredor INT
AS
BEGIN
	SELECT IdCorredor, Posicion
	FROM Posiciones
	WHERE IdCorredor = @idcorredor
END;

-- Ejercicio 2
CREATE PROCEDURE posiciones_corredor_fecha
@idcorredor INT,
@fecha_inicial DATE,
@fecha_final DATE
AS
BEGIN
	SELECT p.IdCorredor, p.Posicion
	FROM Posiciones p
	JOIN Carreras c
	ON p.IdCarrera = c.IdCarrera
	WHERE p.IdCorredor = @idcorredor AND c.Fecha BETWEEN @fecha_inicial AND @fecha_final
END;

-- Ejercicio 3
CREATE FUNCTION puntos_ganados (@idcorredor INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
	DECLARE @total_puntos DECIMAL(5, 2)

	SELECT @total_puntos = SUM(p.Puntos)
	FROM Puntuaciones p
	JOIN Posiciones po
	ON p.Posicion = po.Posicion
	WHERE po.IdCorredor = @idcorredor;

	RETURN @total_puntos;
END;

-- Ejercicio 4
CREATE FUNCTION puntos_ganados_fecha (@idcorredor INT, @fecha_inicial DATE, @fecha_final DATE)
RETURNS DECIMAL(5, 2)
AS
BEGIN
	DECLARE @total_puntos DECIMAL(5, 2)

	SELECT @total_puntos = SUM(p.Puntos)
	FROM Puntuaciones p
	JOIN Posiciones po
	ON p.Posicion = po.Posicion
	JOIN Carreras c
	ON po.IdCarrera = c.IdCarrera
	WHERE po.IdCorredor = @idcorredor AND c.Fecha BETWEEN @fecha_inicial AND @fecha_final;

	RETURN @total_puntos;
END;

-- Ejercicio 5
ALTER TABLE Carreras
ADD IdCampeonato INT NOT NULL;

ALTER TABLE Carreras
ADD CONSTRAINT fk_campeonato FOREIGN KEY (IdCampeonato) REFERENCES Campeonatos (IdCampeonato);

CREATE PROCEDURE posiciones_corredor_campeonato
@idcorredor INT,
@idcampeonato INT
AS
BEGIN
	SELECT p.IdCorredor, p.Posicion, cam.IdCampeonato
	FROM Posiciones p
	JOIN Carreras car
	ON p.IdCarrera = car.IdCarrera
	JOIN Campeonatos cam
	ON car.IdCampeonato = cam.IdCampeonato
	WHERE p.IdCorredor = @idcorredor AND cam.IdCampeonato = @idcampeonato
END;

-- Ejercicio 6
CREATE FUNCTION puntos_ganados_campeonato (@idcorredor INT, @idcampeonato INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
	DECLARE @total_puntos DECIMAL(5, 2)

	SELECT @total_puntos = SUM(p.Puntos)
	FROM Puntuaciones p
	JOIN Posiciones po
	ON p.Posicion = po.Posicion
	JOIN Carreras c
	ON po.IdCarrera = c.IdCarrera
	WHERE po.IdCorredor = @idcorredor AND c.IdCampeonato = @idcampeonato;

	RETURN @total_puntos;
END;

-- Ejercicio 7
CREATE PROCEDURE posicones_campeonato
@idcampeonato INT
AS
BEGIN
	SELECT p.IdCorredor, p.Posicion
	FROM Carreras c
	JOIN Posiciones p
	ON c.IdCarrera = p.IdCarrera
	JOIN Campeonatos ca
	ON c.IdCampeonato = ca.IdCampeonato
	WHERE c.IdCampeonato = @idcampeonato
	ORDER BY c.IdCampeonato
END;

-- Ejercicio 8
CREATE PROCEDURE podio_campeonato
@idcampeonato INT
AS
BEGIN
	SELECT TOP 3 p.IdCorredor, p.Posicion
	FROM Carreras c
	JOIN Posiciones p
	ON c.IdCarrera = p.IdCarrera
	JOIN Campeonatos ca
	ON c.IdCampeonato = ca.IdCampeonato
	WHERE c.IdCampeonato = @idcampeonato
	ORDER BY c.IdCampeonato
END;

-- Ejercicio 9
CREATE PROCEDURE campeones
AS
BEGIN
	WITH suma_puntos AS(
	SELECT c.IdCorredor, c.Nombre, ca.IdCampeonato, SUM(pu.Puntos) AS total_puntos
	FROM Puntuaciones pu
	JOIN Posiciones p
	ON pu.Posicion = p.Posicion
	JOIN Corredores c
	ON p.IdCorredor = c.IdCorredor
	JOIN Carreras ca
	ON p.IdCarrera = ca.IdCarrera
	GROUP BY c.IdCorredor, c.Nombre, ca.IdCampeonato)

	SELECT IdCampeonato, IdCorredor, Nombre, total_puntos AS ganador
	FROM suma_puntos
	WHERE total_puntos IN (
							SELECT MAX(total_puntos) 
							FROM suma_puntos sp
							WHERE sp.IdCampeonato = suma_puntos.IdCampeonato
							GROUP BY IdCampeonato)
	ORDER BY IdCampeonato;
END;

-- Ejercicio 10
CREATE PROCEDURE podio
AS
BEGIN
	WITH puntos_campeonato AS(
	SELECT c.IdCorredor, c.Nombre, ca.IdCampeonato, SUM(pu.Puntos) AS total_puntos
	FROM Puntuaciones pu
	JOIN Posiciones p
	ON pu.Posicion = p.Posicion
	JOIN Corredores c
	ON p.IdCorredor = c.IdCorredor
	JOIN Carreras ca
	ON p.IdCarrera = ca.IdCarrera
	GROUP BY c.IdCorredor, c.Nombre, ca.IdCampeonato
), Podio AS (
SELECT IdCampeonato, IdCorredor, Nombre, total_puntos,
		RANK() OVER (PARTITION BY IdCampeonato ORDER BY total_puntos DESC) AS Posicion_camp
FROM puntos_campeonato)

SELECT IdCampeonato, IdCorredor, Nombre, total_puntos, Posicion_camp
FROM Podio
WHERE Posicion_camp <= 3
ORDER BY IdCampeonato, Posicion_camp;
END;