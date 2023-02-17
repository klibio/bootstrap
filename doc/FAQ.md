# FAQ

## remarks for windows users (especially roaming profile)

Execute the following cmd `echo $HOME`inside git bash 

```bash
$ echo $HOME
/c/Users/peter
```

Output should be referencing a local folder, otherwise configure a USER scoped environment variable on windows. `HOME=%USERPROFILE%`

## no network/internet connection

Execute the following command to check if you have a proxy configure

```bash
# test that these proxy variables are configured
echo $http_proxy
echo $https_proxy
```

If they are empty you need to configure them. For identifying the proxy server which shoud be used. Proceed like this.
1. Open Edge browser
2. Open Settings
3. Inside the Settings bar use the Search and enter `Proxy`
4. In the results `Open your computer's proxy settings`
5. Check for the settings...

If `Automatic proxy setup` is configure copy the script address (url is generanlly ending in *.pac)

Open this file in e.g. Notepadd++ and search for lines containing "return".
This reveals you the possible proxy servers without analysing the full details of the script. 

Use one of the servers where line is `return "PROXY <server:port>"`

Full explanation here [Proxy Auto-Configuration (PAC) file](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file)

```bash
# configure the proxy server inside the current bash (or store permanently inside your ~/.bashrc) the following commands

$ export http_proxy=proxy.klib.io:3128
$ export https_proxy=proxy.klib.io:3128

$ curl --head -sI www.google.com | grep "HTTP/1.1 200 OK"
HTTP/1.1 200 OK
```
If you see line `HTTP/1.1 200 OK`, your internet connection is working.

**HINT:** In Enterprise environments there is ofthe NTLM v2 Authentication active. This is not supported by bash internet commands.

To make sure that you are authenticated against the proxy open the Edge browser and access and internet url. e.g. www.google.com

Afterwards you should be authenticated with the proxy server.

## Enterprise internet/network security tools e.g. "netskope client"

* make sure to de-activate for the initial installation library
