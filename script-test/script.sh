#!/bin/bash

# --- DEĞİŞKENLER ---
DEFAULT_IMAGE_NAME="projem-dockerized_flight"
DEFAULT_CONTAINER_NAME="projem-container_flight"
DEFAULT_HOST_PORT="8081"
# .NET 8 projemizin dinlediği port 8080 olduğu için bunu düzeltiyoruz.
CONTAINER_PORT="8080"
# .env dosyasının adı
ENV_FILE=".env"

# --- MOD KONTROLÜ (SESSİZ MOD) ---
SILENT_MODE=false
if [[ "$1" == "-s" || "$1" == "--silent" ]]; then
    SILENT_MODE=true
    echo "🤫 Sessiz mod aktif edildi. Varsayılan değerler kullanılacak."
fi

# Eğer sessiz mod aktif değilse, kullanıcıdan bilgi al.
if [ "$SILENT_MODE" = false ]; then
    echo "🚀 Proje Dockerize Etme Script'i Başlatıldı..."
    echo "------------------------------------------------"
    read -p "Hangi HOST portunda yayın yapılsın? [Varsayılan: ${DEFAULT_HOST_PORT}]: " HOST_PORT
    read -p "Container adı ne olsun? [Varsayılan: ${DEFAULT_CONTAINER_NAME}]: " CONTAINER_NAME
    read -p "Image için bir etiket (tag) girin [Varsayılan: latest]: " IMAGE_TAG
fi

# Değişkenleri ata (Normal mod veya sessiz mod için)
HOST_PORT=${HOST_PORT:-$DEFAULT_HOST_PORT}
CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}
IMAGE_TAG=${IMAGE_TAG:-latest}
FULL_IMAGE_NAME="${DEFAULT_IMAGE_NAME}:${IMAGE_TAG}"

echo "------------------------------------------------"
echo "Ayarlar tamamlandı:"
echo "🔹 Image Adı: ${FULL_IMAGE_NAME}"
echo "🔹 Container Adı: ${CONTAINER_NAME}"
echo "🔹 Yayın Portu: http://localhost:${HOST_PORT}"
echo "------------------------------------------------"

# --- MEVCUT CONTAINER'I TEMİZLEME ---
if [ "$(docker ps -a -q -f name=^/${CONTAINER_NAME}$)" ]; then
    if [ "$SILENT_MODE" = true ]; then
        confirmation="e" # Sessiz modda otomatik onayla
    else
        read -p "⚠  '${CONTAINER_NAME}' adında bir container zaten mevcut. Kaldırılsın mı? (e/h): " confirmation
    fi

    if [[ "$confirmation" == "e" || "$confirmation" == "E" ]]; then
        echo "🔹 Mevcut container durduruluyor ve kaldırılıyor..."
        docker stop ${CONTAINER_NAME} >/dev/null && docker rm ${CONTAINER_NAME} >/dev/null
    else
        echo "❌ İşlem iptal edildi."
        exit 1
    fi
fi

# --- DOCKER IMAGE OLUŞTURMA ---
echo "⏳ Docker image oluşturuluyor: ${FULL_IMAGE_NAME}"
if ! docker build -t ${FULL_IMAGE_NAME} .; then
    echo "❌ Docker image oluşturulamadı!"
    exit 1
fi
echo "✅ Docker image başarıyla oluşturuldu."

# --- DOCKER RUN PARAMETRELERİNİ HAZIRLAMA ---
DOCKER_RUN_PARAMS="-d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${CONTAINER_NAME}"

# GELİŞTİRME 1: .env dosyasını otomatik olarak ekle
if [ -f "$ENV_FILE" ]; then
    echo "🔹 bulunan '${ENV_FILE}' dosyası container'a ekleniyor."
    DOCKER_RUN_PARAMS+=" --env-file ${ENV_FILE}"
fi

# .NET 8 için gerekli olan ortam değişkenini ekle
DOCKER_RUN_PARAMS+=" -e ASPNETCORE_URLS=http://+:8080"

# GELİŞTİRME 2: Canlı geliştirme için Volume Mount sorusu
if [ "$SILENT_MODE" = false ]; then
    read -p " Canlı geliştirme için mevcut dizin container'a mount edilsin mi? (e/h): " mount_volume
    if [[ "$mount_volume" == "e" || "$mount_volume" == "E" ]]; then
        # Not: Hedef yolu Dockerfile'daki WORKDIR ile uyumlu olmalı!
        DOCKER_RUN_PARAMS+=" -v $(pwd):/app"
        echo "🔹 Canlı geliştirme modu aktif. Kod değişiklikleri anında yansıyacak."
    fi
fi

# --- CONTAINER BAŞLATMA ---
echo "⏳ Container başlatılıyor: ${CONTAINER_NAME}"
if ! docker run ${DOCKER_RUN_PARAMS} ${FULL_IMAGE_NAME}; then
    echo "❌ Container başlatılamadı!"
    exit 1
fi

echo "🎉 Proje başarıyla container içine alındı! 👉 http://localhost:${HOST_PORT}"

# GELİŞTİRME 3: Otomatik Log Takibi
if [ "$SILENT_MODE" = false ]; then
    read -p " Container logları canlı olarak takip edilsin mi? (e/h): " tail_logs
    if [[ "$tail_logs" == "e" || "$tail_logs" == "E" ]]; then
        echo "📝 Loglar takip ediliyor... (Çıkmak için CTRL+C)"
        docker logs -f ${CONTAINER_NAME}
    fi
fi
