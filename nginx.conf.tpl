
upstream mezzanine {
    server mezzanine:8000;
}

server {
    # For a more complex example, see:
    # https://github.com/stephenmcd/mezzanine/blob/master/mezzanine/project_template/deploy/nginx.conf.template

    listen 8080 default_server;
    server_name _;

    location / {
        proxy_redirect      off;
        proxy_set_header    Host                    $host;
        proxy_set_header    X-Real-IP               $remote_addr;
        proxy_set_header    X-Forwarded-For         $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto       $scheme;
        proxy_pass          http://mezzanine;
    }

    location /static/ {
        root            /srv/mezzanine/MEZZANINE_PROJECT/;
    }

    location /robots.txt {
        root            /srv/mezzanine/MEZZANINE_PROJECT/static;
        access_log      off;
        log_not_found   off;
    }

    location /favicon.ico {
        root            /srv/mezzanine/MEZZANINE_PROJECT/static/img;
        access_log      off;
        log_not_found   off;
    }
}

