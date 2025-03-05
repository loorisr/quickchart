# Stage 1: Build stage
FROM node:22-alpine AS build

WORKDIR /quickchart

# Install necessary packages for building
RUN apk add --no-cache git build-base cairo-dev pango-dev 
    
# Copy package.json and yarn.lock
COPY package*.json yarn.lock ./

# Install dependencies
RUN yarn install --production

# Stage 2: Runtime stage
FROM node:22-alpine

ENV NODE_ENV production

WORKDIR /quickchart

# Install runtime dependencies
RUN apk add --no-cache cairo pango libjpeg-turbo librsvg libimagequant vips graphviz

# Additional fonts 65 mo
#RUN apk add --no-cache ttf-dejavu ttf-droid ttf-freefont ttf-liberation font-noto font-noto-emoji fontconfig
#RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community font-wqy-zenhei

# Copy built application from the build stage
COPY --from=build /quickchart .

# Copy application files
COPY *.js ./
COPY lib/*.js lib/

# Expose the application port
EXPOSE 3400

# Set the entrypoint
ENTRYPOINT ["node", "--max-http-header-size=65536", "index.js"]
