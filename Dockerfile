FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY public /usr/share/nginx/html
EXPOSE 8080
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
