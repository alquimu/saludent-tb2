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
      # Filtros opcionales desde la URL: /citas?id_odontologo=1&fecha=2026-10-20
      # Si no vienen, la plantilla los manda vacíos ("") y los convertimos a None (= todos)
      id_odontologo = event.get('id_odontologo') or None
      fecha = event.get('fecha') or None
      
      conn = conectar()
      cursor = conn.cursor()
      try:
          cursor.execute('exec usp_Listar_Citas @IDODONTOLOGO=?, @FECHA=?', (id_odontologo, fecha))
          data = []
          for row in cursor:
              data.append({"idCita": row[0], "fecha": row[1], "hora": row[2],
                           "odontologo": row[3], "tratamiento": row[4], "paciente": row[5],
                           "email": row[6], "telefono": row[7], "estado": row[8]})
          return {'isSuccess': True, 'data': data}
      except Exception as e:
          return {'isSuccess': False, 'errorMessage': str(e), 'data': []}
      finally:
          cursor.close()
          conn.close()