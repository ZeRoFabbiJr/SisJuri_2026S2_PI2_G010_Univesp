# ==============================================================================
# DOCKERFILE FRONTEND (Nginx Unprivileged) - HARDENED PRODUCTION BUILD
# ==============================================================================

FROM nginxinc/nginx-unprivileged:alpine-slim

USER root
# Instala cURL para garantir o funcionamento do Healthcheck
RUN apk add --no-cache curl

# Retorna para o usuário não-root oficial do Nginx (UID 101)
USER 101

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html/

EXPOSE 8080

# Healthcheck testando a resposta HTTP do Nginx
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://127.0.0.1:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
