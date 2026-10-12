import { Component, signal } from '@angular/core';
  import { Router } from '@angular/router';
  import { ApiService } from '../services/api-service';

  @Component({
    selector: 'app-panel',
    imports: [],
    templateUrl: './panel.html',
    styleUrl: './panel.css',
  })
  export class Panel {
    constructor(
      private readonly api: ApiService,
      private router: Router
    ) {}
    
    usuario: any = null;
    
    odontologos = signal<any[]>([]);
    citas = signal<any[]>([]);
    
    idOdontologo = '';   // '' = todos
    fecha = '';          // '' = todas las fechas
    
    __listar_citas() {
      this.api.listar_citas(this.idOdontologo, this.fecha).subscribe((rest: any) => {
        this.citas.set(rest.data);
      });
    } 
    
    __filtrar_odontologo(valor: string) {
      this.idOdontologo = valor;
      this.__listar_citas();
    } 
    
    __filtrar_fecha(valor: string) {
      this.fecha = valor;
      this.__listar_citas();
    }

    __salir() {
      sessionStorage.removeItem('saludent.usuario');
      this.router.navigate(['/login']);
    } 
    
    ngOnInit(): void {
      // Si nadie inició sesión, se manda al login
      const sesion = sessionStorage.getItem('saludent.usuario');
      if (!sesion) { 
        this.router.navigate(['/login']);
        return;
      } 
      this.usuario = JSON.parse(sesion);
      
      this.api.listar_odontologos().subscribe((rest: any) => this.odontologos.set(rest.data));
      this.__listar_citas();
    } 
  } 