# NGINX Resources

## Cheatsheets

- [NGINX Cheatsheet by Vishnu](https://vishnu.hashnode.dev/nginx-cheatsheet)

## Official Documentation

- [NGINX Product Documentation](https://docs.nginx.com)
- [NGINX Core Documentation](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header)

https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header

## Examples

- [NGINX Reverse Proxy Example](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

## Testing NGINX Configuration for Syntax Errors

After making changes to your NGINX configuration files, it’s essential to check for syntax errors before applying them. Use the following command:

```bash
nginx -t
```

To apply the changes after a successful test, reload NGINX:

```bash
sudo systemctl reload nginx
```
Command-line parameters

https://nginx.org/en/docs/switches.html
https://www.keycdn.com/support/nginx-commands