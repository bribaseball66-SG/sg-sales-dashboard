-- ============================================================
-- SG SALES DASHBOARD — Supabase migration
-- Run this ONCE in Supabase Dashboard → SQL Editor → Run.
-- 1) Creates one table per entity (row per record, jsonb payload)
-- 2) Copies all existing data out of the old sg_data key/value rows
-- Old sg_data rows are LEFT INTACT as a backup — nothing is deleted.
-- ============================================================

create extension if not exists pgcrypto;

-- 1) Entity tables -------------------------------------------------
create table if not exists contacts    (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists followups   (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists suppliers   (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists socialleads (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists prospects   (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists sequences   (id text primary key, data jsonb not null, updated_at timestamptz not null default now());
create table if not exists approvals   (id text primary key, data jsonb not null, updated_at timestamptz not null default now());

-- 2) Migrate legacy sg_data arrays → tables ------------------------
insert into contacts (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key = 'contacts' and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

insert into followups (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key = 'followups' and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

insert into suppliers (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key = 'suppliers' and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

insert into socialleads (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key = 'socialleads' and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

insert into prospects (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key in ('prospects','prospecting') and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

insert into sequences (id, data)
select coalesce(elem->>'id', gen_random_uuid()::text), elem
from sg_data, jsonb_array_elements(sg_data.value) elem
where sg_data.key = 'sequences' and jsonb_typeof(sg_data.value) = 'array'
on conflict (id) do nothing;

-- 3) Sanity check — row counts per table ---------------------------
select 'contacts' as tbl, count(*) from contacts
union all select 'followups', count(*) from followups
union all select 'suppliers', count(*) from suppliers
union all select 'socialleads', count(*) from socialleads
union all select 'prospects', count(*) from prospects
union all select 'sequences', count(*) from sequences
union all select 'approvals', count(*) from approvals;
