# Sử dụng Ubuntu 14.04 (đã EOL)
FROM ubuntu:14.04

# Cập nhật và cài thêm một số gói
RUN apt-get update && apt-get install -y curl

# Tạo thư mục cho app test
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy package.json và cài dependencies
COPY package.json /usr/src/app/
RUN apt-get update && apt-get install -y nodejs npm     && npm install

# Copy code
COPY . /usr/src/app

# Chạy app (demo) a
CMD ["node", "index.js"]
