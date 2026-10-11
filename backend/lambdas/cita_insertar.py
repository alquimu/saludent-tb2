import os
import pyodbc
 
          
def conectar():
      return pyodbc.connect("Driver={ODBC Driver 18 for SQL Server};"
                            "Server=" + os.environ['DB_SERVER'] + ";"
                            "Database=DBSALUDENT;"
                            "UID=" + os.environ['DB_USER'] + ";"
                            "PWD=" + os.environ['DB_PASSWORD'] + ";"
                            "TrustServerCertificate=yes;")
                            
                 
def lambda_handler(event, context):
      # Llega en el cuerpo (body) del POST como JSON
      params = (event.get('idOdontologo'), event.get('idTratamiento'), event.get('paciente'),
                event.get('email'), event.get('telefono'), event.get('fecha'), event.get('hora'))
                
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Insertar_Cita @IDODONTOLOGO=?, @IDTRATAMIENTO=?, @PACIENTE=?, '
                         '@EMAIL=?, @TELEFONO=?, @FECHA=?, @HORA=?', params)
          id_cita = cursor.fetchone()[0]
          conn.commit()                    # sin commit, el INSERT se deshace al cerrar
          
          if id_cita == 0:
              return {'isSuccess': False, 'errorMessage': 'Ese horario ya fue reservado. Elige otro.'}
          return {'isSuccess': True, 'idCita': id_cita, 'errorMessage': 'Cita registrada'}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e)}
      finally:
          cursor.close()
          conn.close()