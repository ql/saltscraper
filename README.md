# Saltscraper

This is a demo project of a multithreaded web-scraper

## Setup
```
bundle install
./bin/setup
```

## Usage

```
./bin/scraper -vl url-list.txt
```

## Dashboard

Use with caution, Sqlite3 don't really support concurrent access, so both scraper/server can fail if used at the same time

```
./bin/server
```


