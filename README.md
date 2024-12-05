
# subscription_x_ui

### Description of the project

x-ui returns the inbounds port in the subscription, which can cause problems if X ray is running on one port (for example, 8443), and the server (via Nginx) on another port (for example, 443).

To solve this problem, I have developed my own subscription web server that integrates with xyi and replaces the port in the subscription response. Now clients will receive the correct port (for example, 443), which solves some problems.


## FAQ

### How it works

Xray runs on port 8443, which is the internal port to which all traffic is routed.

Nginx redirects requests from public port 443 to Xray.

The subscription server processes requests received from the client:

- Retrieves subscription data from the x-ui panel.
- Replaces port 8443 with 443 in the response.
- Encodes in base64.
- Returns the correct response to the client with a public port.


## API Reference

#### Get items

```http
  GET /sub/sub_key
```


## Environment Variables

By default, it takes it from config.py if not filled in in docker-compose.bml

`DB_PATCH`

`SERVER_ADDRESS`

`SERVER_PORT`

`PUBLIC_KEY`

`SID`

`SNI`

`FP`

`TYPE`

`SECURITY`

`SPX`

`FLOW`
## Run

Install dependencies

```bash
  sudo apt update
  sudo apt install git -y
  sudo apt install -y docker.io
  sudo apt install -y docker-compose
```

Clone the project

```bash
  git clone https://github.com/vilyzo/subscription_x_ui.git
```

Go to the project directory

```bash
  cd my-project
```
Change for your server
docker-compose.yml

- SERVER_ADDRESS
- PUBLIC_KEY
- SID
- SNI
- SPX

Enable the subscription in the panel
 - Subscription Port = any
 - The root path of the subscription URL = /sub/
 - The URI of the reverse proxy = https://example.com/sub/

 Nginx
```
        location /sub/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_cache_bypass $http_upgrade;
        }
```

Start the server

```bash
  sudo docker-compose up --build -d
```


## Usage example

- The client sends a subscription request via https://your-domain.com

- Nginx redirects the request to the subscription server
- The subscription server requests data from xui, compiles a response, and returns the result to the client
## Tech Stack

**Server:** Python 3.9, FastAPI, SQLite, Docker 26.1.3, Ubuntu 24.04.1 LTS, x-ui 2.4.8


## Authors

- [@vilyzo](https://www.github.com/vilyzo)

