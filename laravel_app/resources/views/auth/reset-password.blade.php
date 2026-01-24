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
                <h1>Réinitialisez votre mot de passe</h1>
                <p>Veuillez remplir le formulaire ci-dessous.</p>
                <ul>
                    <form action="{{ route('password.update') }}" method="post">
                        <input type="hidden" name="token" value="{{ request()->route('token') }}">
                        <li class="mb-4">
                            <label for="email">Adresse e-mail</label>
                            <input id="email" name="email" type="email" value="{{ old('email', request()->email) }}" required autofocus>
                            {{-- @error('email')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror --}}
                        </li>
                        <li class="mb-4">
                            <label for="password">Nouveau mot de passe</label>
                            <input id="password" name="password" type="password" required>
                            {{-- @error('password')
                                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                            @enderror --}}
                        </li>
                        <li class="mb-6">
                            <label for="password_confirmation" class="block mb-1 font-medium">Confirmer le mot de passe</label>
                            <input id="password_confirmation" name="password_confirmation" type="password" required>
                        </li>
                        <li>
                            <input type="submit" value="Réinitialiser le mot de passe">
                        </li>
                    </form>
                </ul>
            </div>
        </main>
    </div>
</body>
</html>
