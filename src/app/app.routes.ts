import { Routes } from '@angular/router';
  import { Home } from './home/home';
  import { Servicios } from './servicios/servicios';
  import { Precios } from './precios/precios';
  import { Equipo } from './equipo/equipo';
  import { Agendar } from './agendar/agendar';
  import { Panel } from './panel/panel';
  import { Login } from './login/login';
  import { MisCitas } from './mis-citas/mis-citas';

  export const routes: Routes = [
    { path: '', component: Home },
    { path: 'servicios', component: Servicios },
    { path: 'precios', component: Precios },
    { path: 'equipo', component: Equipo },
    { path: 'agendar', component: Agendar },
    { path: 'panel', component: Panel },
    { path: 'login', component: Login },
    { path: 'mis-citas', component: MisCitas },
  ];