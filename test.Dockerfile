# Dockerfile demo - sử dụng Ubuntu cũ
FROM ubuntu:16.04

# (Có thể thêm vài lệnh cài đặt nếu muốn demo)
RUN apt-get update && apt-get install -y curl

# Đặt lệnh entrypoint hoặc cmd tùy ý.
CMD ["bash"]
