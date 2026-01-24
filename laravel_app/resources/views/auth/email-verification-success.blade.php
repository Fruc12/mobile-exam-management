<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Laravel') }}</title>
</head>
<body>
    <div>
        <main>
            <div>
                <h1>Vérification de l'e-mail réussie</h1>
                <p>Merci d'avoir vérifié votre adresse e-mail.</p>
            </div>
        </main>
    </div>
</body>
</html>