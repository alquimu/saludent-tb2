import { Component, signal } from '@angular/core';
  import { RouterLink } from '@angular/router';
  import { ApiService } from '../services/api-service';
 
  @Component({
    selector: 'app-precios',
    imports: [RouterLink],
    templateUrl: './precios.html',
    styleUrl: './precios.css',
  })
  export class Precios {
    constructor(
      private readonly api: ApiService
    ) {}
    
    tratamientos = signal<any[]>([]);
    
    __listar_tratamientos() {
      this.api.listar_tratamientos().subscribe((rest: any) => {
        this.tratamientos.set(rest.data);
      });
    } 
    
    ngOnInit(): void {
      this.__listar_tratamientos();
    } 
  } 
