import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
  import { provideRouter, withInMemoryScrolling } from '@angular/router';
  import { provideHttpClient } from '@angular/common/http';      // ← nueva
  import { routes } from './app.routes';
 
  export const appConfig: ApplicationConfig = {
    providers: [
      provideBrowserGlobalErrorListeners(),                        
      provideHttpClient(),                                         // ← nueva
      provideRouter(routes, withInMemoryScrolling({ anchorScrolling: 'enabled', scrollPositionRestoration: 'enabled' }))
    ]
  };