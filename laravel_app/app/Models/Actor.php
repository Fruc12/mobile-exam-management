<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Actor extends Model
{

    protected $fillable = [
        'user_id',
        'npi',
        'id_card',
        'birthdate',
        'birthplace',
        'diploma',
        'bank',
        'n_rib',
        'rib',
        'phone',
    ];

    protected $with = ['user'];

    protected function casts(): array
    {
        return [
            'birthdate' => 'date',
        ];
    }

    public function user() : BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
