import { Component, signal } from '@angular/core';
  import { RouterLink } from '@angular/router';
  import { ApiService } from '../services/api-service';
 
  @Component({
    selector: 'app-servicios',
    imports: [RouterLink],
    templateUrl: './servicios.html',
    styleUrl: './servicios.css',
  })
  export class Servicios {
    constructor(
      private readonly api: ApiService
    ) {}
    
    servicios = signal<any[]>([]);
    
    __listar_servicios() {
      this.api.listar_tratamientos().subscribe((rest: any) => {
        this.servicios.set(rest.data);
      });
    } 
    
    ngOnInit(): void {
      this.__listar_servicios();
    } 
  }