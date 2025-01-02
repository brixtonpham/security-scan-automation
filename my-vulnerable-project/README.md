# my-vulnerable-project

Dự án mẫu chứa các lỗ hổng để thử nghiệm với Snyk và Trivy.

## Hướng dẫn

### 1. Cài đặt
```bash
npm install
```

### 2. Chạy thử app
```bash
node index.js
```

### 3. Quét bằng Snyk
```bash
snyk test
```
Hoặc, để quét container (nếu build Docker image):
```bash
docker build -t vuln-demo .
snyk container test vuln-demo
```

### 4. Quét bằng Trivy
```bash
docker build -t vuln-demo .
trivy image vuln-demo
```
Hoặc quét file system:
```bash
trivy fs .
```
