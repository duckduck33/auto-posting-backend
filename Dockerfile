FROM python:3.11-slim

# 시스템 패키지 업데이트 및 Chrome 설치
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# ChromeDriver 설치 (안정적인 버전 사용)
RUN echo "=== Chrome 설치 확인 ===" \
    && google-chrome --version \
    && echo "=== 안정적인 ChromeDriver 버전 사용 ===" \
    && wget -q "https://chromedriver.storage.googleapis.com/120.0.6099.109/chromedriver_linux64.zip" -O /tmp/chromedriver.zip \
    && ls -la /tmp/chromedriver.zip \
    && echo "=== ChromeDriver 압축 해제 ===" \
    && unzip /tmp/chromedriver.zip -d /tmp/ \
    && ls -la /tmp/ \
    && echo "=== ChromeDriver 설치 ===" \
    && mv /tmp/chromedriver /usr/local/bin/ \
    && ls -la /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && echo "=== ChromeDriver 테스트 ===" \
    && /usr/local/bin/chromedriver --version \
    && rm -rf /tmp/chromedriver* \
    && echo "ChromeDriver 설치 완료: $(which chromedriver)"

# 작업 디렉토리 설정
WORKDIR /app

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 8000

# 애플리케이션 실행
CMD ["python", "main.py"] 