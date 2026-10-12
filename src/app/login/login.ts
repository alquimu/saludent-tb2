import { Component, inject, signal } from '@angular/core';
  import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
  import { Router } from '@angular/router';
  import { ApiService } from '../services/api-service';

  @Component({
    selector: 'app-login',
    imports: [ReactiveFormsModule],
    templateUrl: './login.html',
    styleUrl: './login.css',
  })
  export class Login {
    constructor(
      private readonly api: ApiService,
      private router: Router
    ) {}
    
    private fb = inject(FormBuilder);
    mensajeError = signal('');
    
    loginForm = this.fb.group({
      usuario: ['', [Validators.required]],
      dni: ['', [Validators.required, Validators.pattern('^[0-9]{8}$')]],
    });
    
    __submit() {
      this.mensajeError.set('');
      if (this.loginForm.invalid) {
        this.mensajeError.set('Ingresa tu usuario y un DNI de 8 dígitos.');
        return;
      }
      this.api.login(this.loginForm.value).subscribe((rest: any) => {
        if (rest.isSuccess) {
          // Se guarda la sesión en el navegador (dura mientras la pestaña esté abierta)
          sessionStorage.setItem('saludent.usuario', JSON.stringify(rest.data));
          this.router.navigate(['/panel']);
        } else {
          this.mensajeError.set(rest.errorMessage);
        }
      });
    }
  }