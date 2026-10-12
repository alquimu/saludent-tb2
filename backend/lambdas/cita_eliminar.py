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
      # Llega en el cuerpo del POST: {"idCita": 5, "email": "...", "telefono": "..."}
      params = (event.get('idCita'), event.get('email'), event.get('telefono'))
      
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Eliminar_Cita @IDCITA=?, @EMAIL=?, @TELEFONO=?', params)
          filas = cursor.fetchone()[0]
          conn.commit()                    # sin commit, el DELETE se deshace al cerrar
          
          if filas == 0:
              return {'isSuccess': False, 'errorMessage': 'No se pudo eliminar la cita.'}
          return {'isSuccess': True, 'errorMessage': 'Cita eliminada'}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e)}
      finally:
          cursor.close()
          conn.close()