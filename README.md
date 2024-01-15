# streamripper-nginx
Streamripper rips and splits online stream,
Nginx hosts complete tracks with fancy indexing

Edit docker-compose.yml for your needs and run
```
docker-compose up --build
```

## Branch lite: streamripper+nginx
you need to clean up ./streamripper-nginx/incomplete dir occasionally because
streamripper does not remove incomplete chunks.

