# react-frontend/Dockerfile
FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Build the app with environment variable
ARG ACCESSTOKEN
ENV REACT_APP_ACCESSTOKEN=$ACCESSTOKEN
RUN npm run build

# Install serve to serve the app
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Start the app
CMD ["serve", "-s", "build"]
