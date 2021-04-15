EXTENSION = pgrollup
DATA = pgrollup--1.0.sql
DOCS = README.md 
REGRESS = $(shell sh -c "ls sql | sed 's/\..*//' | sed 's;sql/;;' | xargs echo" )

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
