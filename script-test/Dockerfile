# 1. Temel Python imajını kullan
FROM python:3.9-slim

# 2. Container içinde /app adında bir çalışma dizini oluştur
WORKDIR /app

# 3. Önce gereksinim dosyasını kopyala ve kur (Cache optimizasyonu için)
COPY requirements.txt .
RUN pip install -r requirements.txt

# 4. Projenin geri kalan tüm dosyalarını kopyala
COPY . .

# 5. Uygulama 5000 portunu dinliyor
EXPOSE 8080

# 6. Container başladığında uygulamayı çalıştıracak komut
CMD ["python", "app.py"]
