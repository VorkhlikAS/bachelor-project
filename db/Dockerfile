FROM postgres:alpine

ENV POSTGRES_PASSWORD=postgres

ENV POSTGRES_USER=postgres

EXPOSE 5432

COPY bak_plain.sql /docker-entrypoint-initdb.d/