# NGINX Resources

## In Nginx configuration, you can't directly use Windows-style paths with backslashes (\) inside the configuration file because backslashes are escape characters in Nginx's configuration syntax. 

## Sources for Error Logging documentation.

- https://www.youtube.com/watch?v=toTe2RYLbSo&list=PLFN0wSP_fWCd-t5EVrP8yTBKMzMig1-I0
- https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
- https://nginx.org/en/docs/ngx_core_module.html#error_log


nginx -e "C:\nginx\logs\error.log" -c "C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\conf\nginx.conf"

nginx -e "C:\nginx\logs\error.log" -c "C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\conf\nginx.conf"
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
