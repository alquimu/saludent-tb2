import { Component, signal } from '@angular/core';
  import { ApiService } from '../services/api-service';
 
  @Component({
    selector: 'app-equipo',
    imports: [],
    templateUrl: './equipo.html',
    styleUrl: './equipo.css',
  })
  export class Equipo {
    constructor(
      private readonly api: ApiService
    ) {}
      
    odontologos = signal<any[]>([]);
      
    __listar_odontologos() {
      this.api.listar_odontologos().subscribe((rest: any) => {
        this.odontologos.set(rest.data);
      });
    }   
      
    ngOnInit(): void {
      this.__listar_odontologos();
    }
  } 