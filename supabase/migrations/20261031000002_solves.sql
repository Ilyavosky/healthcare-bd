create table public.solves (
    id uuid primary key default gen_random_uuid(),
    room_id uuid not null references public.rooms (id) on delete cascade,
    computed_at timestamptz not null,
    t0_min integer not null check (t0_min >= 0),
    doctors smallint not null check (doctors >= 1),
    doctors_free_at integer[] not null,
    critical_first boolean not null,
    goal_type text not null check (goal_type in ('all', 'critical', 'k', 'horizon', 'subset')),
    goal_value jsonb,
    input_snapshot jsonb not null,
    reference text not null check (reference in ('ucs', 'astar_simple', 'astar', 'baseline')),
    cost integer not null check (cost >= 0),
    baseline_cost integer not null check (baseline_cost >= 0),
    baseline_order jsonb not null,
    same_cost boolean,
    baseline_gap_pct numeric,
    alerts jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now(),
    constraint solves_doctors_free_at_size check (cardinality(doctors_free_at) = doctors)
);

create table public.solve_results (
    id uuid primary key default gen_random_uuid(),
    solve_id uuid not null references public.solves (id) on delete cascade,
    algorithm text not null check (algorithm in ('ucs', 'astar_simple', 'astar')),
    status text not null check (status in ('optimal', 'approximate', 'limit_reached')),
    weight numeric not null default 1 check (weight >= 1),
    cost integer check (cost >= 0),
    expanded integer check (expanded >= 0),
    max_frontier integer check (max_frontier >= 0),
    elapsed_ms numeric check (elapsed_ms >= 0),
    reopened integer check (reopened >= 0),
    steps jsonb not null default '[]'::jsonb,
    left_out jsonb not null default '[]'::jsonb,
    limit_attempts jsonb not null default '[]'::jsonb,
    constraint solve_results_solve_algorithm_key unique (solve_id, algorithm),
    constraint solve_results_finished_has_cost check ((status = 'limit_reached') = (cost is null))
);

create index solves_room_created_idx on public.solves (room_id, created_at desc);

comment on table public.solves is 'Cada vez que se resuelve una sala: entrada en minutos, meta y resumen';
comment on column public.solves.input_snapshot is 'Pacientes y estado inicial ya convertidos a minutos (F20)';
comment on column public.solves.reference is 'Algoritmo cuya agenda se mostró, o baseline si ninguno terminó';
comment on table public.solve_results is 'Un renglón por algoritmo de cada corrida';
