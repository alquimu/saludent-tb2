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
      # Llegan desde la URL: /horarios?id_odontologo=1&fecha=2026-10-20
      id_odontologo = event.get('id_odontologo')
      fecha = event.get('fecha')
     
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Listar_Horarios_Disponibles @IDODONTOLOGO=?, @FECHA=?',
                         (id_odontologo, fecha))
          data = []
          for row in cursor:
              data.append(row[0])          # "09:00", "10:00", ...
          return {'isSuccess': True, 'data': data}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e), 'data': []}
      finally:
          cursor.close()
          conn.close()