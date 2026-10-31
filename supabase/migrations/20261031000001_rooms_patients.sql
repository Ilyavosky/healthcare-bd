create table public.rooms (
    id uuid primary key default gen_random_uuid(),
    name text not null check (char_length(btrim(name)) between 1 and 80),
    shift_started_at timestamptz not null,
    doctors smallint not null default 1 check (doctors >= 1),
    status text not null default 'open' check (status in ('open', 'closed')),
    created_at timestamptz not null default now()
);

create table public.patients (
    id uuid primary key default gen_random_uuid(),
    room_id uuid not null references public.rooms (id) on delete cascade,
    label text not null check (char_length(btrim(label)) between 1 and 40),
    level smallint not null check (level between 1 and 5),
    duration_min integer not null check (duration_min > 0),
    arrived_at timestamptz not null,
    attended_at timestamptz,
    doctor smallint check (doctor >= 1),
    created_at timestamptz not null default now(),
    constraint patients_room_label_key unique (room_id, label),
    constraint patients_doctor_requires_attention check (doctor is null or attended_at is not null),
    constraint patients_attended_after_arrival check (attended_at is null or attended_at >= arrived_at)
);

create index patients_room_id_idx on public.patients (room_id, created_at);

comment on table public.rooms is 'Salas de espera de urgencias';
comment on column public.rooms.shift_started_at is 'Inicio del turno: t = 0 del modelo';
comment on column public.rooms.doctors is 'Número de médicos que atienden en paralelo';
comment on table public.patients is 'Pacientes capturados en cada sala';
comment on column public.patients.label is 'Identificador visible dentro de la sala (P1, P2, …)';
comment on column public.patients.attended_at is 'Minuto en que empezó su consulta; nulo si sigue esperando';
comment on column public.patients.doctor is 'Médico (1..rooms.doctors) que lo atiende o atendió';
