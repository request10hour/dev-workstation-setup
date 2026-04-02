FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
ENV APP_ENV=dev
COPY web/ /usr/share/nginx/html/
EXPOSE 80
