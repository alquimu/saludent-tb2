import { Component, inject, signal } from '@angular/core';
  import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
  import { Router } from '@angular/router';
  import { ApiService } from '../services/api-service';

  @Component({
    selector: 'app-mis-citas',
    imports: [ReactiveFormsModule],
    templateUrl: './mis-citas.html',
    styleUrl: './mis-citas.css',
  })
  export class MisCitas {
    constructor(
      private readonly api: ApiService,
      private router: Router
    ) {}
    
    private fb = inject(FormBuilder);
    citas = signal<any[]>([]);
    buscado = signal(false);   // para mostrar "no tienes citas" solo después de buscar
    mensajeError = signal('');
    
    consultaForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      telefono: ['', [Validators.required, Validators.pattern('^9[0-9]{8}$')]],
    });
    
    __submit() {
      this.mensajeError.set('');
      if (this.consultaForm.invalid) {
        this.mensajeError.set('Ingresa el correo y el celular con los que reservaste.');
        return;
      }
      this.api.listar_citas_paciente(this.consultaForm.value).subscribe((rest: any) => {
        this.citas.set(rest.data);
        this.buscado.set(true);
      });
    }

    __eliminar(c: any) {
      if (!confirm('Se eliminará tu cita del ' + c.fecha + ' a las ' + c.hora + ' y podrás elegir otro horario. ¿Continuar?')) {
        return;
      }
      const data = {
        idCita: c.idCita,
        email: this.consultaForm.value.email,
        telefono: this.consultaForm.value.telefono,
      };
      this.api.eliminar_cita(data).subscribe((rest: any) => {
        alert(rest.errorMessage);
        if (rest.isSuccess) {
          this.router.navigate(['/agendar']);   // se va a agendar para elegir el nuevo horario
        }
      }); 
    }   
  }