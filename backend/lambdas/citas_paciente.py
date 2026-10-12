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
      # Llega en el cuerpo del POST: {"email": "...", "telefono": "..."}
      # Se usa POST (no GET) para que el correo y el celular no queden visibles en la URL
      params = (event.get('email'), event.get('telefono'))
      
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Listar_Citas_Paciente @EMAIL=?, @TELEFONO=?', params)
          data = []
          for row in cursor:
              data.append({"idCita": row[0], "fecha": row[1], "hora": row[2], "odontologo": row[3],
                           "tratamiento": row[4], "paciente": row[5], "estado": row[6]})
          return {'isSuccess': True, 'data': data}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e), 'data': []}
      finally:
          cursor.close()
          conn.close()