CREATE OR REPLACE FUNCTION generate_clickhouse_create(tablename TEXT)
RETURNS TEXT AS
$$
DECLARE
    rec RECORD;
    ch_type TEXT;
    create_table_command TEXT := 'CREATE TABLE clickhouse_' || tablename || ' (';
BEGIN
    FOR rec IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = tablename
    LOOP
        -- Mapeo de tipos de datos de PostgreSQL a ClickHouse
        IF rec.data_type = 'integer' THEN
            ch_type := 'Int32';
        ELSIF rec.data_type = 'smallint' THEN
            ch_type := 'Int16';
        ELSIF rec.data_type = 'bigint' THEN
            ch_type := 'Int64';
        ELSIF rec.data_type = 'real' THEN
            ch_type := 'Float32';
        ELSIF rec.data_type = 'double precision' THEN
            ch_type := 'Float64';
        ELSIF rec.data_type = 'boolean' THEN
            ch_type := 'UInt8';
        ELSIF rec.data_type IN ('text', 'character', 'varchar', 'character varying') THEN
            ch_type := 'String';
        ELSIF rec.data_type = 'date' THEN
            ch_type := 'Date';
        ELSIF rec.data_type = 'timestamp with time zone' THEN
            ch_type := 'DateTime';
        ELSIF rec.data_type = 'timestamp with time zone' THEN
            ch_type := 'DateTime';
        ELSIF rec.data_type = 'timestamp without time zone' THEN
            ch_type := 'String';
        ELSIF rec.data_type = 'json' THEN
            ch_type := 'String';
        ELSIF rec.data_type = 'uuid' THEN
            ch_type := 'UUID';
        ELSIF rec.data_type = 'char' THEN
            ch_type := 'FixedString(1)';
        ELSE
            ch_type := 'String'; -- Default to String if type is unsupported
        END IF;

        create_table_command := create_table_command || rec.column_name || ' ' || ch_type || ', ';
    END LOOP;

    create_table_command := rtrim(create_table_command, ', ') || ') ENGINE = MergeTree() ORDER BY tuple();';

    RETURN create_table_command;
END;
$$ LANGUAGE plpgsql;

-- To use
-- SELECT * FROM generate_clickhouse_create('you-table-name')
