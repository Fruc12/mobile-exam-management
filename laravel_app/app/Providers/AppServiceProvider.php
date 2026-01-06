<?php

namespace App\Providers;

use App\Models\Actor;
use App\Models\User;
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\HtmlString;
use Illuminate\Support\ServiceProvider;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::define('manage-actor', function (User $user, Actor $actor) {
            if ($user->role == 'admin' || $user->id === $actor->user_id) {
                return true;
            }
            return false;
        });

        VerifyEmail::toMailUsing(function (object $notifiable, string $url) {
            return (new MailMessage)
                ->subject(__('Verify Your Email Address'))
                ->line(__('Please click the button below to verify your email address.'))
                ->action(__('Verify Email Address'), $url)
                ->line(__('Or scan the QrCode below :'))
                ->line(new HtmlString(
                    '<div style="text-align:center;margin-top:15px">
                            <img src="data:image/png;base64,'.base64_encode(
                                QrCode::format('png')
                                    ->size(150)
                                    ->margin(1)
                                    ->generate($url)
                            ).'" alt="QR Code">
                         </div>'
                ));
        });
    }
}
