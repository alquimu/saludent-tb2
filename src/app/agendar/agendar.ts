 import { Component, inject, signal } from '@angular/core';
  import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
  import { ApiService } from '../services/api-service'; 
 
  @Component({
    selector: 'app-agendar',
    imports: [ReactiveFormsModule],
    templateUrl: './agendar.html',
    styleUrl: './agendar.css',
  })
  export class Agendar {
    constructor(
      private readonly api: ApiService
    ) {}
    
    // FormBuilder con inject(): así ya existe cuando se crea citaForm (línea de abajo)
    private fb = inject(FormBuilder);
    
    tratamientos = signal<any[]>([]);
    odontologos = signal<any[]>([]);
    horarios = signal<string[]>([]);
    citaConfirmada = signal<any>(null);
    mensajeError = signal('');
    
    hoy = new Date().toLocaleDateString('en-CA');   // fecha local "2026-10-11", para no elegir días pasados
    
    citaForm = this.fb.group({
      idTratamiento: ['', [Validators.required]],
      idOdontologo: ['', [Validators.required]],
      fecha: ['', [Validators.required]],
      hora: ['', [Validators.required]],
      paciente: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      telefono: ['', [Validators.required, Validators.pattern('^9[0-9]{8}$')]],
    });
    
    // Cada vez que cambia el odontólogo o la fecha, se piden a la API las horas libres
    __cargar_horarios() {
      const idOdontologo = this.citaForm.value.idOdontologo;
      const fecha = this.citaForm.value.fecha;
      this.citaForm.patchValue({ hora: '' });
      this.horarios.set([]);
      
      if (idOdontologo && fecha) {
        this.api.listar_horarios(idOdontologo, fecha).subscribe((rest: any) => {
          this.horarios.set(rest.data);
        });
      } 
    }

     __submit() {
      this.mensajeError.set('');
      if (this.citaForm.invalid) {
        this.citaForm.markAllAsTouched();
        this.mensajeError.set('Completa correctamente todos los campos.');
        return;
      } 
      
      const data = this.citaForm.value;
      this.api.insertar_cita(data).subscribe((rest: any) => {
        if (rest.isSuccess) {
          const odontologo = this.odontologos().find(o => o.idOdontologo == data.idOdontologo);
          const tratamiento = this.tratamientos().find(t => t.idTratamiento == data.idTratamiento);
          this.citaConfirmada.set({ ...data, idCita: rest.idCita,
                                    odontologo: odontologo?.nombre, tratamiento: tratamiento?.nombre });
        } else {                    
          this.mensajeError.set(rest.errorMessage);   // ej. "Ese horario ya fue reservado"
          this.__cargar_horarios();                   // refresca las horas libres
        } 
      }); 
    } 
    
    __nueva_cita() {
      this.citaConfirmada.set(null);
      this.citaForm.reset({ idTratamiento: '', idOdontologo: '', fecha: '', hora: '' });
      this.horarios.set([]);
    } 
    
    // true si el campo fue tocado y tiene error (para pintarlo en rojo)
    invalido(campo: string) {
      const control = this.citaForm.get(campo);
      return !!control && control.invalid && control.touched;
    } 
    
    ngOnInit(): void {
      this.api.listar_tratamientos().subscribe((rest: any) => this.tratamientos.set(rest.data));
      this.api.listar_odontologos().subscribe((rest: any) => this.odontologos.set(rest.data));
    } 
  } 