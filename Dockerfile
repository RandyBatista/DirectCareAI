## Stage 1: Build React app

# Use the official Node.js runtime as the base image
FROM node:18-alpine AS client
# Set working directory for frontend
WORKDIR /app/client
# Copy package*.json to the working directory
COPY client/package*.json ./
# Install dependencies for the React app
RUN npm install
# Copy the entire application files to the container and Build the React app for production
COPY client/ . 
# Build the React app for production
RUN npm run build || { echo "Build failed"; exit 1; }

## Stage 2: Build FastAPI app (Backend)

# Use the official latest Python 3 stable version runtime as the base image
FROM python:3 AS server
# Set working directory for backend
WORKDIR /app/server
# Copy and install FastAPI dependencies to container
COPY server/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
# Copy FastAPI application files to the container
COPY . .
# Expose the FastAPI port
EXPOSE 8000
# Command to run FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

## Stage 3: Build PyMongo

FROM mongo:latest AS database
# install Python 3
RUN apt-get update && apt-get install -y python3 python3-pip
RUN apt-get -y install python3.7-dev
RUN pip3 install pymongo
EXPOSE 27017

# Stage 2: Nginx configuration stage
FROM nginx:alpine AS conf

# Copy the custom Nginx configuration from the local file system (generated via Install-Nginx.ps1)
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/NginxDev.conf /etc/nginx/conf.d/nginx.dev.conf
COPY conf/NginxProd.conf /etc/nginx/conf.d/nginx.prod.conf


# Expose Nginx port
EXPOSE 80

# Stage 3: Final Nginx serving stage
FROM nginx:alpine AS nginx

# Copy the React build files from the frontend build stage
COPY --from=client /app/client/build /usr/share/nginx/html

# Copy the custom Nginx configuration from the 'conf' stage
COPY --from=conf /etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=conf /etc/nginx/conf.d /etc/nginx/conf.d

# Expose Nginx port
EXPOSE 80

# Start Nginx in the background
CMD ["nginx", "-g", "daemon off;"]
