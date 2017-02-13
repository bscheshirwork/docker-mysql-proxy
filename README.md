# mysql-proxy

# Usage with docker-compose

without
```
version: '2'

services:
  db:
    image: mysql:8.0.0
    restart: always
    ports:
      - "3307:3306" #for external connection
    volumes:
      - ../mysql-data/db:/var/lib/mysql #mysql-data
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: dbuser
      MYSQL_USER: dbuser
      MYSQL_PASSWORD: password
```

within
```
version: '2'

services:
  mysql:
    image: mysql:8.0.0
    restart: always
    expose:
      - "3306" #for service mysql-proxy
    ports:
      - "3307:3306" #for external connection
    volumes:
      - ../mysql-data/db:/var/lib/mysql #mysql-data
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: dbuser
      MYSQL_USER: dbuser
      MYSQL_PASSWORD: password
  db:
    image: bscheshir/mysqlproxy:0.8.5
    expose:
      - "3306" #for service php
    ports:
      - "3308:3306" #for external connection
    restart: always
    volumes: 
      - ../mysql-proxy/main.lua:/opt/main.lua
    environment:
      PROXY_DB_PORT: 3306
      REMOTE_DB_HOST: mysql
      REMOTE_DB_PORT: 3306
      PROXY_LUA_SCRIPT: "/opt/main.lua"
    depends_on:
      - mysql
```


# Query logging for mysql-proxy 
https://gist.github.com/simonw/1039751
```
local log_file = '/opt/mysql-proxy/mysql.log'

local fh = io.open(log_file, "a+")

function read_query( packet )
    if string.byte(packet) == proxy.COM_QUERY then
        local query = string.sub(packet, 2)
        fh:write( string.format("%s %6d -- %s \n", 
            os.date('%Y-%m-%d %H:%M:%S'), 
            proxy.connection.server["thread_id"], 
            query)) 
        fh:flush()
    end
end
```

# Query to stdout
For `docker-compose up` without `-d`
```
function read_query(packet)
   if string.byte(packet) == proxy.COM_QUERY then
	print(string.sub(packet, 2))
   end
end
```

# thanks

https://hub.docker.com/r/zwxajh/mysql-proxy
https://hub.docker.com/r/gediminaspuksmys/mysqlproxy/

#troubleshooting
If you can't create the chain `mysql` -> `mysql-proxy` -> `external client liten 0.0.0.0:3308`
check extends ports on the `mysql` service and/or add `expose` directly
```
    expose:
      - "3306" #for service mysql-proxy
```

You can create
 ```touch mysql-proxy/mysql.log```
before run the suite