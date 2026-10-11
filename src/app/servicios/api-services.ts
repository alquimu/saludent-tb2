import { HttpClient } from '@angular/common/http';
  import { Injectable } from '@angular/core';
 
  const API = 'https://x6sn8mk18h.execute-api.us-east-1.amazonaws.com/v1';
  
  @Injectable({
    providedIn: 'root',
  })
  export class ApiService {
    constructor(
      private readonly http: HttpClient
    ) {}
    
    listar_tratamientos() {
      return this.http.get(API + '/tratamientos', { responseType: 'json' });
    } 
    
    listar_odontologos() {
      return this.http.get(API + '/odontologos', { responseType: 'json' });
    } 
   
    listar_horarios(idOdontologo: string, fecha: string) {
      return this.http.get(API + '/horarios?id_odontologo=' + idOdontologo + '&fecha=' + fecha, { responseType: 'json' });
    } 
  
    insertar_cita(data: any) {
      return this.http.post(API + '/citas', data, { responseType: 'json' });
    } 
  }