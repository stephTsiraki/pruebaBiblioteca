--Crear DB--
CREATE DATABASE biblioteca;

--Conectarme a DB--
\c biblioteca

--Crear tablas--
BEGIN;
CREATE TABLE socios
(
    rut VARCHAR(20),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (rut)
);
COMMIT;

BEGIN;
CREATE TABLE autores
(
    codigo_autor serial, 
    nombre_autor VARCHAR(100) NOT NULL,
    apellido_autor VARCHAR(100) NOT NULL,
    anio_nacimiento integer NOT NULL,
    anio_muerte integer,
    PRIMARY KEY (codigo_autor)
);
COMMIT;

BEGIN;
CREATE TABLE libros
(
    isbn bigint,
    paginas integer NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    PRIMARY KEY (isbn)
);
COMMIT;

BEGIN;
CREATE TABLE libros_autores
(
    isbn bigint NOT NULL,
    codigo_autor serial NOT NULL,
    tipo_autor VARCHAR(50) NOT NULL,
    PRIMARY KEY (codigo_autor),
    FOREIGN KEY (isbn) REFERENCES libros (isbn),
    FOREIGN KEY (codigo_autor) REFERENCES autores (codigo_autor) 

);
COMMIT;

BEGIN;
CREATE TABLE prestamos
(
    id_prestamo bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_dev_esp date NOT NULL,
    fecha_dev_real date,
    rut_socio VARCHAR(20) NOT NULL,
    isbn_libro bigint NOT NULL,
    PRIMARY KEY (id_prestamo),
    FOREIGN KEY (rut_socio) REFERENCES socios (rut),
    FOREIGN KEY (isbn_libro) REFERENCES libros (isbn)
);
COMMIT;


--Insertar registros--
BEGIN;
INSERT INTO socios (rut, nombre, apellido, direccion, telefono) VALUES ('1111111-1','JUAN','SOTO','AVENIDA 1, SANTIAGO ','911111111'),('2222222-2','ANA','PEREZ','PASAJE 2, SANTIAGO ','922222222'),('3333333-3','SANDRA','AGUILAR','AVENIDA 2, SANTIAGO','933333333'),('4444444-4','ESTEBAN','JEREZ','AVENIDA 3, SANTIAGO','944444444'),('5555555-5','SILVANA','MUNOZ','PASAJE 3, SANTIAGO ','955555555');
COMMIT;

BEGIN;
INSERT INTO autores (codigo_autor, nombre_autor, apellido_autor, anio_nacimiento) VALUES ( 1, 'ANDRES', 'ULLOA', 1982);
INSERT INTO autores (codigo_autor, nombre_autor, apellido_autor, anio_nacimiento, anio_muerte) VALUES ( 2, 'SERGIO', 'MARDONES', 1950 , 2012),( 3, 'JOSE', 'SALGADO', 1968, 2020);
INSERT INTO autores (codigo_autor, nombre_autor, apellido_autor, anio_nacimiento) VALUES ( 4, 'ANA', 'SALGADO', 1972),(5, 'MARTIN', 'PORTA', 1976);
COMMIT;

BEGIN;
INSERT INTO libros (isbn, paginas, titulo) VALUES (1111111111111, 344, 'CUENTOS DE TERROR'),(2222222222222, 167, 'POESIAS CONTEMPORANEAS'),(3333333333333, 511, 'HISTORIA DE ASIA'),(4444444444444, 298 ,'MANUAL DE MECANICA');
COMMIT;

BEGIN;
INSERT INTO libros_autores (isbn, codigo_autor, tipo_autor) VALUES (2222222222222, 1, 'PRINCIPAL'),(3333333333333, 2, 'PRINCIPAL'),(1111111111111, 3, 'PRINCIPAL'),(1111111111111, 4, 'COAUTOR'),(4444444444444, 5, 'PRINCIPAL');
COMMIT;

BEGIN;
INSERT INTO prestamos (id_prestamo, fecha_inicio, fecha_dev_esp, fecha_dev_real, rut_socio, isbn_libro) VALUES ( 1, '2020-01-20', '2020-01-27', '2020-01-27', '1111111-1', 1111111111111), ( 2, '2020-01-20', '2020-01-27', '2020-01-30', '5555555-5', 2222222222222),( 3, '2020-01-22', '2020-01-29', '2020-01-30', '3333333-3', 3333333333333),( 4, '2020-01-23', '2020-01-30', '2020-01-30', '4444444-4', 4444444444444),( 5, '2020-01-27', '2020-02-03', '2020-02-04', '2222222-2', 1111111111111),( 6, '2020-01-31', '2020-02-07', '2020-02-12', '1111111-1', 4444444444444),( 7, '2020-01-31', '2020-02-07', '2020-02-12', '3333333-3', 2222222222222);
COMMIT;


--Consultas--
--Mostrar todos los libros que posean menos de 300 páginas--
BEGIN;
SELECT titulo, isbn FROM libros WHERE paginas<300;
COMMIT;


-- Mostrar todos los autores que hayan nacido después del 01-01-1970--
BEGIN;
SELECT nombre_autor, apellido_autor, anio_nacimiento FROM autores WHERE anio_nacimiento >= 1970;
COMMIT;


--¿Cuál es el libro más solicitado?--
--Puede entenderse solicitud como numero de veces solicitado o, como numero de dias prestados--
--Lo entendere como numero de prestamos. Aunque es posible que dos libros o más, puedan tener el mismo numero de prestamos-
BEGIN;
SELECT titulo, COUNT(isbn_libro ) AS numero_prestamos FROM prestamos INNER JOIN libros ON libros.isbn=prestamos.isbn_libro GROUP BY libros.titulo ORDER BY(numero_prestamos) DESC LIMIT 1;
COMMIT;

--Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días--
BEGIN;
SELECT nombre, apellido, (100*(fecha_dev_real - fecha_dev_esp)) AS multa_atraso, id_prestamo FROM prestamos FULL OUTER JOIN socios ON prestamos.rut_socio=socios.rut;
COMMIT;
--Podemos notar que se repiten usuarios con multas, ya que en distintos prestamos excedieron los días permitidos--
--Alternativamente, mostrare las multas agregadas(el total) por cada usuario independiente del id_prestamo.--
BEGIN;
SELECT CONCAT( nombre,' ', apellido) AS nombre_completo, SUM(100*(fecha_dev_real - fecha_dev_esp)) AS multa_total FROM socios FULL OUTER JOIN prestamos ON prestamos.rut_socio=socios.rut GROUP BY nombre_completo;
COMMIT;