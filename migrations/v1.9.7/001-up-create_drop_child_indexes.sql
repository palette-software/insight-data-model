CREATE OR REPLACE FUNCTION drop_child_indexes (index_name varchar)
RETURNS VOID
AS
$functionBody$
DECLARE
  child_index_name varchar;
BEGIN

	  FOR child_index_name IN
	    SELECT child_index.indexrelid::regclass
	      FROM pg_index AS parent_index
	        -- Find the partitioning scheme for the table the index is on
        INNER JOIN pg_partition ON pg_partition.parrelid = parent_index.indrelid
	        -- Follow the links through to the individual partitions
        INNER JOIN pg_partition_rule ON pg_partition_rule.paroid = pg_partition.oid
	        -- Find the indexes on each partition
        INNER JOIN pg_index AS child_index ON child_index.indrelid = pg_partition_rule.parchildrelid
	          -- Which are on the same field as the named index
          AND child_index.indkey = parent_index.indkey
	          -- Using the same comparison operator
          AND child_index.indclass = parent_index.indclass
	      -- Filtered for the index we're trying to drop
      WHERE parent_index.indexrelid = $1::regclass::oid
      -- Drop leaves first, even if it doesn't really matter in this case
      ORDER BY pg_partition.parlevel DESC

LOOP
	  RAISE NOTICE 'DROP INDEX %', child_index_name||' ';
	  EXECUTE 'DROP INDEX '||child_index_name||';';
END LOOP;

END
$functionBody$
LANGUAGE plpgsql;
