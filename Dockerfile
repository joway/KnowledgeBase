FROM orchardup/nginx
ADD wiki/ /var/www
CMD 'nginx'
