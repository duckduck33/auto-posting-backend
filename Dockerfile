FROM python:3.11-slim

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 안정적인 Chrome 버전 설치 (115.0.5790.170)
RUN echo "=== Installing Google Chrome 115.0.5790.170 ===" \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable=115.0.5790.170-1 \
    && echo "Google Chrome version: $(google-chrome --version)"

# ChromeDriver 설치 (Chrome 115.0.5790.170에 맞춤)
RUN echo "=== ChromeDriver Installation for Chrome 115.0.5790.170 ===" \
    && CHROMEDRIVER_VERSION="115.0.5790.170" \
    && echo "Downloading ChromeDriver version: $CHROMEDRIVER_VERSION" \
    && wget -q "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" -O /tmp/chromedriver.zip \
    && ls -la /tmp/chromedriver.zip \
    && echo "Unzipping ChromeDriver..." \
    && unzip /tmp/chromedriver.zip -d /tmp/ \
    && ls -la /tmp/ \
    && echo "Moving ChromeDriver to /usr/local/bin/" \
    && mv /tmp/chromedriver /usr/local/bin/ \
    && ls -la /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && echo "Testing ChromeDriver installation..." \
    && /usr/local/bin/chromedriver --version \
    && rm -rf /tmp/chromedriver* \
    && echo "ChromeDriver installation complete: $(which chromedriver)"

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