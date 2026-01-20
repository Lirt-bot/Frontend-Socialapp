# ===== 1. Build stage =====
FROM node:20-alpine AS build
WORKDIR /app

ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Kopiera package-filer först (för cache)
COPY package*.json ./
RUN npm install

# Kopiera resten av koden
COPY . .

# Bygg frontend
RUN npm run build

# ===== 2. Production stage =====
FROM nginx:alpine

# Ta bort default nginx-config
RUN rm /etc/nginx/conf.d/default.conf

# Kopiera build-resultatet
COPY --from=build /app/dist /usr/share/nginx/html

# Kopiera nginx template
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Nginx kommer automatiskt att ersätta $PORT i template-filen
CMD ["nginx", "-g", "daemon off;"]
