# Use Node.js as base image
FROM node:20

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose port and start the server
EXPOSE 8080
CMD ["npm", "start"]