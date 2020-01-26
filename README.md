An nginx image customized with https as the final purpose. And run the service as non-root, the module of ngx_brotli is compiled by default. Compared to the official image, it is more customized. Of course it means fewer people are suitable to use it

I am also not familiar with Linux systems because I run the service as non-root. The default nginx.conf may not be used directly. Because it does not have access to ports 80 and 443. Thanks to the port mapping of the docker image, I didn't pay much attention to this place. Even if the container is running at 8080 or other ports

## Usage

```
docker run kotomi/nginx-https-br:[tagname] -p 80: 8080
```
