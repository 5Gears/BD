FROM mysql:8.0
ENV MYSQL_DATABASE=FiveGears
COPY ./SQL5Gears.sql /docker-entrypoint-initdb.d/001-init.sql
COPY ./SQLInserts.sql /docker-entrypoint-initdb.d/002-inserts.sql
EXPOSE 3306
