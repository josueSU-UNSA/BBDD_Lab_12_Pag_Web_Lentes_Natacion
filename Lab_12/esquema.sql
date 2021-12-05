/*
CREAREMOS LAS TABLAS
*/
CREATE DATABASE tienda_natacion;
#DROP DATABASE tienda_natacion;
USE tienda_natacion;
CREATE TABLE persona(
	dni INT NOT NULL,
    nombres VARCHAR(30) NULL,
    p_apellido VARCHAR(30)NULL,
    s_apellido VARCHAR(30) NULL,
    direccion VARCHAR(30)NULL,
    telefono VARCHAR(30)NULL,
    usuario varchar(30) NULL, 
    contra VARCHAR(30) NOT NULL,
    PRIMARY KEY(dni)
);
CREATE TABLE cliente(
	dni INT,
	saldo DECIMAL(5,2) NOT NULL,
	foreign key(dni) references persona(dni),
    primary key(dni)
);
CREATE TABLE vendedor(
	dni INT,
	sueldo DECIMAL(5,2) NOT NULL,
	foreign key(dni) references persona(dni),
	primary key(dni)
);
CREATE TABLE lente(
	id_lente INT,
	descripcion VARCHAR(100) NOT NULL,
    precio DECIMAL(5,2) NOT NULL,
    marca VARCHAR(30) NOT NULL,
    stock INT NOT NULL,
	primary key(id_lente)
);
CREATE TABLE compra(
	id_compra INT AUTO_INCREMENT,
    id_lente INT,
    dni_cliente INT,
    dni_vendedor INT,
	cantidad INT NOT NULL,
	foreign key(id_lente) references lente(id_lente),
    foreign key(dni_cliente) references persona(dni),
    foreign key(dni_vendedor) references persona(dni),
	primary key(id_compra)
);

/*
INSERCION DE DATOS EN LAS TABLAS
*/
DESCRIBE persona;
INSERT INTO persona 
VALUES(123,'Diego','Rios','Valdivia','Av. Venezuela','765432190','asd@gmail.com','123');
INSERT INTO persona 
VALUES(124,'Diego','Risa','Balde','Av. Peru','76543219','asde@gmail.com','121');
SELECT* FROM persona;

/*Insertando cliente dni ,saldo, */
DESCRIBE cliente;
INSERT INTO cliente
VALUES(123,350.00);
SELECT* FROM cliente;

/*Insertando vendedor dni, sueldo */
DESCRIBE vendedor;
INSERT INTO vendedor
VALUES(124,500.00);
SELECT* FROM  vendedor;

/*Insertando lente id_lente, descripcion, precio, marca, stock */
DESCRIBE lente;
INSERT INTO lente
VALUES(1,'rojo oscuro',40.00,'NIKE',500);
INSERT INTO lente
VALUES(2,'verde claro',30.00,'ADIDAS',300);
SELECT* FROM lente;

/*Insertando compra id_compra ,id_lente ,dni_cliente ,dni_vendedor ,cantidad */
DESCRIBE compra;
INSERT INTO compra VALUES(NULL,1,123,124,3);
INSERT INTO compra VALUES(NULL,1,123,124,5);
SELECT* FROM compra;

/*
STORES PROCEDURE
*/

USE tienda_natacion;

/*Dar el dni de un cliente y obtener los lentes que compro el cliente*/
USE tienda_natacion;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE obtenerLente(
IN n_dni_cliente integer)
begin
	SELECT pe.nombres, pe.dni, pe.usuario,co.id_compra,co.cantidad,le.id_lente,le.descripcion
    FROM cliente c INNER JOIN
    Persona pe ON pe.dni = c.dni AND n_dni_cliente = c.dni
    INNER JOIN compra co 
    INNER JOIN lente le
    WHERE co.dni_cliente = n_dni_cliente AND co.id_lente = le.id_lente;
end$$
DELIMITER ;
    
USE tienda_natacion;
CALL obtenerLente(123);

/* Damos un dni y verifica si es cliente*/

USE tienda_natacion;
DELIMITER $$
create definer=`root`@`localhost` function esCliente(
DNI INT)RETURNS INT DETERMINISTIC
begin
    DECLARE bandera BOOL;
    DECLARE aux INT;
    
    SET bandera = (SELECT COUNT(c.dni) FROM cliente c 
        INNER JOIN  persona p WHERE c.dni = DNI AND p.dni = c.dni
        GROUP BY c.dni);
    IF bandera THEN
       SET aux = 1;
	ELSE
       SET aux = 0;
     END IF;
    
    RETURN aux;
end$$
DELIMITER ;

#DROP FUNCTION esCliente;
USE tienda_natacion;
SELECT escliente(222);

/* Le doy correo y me devuelve  dni*/

/* Damos un correo y validamos */

USE tienda_natacion;
#DROP PROCEDURE validarLogin;
DELIMITER $$
create definer=`root`@`localhost` procedure validarLogin(
IN n_usuario varchar(30))
begin
    SELECT p.dni dni, p.nombres nombres, p.p_apellido, p.s_apellido, 
           p.direccion direccion,p.telefono telefono, p.usuario usuario,
           p.contra contra, esCliente(p.dni) sies
	FROM persona p INNER JOIN cliente c
    ON p.usuario = n_usuario;
    
end$$
DELIMITER ;
#DROP PROCEDURE validarLogin;
USE tienda_natacion;
SELECT* FROM persona;
SELECT* FROM cliente;
SELECT* FROM vendedor;
CALL validarLogin('asd@gmail.com');


/*Crea un persona*/
USE tienda_natacion;
DELIMITER $$
create definer=`root`@`localhost` procedure crearPersona(
IN n_dni integer,
IN n_nombre varchar(30),
IN n_p_apellido varchar(30),
IN n_s_apellido varchar(30),
IN n_direccion varchar(30),
IN n_telefono varchar(30),
IN n_usuario varchar(30),
IN n_contra varchar(30),
IN n_sies  VARCHAR(4))#Si es  cliente o no
begin
	if (select exists (select 1 from persona where usuario = n_usuario)) then
		select 'Usuario ya existe!!';
	else
        insert into persona 
		values (n_dni, n_nombre, n_p_apellido, n_s_apellido, n_direccion, n_telefono, n_usuario, n_contra);
        if n_sies = "si" THEN
            insert into cliente values(n_dni,600.00);
		else
            insert into vendedor values(n_dni,800.00);
        end if;
    end if;
end$$
DELIMITER ;

USE tienda_natacion;
SELECT* FROM persona;
SELECT* FROM cliente;
SELECT* FROM vendedor;
CALL crearPersona(222,'Juan','Perez','Rios','Av.malavida','456732','pepe@gmail.com','982','si');

/*Agregamos una compra para un usuario(cliente)*/
#drop procedure agregarCompra;
USE tienda_natacion;
DELIMITER $$
create definer=`root`@`localhost` procedure agregarCompra(
IN n_id_lente INT,
IN n_titulo varchar(30),#marca
IN n_descripcion varchar(30),
IN n_dni_cliente integer)
begin
	/*insert into lente (id_lente, descripcion,precio, marca, stock)
	values (n_id_lente, n_descripcion,20.00, n_titulo,100);*/
    
    insert into compra(id_lente ,dni_cliente ,dni_vendedor, cantidad)
    values(n_id_lente,n_dni_cliente,124,3);
    
end$$
DELIMITER ;

/*Obtener compra*/
#DROP PROCEDURE obtenerCompra;
USE tienda_natacion;#
DELIMITER $$
create definer=`root`@`localhost` procedure obtenerCompra(
IN n_dni_cliente integer)
begin
	select l.id_lente id,l.marca marca,l.descripcion descripcion,l.precio precio,c.cantidad cantidad
    from compra c inner join lente l 
    on c.id_lente = l.id_lente;
end$$
DELIMITER ;

CALL obtenerCompra(123);

/*Agregar producto lente*/
#DROP PROCEDURE obtenerCompra;
use tienda_natacion;
DELIMITER $$
create definer=`root`@`localhost` procedure agregarProducto(
IN n_id_lente INT,
IN n_titulo varchar(30),#marca
IN n_descripcion varchar(30),
IN n_dni_cliente integer)
begin
	insert into lente (id_lente, descripcion,precio, marca, stock)
	values (n_id_lente, n_descripcion,20.00, n_titulo,100);
    
end$$
DELIMITER ;

USE tienda_natacion;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE obtenerProducto(
)
begin
	SELECT * FROM lente;
end$$
DELIMITER ;

USE tienda_natacion;
CALL obtenerCompra(123);

use tienda_natacion;
SELECT* FROM persona;
SELECT* FROM cliente;
SELECT* FROM vendedor;
SELECT* FROM compra;
SELECT* FROM lente;