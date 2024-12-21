## Stage 1: Build React app

# Use the official Node.js runtime as the base image
FROM node:22.12.0 AS frontend
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
FROM python:3 AS backend
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

## Stage 4: Serve with Nginx

# Use the official nginx image as the base image
FROM nginx:alpine AS nginx
# Copy React build files from the frontend stage to Nginx's HTML directory
COPY --from=frontend /app/client/build /usr/share/nginx/html
# Copy the custom Nginx configurations for both development and production
COPY nginx/nginx.dev.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.prod.conf /etc/nginx/conf.d/default.conf
# Expose Nginx port
EXPOSE 80
# Start Nginx in the background
CMD ["nginx", "-g", "daemon off;"]