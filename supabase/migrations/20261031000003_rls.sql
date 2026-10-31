alter table public.rooms enable row level security;
alter table public.patients enable row level security;
alter table public.solves enable row level security;
alter table public.solve_results enable row level security;

revoke all on table public.rooms, public.patients, public.solves, public.solve_results
    from anon, authenticated;

grant select, insert, update, delete
    on table public.rooms, public.patients, public.solves, public.solve_results
    to service_role;
