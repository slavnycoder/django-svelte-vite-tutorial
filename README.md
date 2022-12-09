### Django + Svelte(vite)

How to serve svelte SPA with django. 

Firstly you should create empty Svelte project inside Django basedir.
```
npm create vite@latest frontend -- --template svelte
```
```
├── backend
│      ├── asgi.py
│      ├── celery.py
│      ├── __init__.py
│      ├── __pycache__
│      ├── settings.py
│      ├── urls.py
│      └── wsgi.py
├── frontend
│      ├── index.html
│      ├── jsconfig.json
│      ├── node_modules
│      ├── package.json
│      ├── package-lock.json
│      ├── public
│      ├── README.md
│      ├── src
│      └── vite.config.js
├── manage.py
```
In `vite.config.js` add build `rollupOptions` to avoid adding hash.
```javascript
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

export default defineConfig({
  plugins: [svelte()],
  build: {
    rollupOptions: {
      output: {
        entryFileNames: `[name].js`,
        chunkFileNames: `[name].js`,
        assetFileNames: `[name].[ext]`
      }
    }
  }
})
```


Then create custom [index.html](index.html) in templates folder.

Add views for serving your index.html and static files.
```python
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

urlpatterns = [
    path("api/", include(router.urls)), # Django rest framework router
    path("admin/", admin.site.urls),
    re_path("", TemplateView.as_view(template_name="index.html")),
    *staticfiles_urlpatterns(),
]
```
Install whitenoise package: `pip install whitenoise`

```python
# settings.py
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"
STATICFILES_DIRS = [
    "/frontend/"
]

TEMPLATES = [
    {
        ...
        "DIRS": [
            (BASE_DIR / 'templates'),
        ],
        ...
    },
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    ...
]
```

I use Docker to compile my project. Take a look on my [Dockerfile](Dockerfile).

1) Build our bundle
2) Install python dependencies and build yout project
3) Copy builded Svelte project from `dist` folder to `/frontend/` folder inside your container.

Before you run your server run `collectstatic`

```
python manage.py collectstatic --noinput
python manage.py runserver
```

Django will use your custom `index.html` template, but u can still use default svelte `index.html` for frontend development. Don't forget to update changes in your template.
