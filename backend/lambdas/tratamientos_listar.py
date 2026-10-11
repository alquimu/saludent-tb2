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
          cursor.execute('exec usp_Listar_Tratamientos')
          data = []
          for row in cursor:
              data.append({"idTratamiento": row[0], "nombre": row[1], "descripcion": row[2],
                           "icono": row[3], "duracion": row[4],
                           "precioRegular": float(row[5]), "precioHoy": float(row[6]),
                           "promo": row[7]})
          return {'isSuccess': True, 'data': data}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e), 'data': []}
      finally:
          cursor.close()
          conn.close()
