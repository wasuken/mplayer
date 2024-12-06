FROM debian:slim-bookworm

ENV ANDROID_SDK_ROOT="/opt/android-sdk" \
    FLUTTER_ROOT="/opt/flutter" \
    FLUTTER_VERSION="3.19.1"

# 必要最小限のパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    openjdk-17-jdk-headless \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Android SDK Command-line toolsのインストール
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-*_latest.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm commandlinetools-linux-*_latest.zip

# 環境変数の設定
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${FLUTTER_ROOT}/bin

# Android SDKのコンポーネントをインストール
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# Flutterのインストール
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_ROOT}

# Flutterの初期設定
RUN flutter config --no-analytics && \
    flutter precache && \
    flutter doctor

WORKDIR /app

# プロジェクトのマウントポイントを作成
VOLUME ["/app"]

# デフォルトコマンド
CMD ["flutter", "doctor"]
