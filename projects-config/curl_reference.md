# Curl HTTP Scripting Reference

A practical reference for using **curl as a scripting tool for HTTP requests**.

This guide summarizes key ideas from curl's HTTP scripting documentation and organizes them for quick lookup.

---

# 1. Overview

`curl` is a command-line tool used to transfer data using URLs. It supports many protocols, but this guide focuses on **HTTP scripting**.

Typical use cases:

* Automating web requests
* Scraping data
* Testing APIs
* Simulating browser behavior
* Uploading files
* Logging into websites
* Debugging HTTP interactions

Curl **does not automate workflows by itself**. It sends requests and receives responses. For automation you usually combine it with:

* Bash
* Python
* Makefiles
* CI scripts

---

# 2. HTTP Protocol Basics

HTTP is a **text-based protocol over TCP/IP**.

### Request structure

```
METHOD /path HTTP/1.1
Header: value
Header: value

BODY
```

Example:

```
GET /index.html HTTP/1.1
Host: example.com
User-Agent: curl/8.x
```

### Response structure

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234

<html>...</html>
```

Components:

| Part    | Description              |
| ------- | ------------------------ |
| Method  | GET, POST, PUT, HEAD etc |
| Headers | metadata                 |
| Body    | actual content           |

---

# 3. Debugging Requests

## Verbose Mode

Most useful debugging flag.

```bash
curl -v https://example.com
```

Shows:

* Request headers
* Response headers
* Connection details

---

## Full Trace

Logs **everything sent and received**.

```bash
curl --trace-ascii debug.txt https://example.com
```

---

## Add Timestamps

```bash
curl --trace-ascii debug.txt --trace-time https://example.com
```

---

## Identify Parallel Transfers

```bash
curl --trace-ascii debug.txt --trace-ids https://example.com
```

---

# 4. URL Structure

A URL format:

```
scheme://user:password@host:port/path?query
```

Example:

```
https://user:pass@example.com:8080/api/data?id=3
```

Components:

| Part   | Example      |
| ------ | ------------ |
| Scheme | http / https |
| Host   | example.com  |
| Port   | 80, 443      |
| Path   | /api/data    |
| Query  | ?id=3        |

---

# 5. Basic Requests

## GET

Retrieve a resource.

```bash
curl https://example.com
```

---

## Show Headers

```bash
curl -i https://example.com
```

---

## HEAD Request

Fetch only headers.

```bash
curl -I https://example.com
```

---

# 6. Multiple URLs

Curl can fetch multiple URLs in one command.

```bash
curl http://site1.com http://site2.com
```

---

## Different Requests Using `--next`

```bash
curl -I http://example.com --next http://example.com
```

Example:

```
HEAD request
then GET request
```

---

# 7. HTML Form Requests

Web forms usually use **GET or POST**.

---

# 7.1 GET Forms

HTML example:

```html
<form method="GET" action="search.cgi">
```

Browser generates:

```
search.cgi?query=term
```

Curl equivalent:

```bash
curl "http://example.com/search.cgi?query=term"
```

---

# 7.2 POST Forms

HTML:

```html
<form method="POST" action="submit.cgi">
```

Curl:

```bash
curl --data "name=value&age=25" http://example.com/submit.cgi
```

---

## URL Encoding

Spaces must be encoded.

```
space -> %20
```

Example:

```bash
curl --data-urlencode "name=John Doe" http://example.com
```

---

# 8. Uploading Files

Multipart upload:

```bash
curl --form upload=@file.txt http://example.com/upload
```

Equivalent HTML form:

```
enctype="multipart/form-data"
```

---

# 9. HTTP PUT Upload

Upload file directly.

```bash
curl --upload-file file.txt http://example.com/upload
```

---

# 10. Authentication

## Basic Authentication

```bash
curl -u username:password http://example.com
```

or

```
http://username:password@example.com
```

---

## Other Auth Types

Curl supports:

```
--digest
--ntlm
--negotiate
--anyauth
```

---

# 11. Proxy Authentication

Example:

```bash
curl --proxy http://proxy.example.com:4321 http://example.com
```

With credentials:

```bash
curl --proxy-user user:password http://example.com
```

---

# 12. Custom Headers

Add headers:

```bash
curl -H "Header: value" https://example.com
```

Example:

```bash
curl -H "Content-Type: application/json" https://example.com
```

---

## Remove a header

```bash
curl -H "Host:" http://example.com
```

---

# 13. Referer Header

Spoof referer:

```bash
curl --referer https://example.com https://target.com
```

---

# 14. User Agent Spoofing

Websites may serve different pages based on user agent.

Example:

```bash
curl -A "Mozilla/5.0" https://example.com
```

---

# 15. Redirects

By default curl **does not follow redirects**.

Enable:

```bash
curl -L https://example.com
```

Important behavior:

```
POST -> redirect -> GET
```

---

# 16. Cookies

Cookies maintain session state.

---

## Send cookie

```bash
curl --cookie "name=value" https://example.com
```

---

## Save cookies

```bash
curl -c cookies.txt https://example.com
```

---

## Use stored cookies

```bash
curl -b cookies.txt https://example.com
```

---

## Save and reuse cookies

```bash
curl -b cookies.txt -c cookies.txt https://example.com
```

---

# 17. HTTPS

Secure HTTP using TLS.

Example:

```bash
curl https://secure.example.com
```

---

## Use client certificate

```bash
curl --cert mycert.pem https://example.com
```

---

## Custom CA certificate

```bash
curl --cacert ca-bundle.pem https://example.com
```

---

## Skip certificate validation

(Not recommended)

```bash
curl -k https://example.com
```

---

# 18. Custom Request Methods

Change HTTP method:

```bash
curl -X DELETE https://example.com/api
```

---

Example with headers and data:

```bash
curl \
  -X PROPFIND \
  -H "Content-Type: text/xml" \
  --data "<xml>" \
  https://example.com
```

---

# 19. Web Login Automation

Typical login flow:

1. Visit login page
2. Receive cookies
3. Submit login form
4. Maintain session cookies

Example workflow:

### Step 1 — get login page

```bash
curl -c cookies.txt https://example.com/login
```

### Step 2 — send login request

```bash
curl \
  -b cookies.txt \
  -c cookies.txt \
  -d "username=user&password=pass" \
  https://example.com/login
```

---

### Important notes

Login forms may include:

* hidden fields
* CSRF tokens
* JavaScript cookie generation

Sometimes you must inspect browser traffic.

---

# 20. Debugging Real Websites

If curl behaves differently than a browser:

### Check

* cookies
* headers
* user agent
* referer
* POST fields

---

### Useful tools

Browser developer tools:

```
Network tab
```

Shows:

* full request
* headers
* payload
* cookies

---

### Network capture

Tools:

```
Wireshark
tcpdump
```

For HTTPS debugging:

```
SSLKEYLOGFILE
```

---

# 21. Common Curl Recipes

## Download file

```bash
curl -O https://example.com/file.zip
```

---

## Save to custom filename

```bash
curl -o file.zip https://example.com/file.zip
```

---

## JSON API request

```bash
curl -H "Content-Type: application/json" \
     -d '{"name":"John"}' \
     https://api.example.com
```

---

## API token

```bash
curl -H "Authorization: Bearer TOKEN" https://api.example.com
```

---

# 22. Useful Curl Flags Cheat Sheet

| Flag | Purpose                   |
| ---- | ------------------------- |
| `-v` | verbose                   |
| `-i` | include headers           |
| `-I` | HEAD request              |
| `-L` | follow redirects          |
| `-H` | custom header             |
| `-A` | user agent                |
| `-d` | POST data                 |
| `-F` | multipart form            |
| `-b` | send cookies              |
| `-c` | save cookies              |
| `-u` | authentication            |
| `-X` | custom method             |
| `-o` | output file               |
| `-O` | save with remote filename |

---

# 23. Learning Resources

## Official Documentation

* [https://curl.se/docs/](https://curl.se/docs/)
* [https://curl.se/docs/manpage.html](https://curl.se/docs/manpage.html)
* [https://everything.curl.dev/](https://everything.curl.dev/)

**Everything curl** is the best deep resource.

---

# 24. Advanced Topics to Explore

## HTTP API scripting

Learn:

* REST APIs
* JSON payloads
* authentication tokens

Resources:

* REST API design
* HTTP RFCs

---

## Bash HTTP automation

Use curl with:

```
jq
xargs
sed
awk
```

Example pipeline:

```
curl API | jq | grep | awk
```

---

## Advanced Curl Features

Study:

```
--retry
--limit-rate
--parallel
--compressed
--write-out
```

---

## Networking knowledge

Understanding these improves curl usage:

* TCP/IP
* TLS
* HTTP/1.1 vs HTTP/2
* DNS

---

## Books / Guides

Recommended reading:

* **Everything Curl – Daniel Stenberg**
* **HTTP: The Definitive Guide**
* **Web API Design**

---

# 25. Useful Tools for HTTP Scripting

| Tool      | Purpose                    |
| --------- | -------------------------- |
| curl      | HTTP client                |
| jq        | JSON processing            |
| httpie    | human-friendly HTTP client |
| mitmproxy | inspect HTTP traffic       |
| Wireshark | packet analysis            |

---

# 26. Practical Exercises

Try scripting:

1. Download API data automatically
2. Login to a website via curl
3. Upload files to a server
4. Automate website scraping
5. Simulate browser requests
6. advanced API scripting
7. scraping workflows
8. bash + curl automation patterns

---
