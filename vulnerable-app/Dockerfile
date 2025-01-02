# Sử dụng Node.js version cũ đã biết có lỗ hổng
FROM node:14.17.0

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .

EXPOSE 3000
CMD ["npm", "start"]