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
      # Llega en el cuerpo del POST: {"usuario": "recepcion", "dni": "12345678"}
      params = (event.get('usuario'), event.get('dni'))
      
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Login_Usuario @LOGINUSUARIO=?, @DOCUMENTOIDENTIDAD=?', params)
          row = cursor.fetchone()
          if row is None:
              return {'isSuccess': False, 'errorMessage': 'Usuario o DNI incorrectos'}
          return {'isSuccess': True, 'data': {"idUsuario": row[0], "usuario": row[1], "nombres": row[2]}}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e)}
      finally:
          cursor.close()
          conn.close()