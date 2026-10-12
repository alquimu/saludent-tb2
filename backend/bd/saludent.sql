 -- =========================================
  -- SALUDENT - Script de base de datos (TB2)
  -- =========================================
  CREATE DATABASE DBSALUDENT
  GO
  USE DBSALUDENT
  GO

   -- ---------- 1. TABLAS ----------
  CREATE TABLE TM_TRATAMIENTO
  (
          IDTRATAMIENTO   INT PRIMARY KEY IDENTITY(1,1),
          NOMBRE          VARCHAR(128) NOT NULL,
          DESCRIPCION     VARCHAR(512),
          ICONO           VARCHAR(64),         -- clase de Bootstrap Icons, ej. bi-stars
          DURACION        INT,                 -- minutos
          PRECIOREGULAR   DECIMAL(10,2),       -- 0 = sin promoción
          PRECIOACTUAL    DECIMAL(10,2) NOT NULL,
          ACTIVO          BIT DEFAULT 1,
          FECHACREA       DATETIME DEFAULT GETDATE()
  )
  GO

  CREATE TABLE TM_ODONTOLOGO
  (
          IDODONTOLOGO    INT PRIMARY KEY IDENTITY(1,1),
          NOMBRE          VARCHAR(128) NOT NULL,
          ESPECIALIDAD    VARCHAR(128),
          REGISTRO        VARCHAR(256),
          ANIOS           INT,
          FOTO            VARCHAR(512),
          ACTIVO          BIT DEFAULT 1,
          FECHACREA       DATETIME DEFAULT GETDATE()
  )
  GO

  CREATE TABLE TM_CITA
  (
          IDCITA          INT PRIMARY KEY IDENTITY(1,1),
          IDODONTOLOGO    INT NOT NULL,
          IDTRATAMIENTO   INT NOT NULL,
          PACIENTE        VARCHAR(128) NOT NULL,
          EMAIL           VARCHAR(128) NOT NULL,
          TELEFONO        VARCHAR(16)  NOT NULL,
          FECHA           DATE NOT NULL,
          HORA            TIME NOT NULL,
          ESTADO          VARCHAR(16) DEFAULT 'CONFIRMADA',
          FECHACREA       DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (IDODONTOLOGO)  REFERENCES TM_ODONTOLOGO(IDODONTOLOGO),
          FOREIGN KEY (IDTRATAMIENTO) REFERENCES TM_TRATAMIENTO(IDTRATAMIENTO),
          CONSTRAINT UQ_CITA_HORARIO UNIQUE (IDODONTOLOGO, FECHA, HORA)  -- nadie reserva el mismo hueco dos veces
  )
  GO

  -- ---------- 2. PROCEDIMIENTOS ----------
  CREATE PROC usp_Listar_Tratamientos
  AS
          SELECT IDTRATAMIENTO, NOMBRE, DESCRIPCION, ICONO, DURACION, PRECIOREGULAR, PRECIOACTUAL,
                 CASE WHEN PRECIOREGULAR > 0
                      THEN CAST(ROUND(100 - PRECIOACTUAL * 100 / PRECIOREGULAR, 0) AS INT)
                      ELSE 0 END AS PROMO          -- % de descuento
          FROM   TM_TRATAMIENTO
          WHERE  ACTIVO = 1
  GO

  CREATE PROC usp_Listar_Odontologos
  AS
          SELECT IDODONTOLOGO, NOMBRE, ESPECIALIDAD, REGISTRO, ANIOS, FOTO
          FROM   TM_ODONTOLOGO
          WHERE  ACTIVO = 1
  GO

  -- Horario de atención fijo: 09:00 a 17:00, una cita por hora.
  -- Devuelve las horas de ese día que el odontólogo todavía tiene libres.
  CREATE PROC usp_Listar_Horarios_Disponibles
  (
          @IDODONTOLOGO INT,
          @FECHA DATE
  )
  AS
          SELECT H.HORA
          FROM  (VALUES ('09:00'),('10:00'),('11:00'),('12:00'),
                        ('14:00'),('15:00'),('16:00'),('17:00')) AS H(HORA)
          WHERE NOT EXISTS (SELECT 1 FROM TM_CITA C
                            WHERE C.IDODONTOLOGO = @IDODONTOLOGO
                              AND C.FECHA = @FECHA 
                              AND C.HORA  = CAST(H.HORA AS TIME)
                              AND C.ESTADO = 'CONFIRMADA')
          ORDER BY H.HORA     
  GO

  CREATE PROC usp_Insertar_Cita
  (
          @IDODONTOLOGO INT,
          @IDTRATAMIENTO INT,
          @PACIENTE VARCHAR(128),
          @EMAIL VARCHAR(128),
          @TELEFONO VARCHAR(16),
          @FECHA DATE,
          @HORA TIME
  )
  AS
            SET NOCOUNT ON
          IF EXISTS (SELECT 1 FROM TM_CITA
                     WHERE IDODONTOLOGO = @IDODONTOLOGO AND FECHA = @FECHA AND HORA = @HORA)
          BEGIN      
                  SELECT 0 AS IDCITA   -- 0 = horario ya ocupado
                  RETURN
          END     
    
          INSERT INTO TM_CITA (IDODONTOLOGO, IDTRATAMIENTO, PACIENTE, EMAIL, TELEFONO, FECHA, HORA)
          VALUES (@IDODONTOLOGO, @IDTRATAMIENTO, @PACIENTE, @EMAIL, @TELEFONO, @FECHA, @HORA)
    
          SELECT CAST(SCOPE_IDENTITY() AS INT) AS IDCITA
  GO

     
  -- ---------- 3. DATOS ----------
  INSERT INTO TM_TRATAMIENTO (NOMBRE, DESCRIPCION, ICONO, DURACION, PRECIOREGULAR, PRECIOACTUAL) VALUES
  ('Limpieza y profilaxis', 'Eliminamos sarro y placa bacteriana para prevenir caries y enfermedades de las encías.',
  'bi-droplet-half', 45, 120, 89),
  ('Ortodoncia', 'Brackets metálicos, estéticos y alineadores invisibles para corregir la posición de tus dientes.',
  'bi-grid-3x3-gap', 60, 0, 2500),
  ('Blanqueamiento dental', 'Aclaramos varios tonos el color de tus dientes de forma segura y sin sensibilidad.', 'bi-stars',
  90, 450, 349),
  ('Implantes dentales', 'Reemplazamos piezas perdidas con implantes de titanio que se ven y funcionan como dientes naturales.', 'bi-bullseye', 120, 0, 3200),
  ('Endodoncia', 'Tratamos el nervio del diente para salvarlo y eliminar el dolor sin necesidad de extraerlo.',
  'bi-activity', 75, 0, 380),
  ('Odontopediatría', 'Atención especial para los más pequeños en un ambiente cómodo y sin miedo.', 'bi-emoji-smile', 40,
  100, 75),
  ('Estética dental', 'Carillas, diseño de sonrisa y resinas estéticas para mejorar la forma y el color de tus dientes.',
  'bi-gem', 90, 0, 850),
  ('Urgencias 24/7', 'Te atendemos a cualquier hora ante dolor intenso, golpes o piezas rotas.', 'bi-hospital', 30, 0, 150)
  GO

  INSERT INTO TM_ODONTOLOGO (NOMBRE, ESPECIALIDAD, REGISTRO, ANIOS, FOTO) VALUES
  ('Dra. Lucía Ramírez', 'Ortodoncia y Ortopedia Maxilar', 'COP 28451 · Universidad Peruana de Ciencias Aplicadas', 12,
   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_X3-JmfvQnqX86faPqdUlRtJDbrYl_43LQkMDgWUBjQ&s=10'),
  ('Dr. Andrés Salgado', 'Implantología y Cirugía Oral', 'COP 31207 · Máster en Implantología, Barcelona', 15,
   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5MqQ5r6lZrz1Awz9sI4AdpBd2RFiTNk76JdwnCazccA&s=10'),
  ('Dra. Camila Torres', 'Estética Dental y Rehabilitación', 'COP 35980 · Diplomado en Carillas Cerámicas', 8,
   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpT2RZokc1omaBNpBnFSiZW6c1IclRINiZQ9uaAnosCA&s=10'),
  ('Dr. Martín Quispe', 'Odontopediatría', 'COP 39112 · Especialista en manejo de conducta infantil', 10,
   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF8MtvIognhqYh0KVao4wsR9-odS5oud-Pd3eN1s7XSA&s=10')
  GO
   
  -- ---------- 4. PRUEBAS ----------
  -- EXEC usp_Listar_Tratamientos
  -- EXEC usp_Listar_Odontologos
  -- EXEC usp_Listar_Horarios_Disponibles @IDODONTOLOGO=1, @FECHA='2026-10-20'
  -- EXEC usp_Insertar_Cita 1, 1, 'Ana Pérez', 'ana@mail.com', '999888777', '2026-10-20', '10:00'
  -- EXEC usp_Listar_Horarios_Disponibles @IDODONTOLOGO=1, @FECHA='2026-10-20'   -- ya no sale 10:00
  -- EXEC usp_Insertar_Cita 1, 1, 'Otro', 'x@mail.com', '999', '2026-10-20', '10:00'  -- devuelve 0

-- ---------- 5. PANEL DE LA CLÍNICA (agregado) ----------
  -- Lista las citas; los filtros son opcionales (NULL = todos)
  CREATE PROC usp_Listar_Citas
  (
          @IDODONTOLOGO INT = NULL,
          @FECHA DATE = NULL
  )
  AS
          SELECT C.IDCITA,
                 CONVERT(VARCHAR(10), C.FECHA, 23) AS FECHA,   -- '2026-10-20'
                 CONVERT(VARCHAR(5),  C.HORA, 108) AS HORA,    -- '10:00'
                 O.NOMBRE AS ODONTOLOGO,
                 T.NOMBRE AS TRATAMIENTO,
                 C.PACIENTE, C.EMAIL, C.TELEFONO, C.ESTADO
          FROM   TM_CITA C
          INNER JOIN TM_ODONTOLOGO  O ON O.IDODONTOLOGO  = C.IDODONTOLOGO
          INNER JOIN TM_TRATAMIENTO T ON T.IDTRATAMIENTO = C.IDTRATAMIENTO
          WHERE (@IDODONTOLOGO IS NULL OR C.IDODONTOLOGO = @IDODONTOLOGO)
            AND (@FECHA IS NULL OR C.FECHA = @FECHA)
          ORDER BY C.FECHA, C.HORA 
  GO
 
  -- ---------- 6. ACCESO DEL PERSONAL Y CONSULTA DEL PACIENTE (agregado) ----------
  CREATE TABLE TM_USUARIO
  (
          IDUSUARIO           INT PRIMARY KEY IDENTITY(1,1),
          LOGINUSUARIO        VARCHAR(64) NOT NULL UNIQUE,
          DOCUMENTOIDENTIDAD  VARCHAR(16) NOT NULL,      -- el DNI hace de clave (acceso ligero)
          NOMBRES             VARCHAR(128),
          ACTIVO              BIT DEFAULT 1,
          FECHACREA           DATETIME DEFAULT GETDATE()
  )
  GO
 
  INSERT INTO TM_USUARIO (LOGINUSUARIO, DOCUMENTOIDENTIDAD, NOMBRES) VALUES
  ('recepcion', '12345678', 'Recepción Saludent')
  GO

   -- Devuelve el usuario si usuario + DNI coinciden; si no, no devuelve filas
  CREATE PROC usp_Login_Usuario
  (
          @LOGINUSUARIO VARCHAR(64),
          @DOCUMENTOIDENTIDAD VARCHAR(16)
  )
  AS
          SELECT IDUSUARIO, LOGINUSUARIO, NOMBRES
          FROM   TM_USUARIO
          WHERE  LOGINUSUARIO = @LOGINUSUARIO
            AND  DOCUMENTOIDENTIDAD = @DOCUMENTOIDENTIDAD
            AND  ACTIVO = 1
  GO        

  -- Citas de un paciente: deben coincidir correo Y celular (así nadie ve citas ajenas solo con un correo)
  CREATE PROC usp_Listar_Citas_Paciente
  (
          @EMAIL VARCHAR(128),
          @TELEFONO VARCHAR(16)
  )
  AS
          SELECT C.IDCITA,
                 CONVERT(VARCHAR(10), C.FECHA, 23) AS FECHA,
                 CONVERT(VARCHAR(5),  C.HORA, 108) AS HORA,
                 O.NOMBRE AS ODONTOLOGO,
                 T.NOMBRE AS TRATAMIENTO,
                 C.PACIENTE, C.ESTADO
          FROM   TM_CITA C
          INNER JOIN TM_ODONTOLOGO  O ON O.IDODONTOLOGO  = C.IDODONTOLOGO
          INNER JOIN TM_TRATAMIENTO T ON T.IDTRATAMIENTO = C.IDTRATAMIENTO
          WHERE  C.EMAIL = @EMAIL
            AND  C.TELEFONO = @TELEFONO
          ORDER BY C.FECHA, C.HORA
  GO

   -- Devuelve el usuario si usuario + DNI coinciden; si no, no devuelve filas
  CREATE PROC usp_Login_Usuario
  (
          @LOGINUSUARIO VARCHAR(64),
          @DOCUMENTOIDENTIDAD VARCHAR(16)
  )
  AS
          SELECT IDUSUARIO, LOGINUSUARIO, NOMBRES
          FROM   TM_USUARIO
          WHERE  LOGINUSUARIO = @LOGINUSUARIO
            AND  DOCUMENTOIDENTIDAD = @DOCUMENTOIDENTIDAD
            AND  ACTIVO = 1
  GO        

  -- Citas de un paciente: deben coincidir correo Y celular (así nadie ve citas ajenas solo con un correo)
  CREATE PROC usp_Listar_Citas_Paciente
  (
          @EMAIL VARCHAR(128),
          @TELEFONO VARCHAR(16)
  )
  AS
          SELECT C.IDCITA,
                 CONVERT(VARCHAR(10), C.FECHA, 23) AS FECHA,
                 CONVERT(VARCHAR(5),  C.HORA, 108) AS HORA,
                 O.NOMBRE AS ODONTOLOGO,
                 T.NOMBRE AS TRATAMIENTO,
                 C.PACIENTE, C.ESTADO
          FROM   TM_CITA C
          INNER JOIN TM_ODONTOLOGO  O ON O.IDODONTOLOGO  = C.IDODONTOLOGO
          INNER JOIN TM_TRATAMIENTO T ON T.IDTRATAMIENTO = C.IDTRATAMIENTO
          WHERE  C.EMAIL = @EMAIL
            AND  C.TELEFONO = @TELEFONO
          ORDER BY C.FECHA, C.HORA
  GO
  