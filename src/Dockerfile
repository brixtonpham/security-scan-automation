# Dockerfile for Node.js with Lodash

# Use a Node.js base image
FROM node:14

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json for dependency installation
COPY package.json package-lock.json ./

# Install dependencies, including Lodash
RUN npm install

# Copy application code
COPY . ./

# Expose application port (optional, adjust based on your app)
EXPOSE 3000

# Command to run the application
CMD ["node", "index.js"]
