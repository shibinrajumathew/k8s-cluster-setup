# node-backend/Dockerfile
FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Expose port
EXPOSE 5000

# Pass environment variable to the container

ARG ACCESSTOKEN
ENV ACCESSTOKEN=${ACCESSTOKEN}

# Start the app
CMD ["node", "index.js"]
