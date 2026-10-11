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
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Listar_Odontologos')
          data = []
          for row in cursor:
              data.append({"idOdontologo": row[0], "nombre": row[1], "especialidad": row[2],
                           "registro": row[3], "anios": row[4], "foto": row[5]})
          return {'isSuccess': True, 'data': data}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e), 'data': []}
      finally:
          cursor.close()
          conn.close()