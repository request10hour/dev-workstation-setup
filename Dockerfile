FROM nginx:1.29-alpine

LABEL org.opencontainers.image.title="workstation-nginx-demo"
LABEL org.opencontainers.image.description="Static web server for the AI/SW workstation mission"

ENV APP_ENV=mission

COPY app/ /usr/share/nginx/html/
