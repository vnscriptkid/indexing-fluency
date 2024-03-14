# Scenario

## Goal
- Demonstrate lookup speed on event sourcing tables

## Demo
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create postgres table delivery_events (id int primary key, delivery_id uuid, event_type string, created_at timestamp, event_data jsonb)
create table delivery_events (id serial primary key, delivery_id uuid, event_type text, created_at timestamp, event_data jsonb);

-- Seeds 10 million records, for each delivery_id there's around 5-10 event_types
-- event_types: created, requested, picked, delivered, cancelled
DO $$
DECLARE
    event_types text[] := ARRAY['created', 'requested', 'picked', 'delivered', 'cancelled'];
    start_time timestamp := NOW() - INTERVAL '5 years';
    end_time timestamp := NOW();
    total_records int := 1000000;
    delivery_event_count int;
    current_delivery_id uuid;
BEGIN
    FOR i IN 1..total_records LOOP
        -- Randomly decide how many events this delivery_id will have (between 5 and 10)
        delivery_event_count := 5 + (random() * 6)::int;
        
        -- Generate a new delivery_id
        current_delivery_id := uuid_generate_v4();
        
        -- Insert 5 to 10 events for each delivery_id
        FOR j IN 1..delivery_event_count LOOP
            INSERT INTO delivery_events (delivery_id, event_type, created_at, event_data)
            VALUES (
                current_delivery_id,
                event_types[1 + (random() * (array_length(event_types, 1) - 1))::int],
                start_time + (random() * (extract(epoch from (end_time - start_time)))) * '1 second'::interval,
                '{}'
            );
        END LOOP;
    END LOOP;
END $$;

-- Count the number of records
select count(*) from delivery_events;

-- Randomly select a delivery_id
select delivery_id from delivery_events order by random() limit 1;

-- find by delivery_id
select * from delivery_events where delivery_id = '9bbda6ab-1a35-4be6-a2aa-a8570ca7e8ff';

-- Create index on delivery_id
create index delivery_events_delivery_id on delivery_events (delivery_id);

-- Create index on delivery_id and event_type
create index delivery_events_delivery_id_event_type on delivery_events (delivery_id, event_type);
```