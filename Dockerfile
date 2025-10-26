FROM mysql:8.0

ENV MYSQL_DATABASE=FiveGears

COPY ./SQL5Gears.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306
