CREATE DATABASE MOBI CHARACTER SET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE Usuario (
    idUsuario VARCHAR(10) PRIMARY KEY NOT NULL,
    userType ENUM('Administrador', 'Miembro', 'Visitante', 'Vigilante') NOT NULL,
    usuario VARCHAR(25),
    contraseña VARCHAR(80),
    nombre VARCHAR(30) NOT NULL,
    apellidoP VARCHAR(30) NOT NULL,
    apellidoM VARCHAR(30) NOT NULL,
    fechaRegistro DATETIME NOT NULL
);

DELIMITER //
CREATE PROCEDURE InsertarUsuario(
    IN p_userType ENUM('Administrador', 'Miembro', 'Visitante', 'Vigilante'),
    IN p_usuario VARCHAR(25),
    IN p_contraseña VARCHAR(80),
    IN p_nombre VARCHAR(30),
    IN p_apellidoP VARCHAR(30),
    IN p_apellidoM VARCHAR(30)
)
BEGIN
    DECLARE v_idUsuario VARCHAR(10);
    DECLARE v_fechaRegistro DATETIME;
    DECLARE v_contraseñaHash VARCHAR(80);
    
    SET v_idUsuario = CONCAT('USR', LPAD(FLOOR(RAND() * 10000000), 7, '0'));
    
    WHILE EXISTS(SELECT 1 FROM Usuario WHERE idUsuario = v_idUsuario) DO
        SET v_idUsuario = CONCAT('USR', LPAD(FLOOR(RAND() * 10000000), 7, '0'));
    END WHILE;
    
    SET v_fechaRegistro = NOW();
    SET v_contraseñaHash = TO_BASE64(UNHEX(SHA2(p_contraseña, 256)));
    
    INSERT INTO Usuario(idUsuario, userType, usuario, contraseña, nombre, apellidoP, apellidoM, fechaRegistro)
    VALUES(v_idUsuario, p_userType, p_usuario, v_contraseñaHash, p_nombre, p_apellidoP, p_apellidoM, v_fechaRegistro);
END //
DELIMITER ;

CREATE TABLE Sede (
  idSede VARCHAR(7) PRIMARY KEY NOT NULL,
  nombre VARCHAR(80)
);

DELIMITER //
CREATE PROCEDURE InsertarSede(IN nombreSede VARCHAR(80))
BEGIN
    DECLARE sedeCount INT;
    SELECT COUNT(*) INTO sedeCount FROM Sede;
    SET sedeCount = sedeCount + 1;
    INSERT INTO Sede (idSede, nombre) VALUES (CONCAT('SEDE', LPAD(sedeCount, 3, '0')), nombreSede);
END //
DELIMITER ;



CREATE TABLE Administrador (
    idAdmin VARCHAR(10) PRIMARY KEY,
    idUsuario VARCHAR(10) NOT NULL,
    idSede VARCHAR(10) NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idSede) REFERENCES Sede(idSede)
);

CREATE TABLE Vigilante (
    idVigilante VARCHAR(10) PRIMARY KEY,
    idUsuario VARCHAR(10) NOT NULL,
    inicioTurno TIME NOT NULL,
    finTurno TIME NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Area (
  idArea VARCHAR(10) PRIMARY KEY,
  idSede VARCHAR(10),
  nombre VARCHAR(50),
  FOREIGN KEY (idSede) REFERENCES Sede(idSede)
);

CREATE TABLE Tipo_Miembro (
    idTipoMiembro VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE Miembro (
    matricula VARCHAR(10) PRIMARY KEY,
    idUsuario VARCHAR(10) NOT NULL,
    idArea VARCHAR(10) NOT NULL,
    idTipoMiembro VARCHAR(10) NOT NULL,
    foto VARCHAR(100) NOT NULL,
    teléfono VARCHAR(10) NOT NULL,
    mail VARCHAR(70) NOT NULL,
    verificado BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idArea) REFERENCES Area(idArea),
    FOREIGN KEY (idTipoMiembro) REFERENCES Tipo_Miembro(idTipoMiembro)
);

CREATE TABLE Tipo_Motivo (
    idTipoMotivo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30)
);

CREATE TABLE Tipo_Puerta (
  idTipoPuerta VARCHAR(10) PRIMARY KEY,
  nombre VARCHAR(30)
);

CREATE TABLE Puerta (
  idPuerta VARCHAR(10) PRIMARY KEY,
  idSede VARCHAR(10),
  idTipoPuerta VARCHAR(10),
  nombre VARCHAR(30),
  FOREIGN KEY (idSede) REFERENCES Sede(idSede),
  FOREIGN KEY (idTipoPuerta) REFERENCES Tipo_Puerta(idTipoPuerta)
);

CREATE TABLE Vigilante_Puerta (
  idAsignacion VARCHAR(10) PRIMARY KEY,
  idPuerta VARCHAR(10),
  idVigilante VARCHAR(10),
  fecha DATETIME NOT NULL,
  FOREIGN KEY (idPuerta) REFERENCES Puerta(idPuerta),
  FOREIGN KEY (idVigilante) REFERENCES Vigilante(idVigilante)
);

CREATE TABLE Visitante (
    idVisitante VARCHAR(10) PRIMARY KEY,
    idUsuario VARCHAR(10) NOT NULL,
    idAsignacion VARCHAR(10),
    idTipoMotivo VARCHAR(10),
    fecha DATETIME NOT NULL,
    teléfono VARCHAR(10),
    mail VARCHAR(50),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idAsignacion) REFERENCES Vigilante_Puerta(idAsignacion),
    FOREIGN KEY (idTipoMotivo) REFERENCES Tipo_Motivo(idTipoMotivo)
);

CREATE TABLE Vehiculo (
  vhCode VARCHAR(10) PRIMARY KEY,
  idUsuario VARCHAR(10),
  vhType ENUM('Bicicleta', 'Motocicleta', 'Scooter'),
  foto VARCHAR(100) NOT NULL, 
  marca VARCHAR(30) NOT NULL, 
  modelo VARCHAR(20) NOT NULL, 
  color VARCHAR(20) NOT NULL, 
  fechaRegistro DATETIME, 
  FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Tipo_Rodada (
  idTipoRodada VARCHAR(10) PRIMARY KEY NOT NULL,
  nombre VARCHAR(30)
);

CREATE TABLE Bicicleta (
  idBicicleta VARCHAR(10) PRIMARY KEY NOT NULL,
  vhCode VARCHAR(10) NOT NULL, 
  idTipoRodada VARCHAR(10) NOT NULL,
  FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode),
  FOREIGN KEY (idTipoRodada) REFERENCES Tipo_Rodada(idTipoRodada)
);

CREATE TABLE Tipo_Estilo (
  idTipoEstilo VARCHAR(10) PRIMARY KEY NOT NULL,
  nombre VARCHAR(30)
);

CREATE TABLE Motocicleta (
  idMotocicleta VARCHAR(10) PRIMARY KEY NOT NULL, 
  vhCode VARCHAR(10) NOT NULL, 
  idTipoEstilo VARCHAR(10) NOT NULL,
  FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode),
  FOREIGN KEY (idTipoEstilo) REFERENCES Tipo_Estilo(idTipoEstilo)
);

CREATE TABLE Tipo_Motor (
  idTipoMotor VARCHAR(10) PRIMARY KEY NOT NULL,
  nombre VARCHAR(30)
);

CREATE TABLE Scooter (
  idScooter VARCHAR(10) PRIMARY KEY NOT NULL,
  vhCode VARCHAR(10) NOT NULL, 
  idTipoMotor VARCHAR(10) NOT NULL,
  FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode),
  FOREIGN KEY (idTipoMotor) REFERENCES Tipo_Motor(idTipoMotor)
);

CREATE TABLE Movimiento (
  idMovimiento VARCHAR(10) PRIMARY KEY NOT NULL,
  idAsignacion VARCHAR(10) NOT NULL,
  idUsuario VARCHAR(10) NOT NULL,
  vhCode VARCHAR(10) NOT NULL,
  fecha DATETIME NOT NULL,
  esFlag BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (idAsignacion) REFERENCES Vigilante_Puerta(idAsignacion),
  FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
  FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode)
);

CREATE TABLE Estacionamiento (
    idMovimiento VARCHAR(10) PRIMARY KEY NOT NULL, 
    idAsignacion VARCHAR(10) NOT NULL,
    idUsuario VARCHAR(10) NOT NULL,
    vhCode VARCHAR(10) NOT NULL,
    fechaIngreso DATETIME NOT NULL,
    FOREIGN KEY (idMovimiento) REFERENCES Movimiento(idMovimiento),
    FOREIGN KEY (idAsignacion) REFERENCES Vigilante_Puerta(idAsignacion),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode)
);

CREATE TABLE Prestamo (
    idPrestamo VARCHAR(10) PRIMARY KEY NOT NULL,
    matricula VARCHAR(10) NOT NULL,
    vhCode VARCHAR(10) NOT NULL,
    mtrPrestatario VARCHAR(10) NOT NULL,
    fechaInicio DATETIME NOT NULL,
    fechaFin DATETIME NOT NULL,
    activeFlag BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (matricula) REFERENCES Miembro(matricula),
    FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode),
    FOREIGN KEY (mtrPrestatario) REFERENCES Miembro(matricula)
);

CREATE TABLE Tipo_Incidente (
   idTipoIncidente VARCHAR(10) PRIMARY KEY NOT NULL,
   nombre VARCHAR(30)
);

CREATE TABLE Incidente (
    idIncidente VARCHAR(10) PRIMARY KEY NOT NULL,
    idVigilante VARCHAR(10) NOT NULL,
    vhCode VARCHAR(10) NOT NULL,
    idArea VARCHAR(10) NOT NULL,
    idTipoIncidente VARCHAR(10) NOT NULL,
    fechaRegistro DATETIME NOT NULL,
    detalles VARCHAR(300) NOT NULL,
    foto VARCHAR(100) NOT NULL,
    FOREIGN KEY (idVigilante) REFERENCES Vigilante(idVigilante),
    FOREIGN KEY (vhCode) REFERENCES Vehiculo(vhCode),
    FOREIGN KEY (idArea) REFERENCES Area(idArea),
    FOREIGN KEY (idTipoIncidente) REFERENCES Tipo_Incidente(idTipoIncidente)
);


CALL InsertarUsuario('Administrador', 'usuario1', 'password123', 'Nombre', 'ApellidoP', 'ApellidoM');