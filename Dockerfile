## Stage 1: Build React app

# Use the official Node.js runtime as the base image
FROM node:22.11.0-slim AS client
# Set working directory for frontend
WORKDIR /app/client
# Copy package files to the working directory
COPY client/package.json client/package-lock.json ./
# Install dependencies
RUN npm install
# Copy the entire application files to the container and Build the React app for production
COPY client/ . 
# Build the React app for production
RUN npm run build || { echo "Client Build failed"; exit 1; }

## Stage 2: Build FastAPI app (Backend)

# Use the official latest Python 3 stable version runtime as the base image
FROM python:3.11-slim AS server
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

# Stage 4: Nginx configuration stage
FROM nginx:alpine AS conf
# Copy the custom Nginx configuration from the local file system (generated via Install-Nginx.ps1)
COPY ./nginx/conf/nginx.conf /etc/nginx/nginx.conf
# Expose Nginx port
EXPOSE 80
# Stage 3: Final Nginx serving stage
FROM nginx:alpine AS nginx
# Copy the React build files from the frontend build stage
COPY --from=client /app/client/build /usr/share/nginx/html
# Copy the custom Nginx configuration from the 'conf' stage
COPY --from=conf /etc/nginx/nginx.conf /etc/nginx/nginx.conf
# Expose Nginx port
EXPOSE 80

# Start Nginx in the background
CMD ["nginx", "-g", "daemon off;"]
