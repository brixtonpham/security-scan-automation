# Use a base image with known vulnerabilities
FROM ubuntu:14.04

# Install a vulnerable package (e.g., curl with known CVEs)
RUN apt-get update && apt-get install -y curl=7.35.0-1ubuntu2.20

# Create a dummy application
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

CMD ["bash"]
