# сборка проекта
FROM ubuntu:22.04 AS builder

# ставим всё необходимое для сборки
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# копируем исходники проекта
WORKDIR /app
COPY include/ ./include/
COPY src/ ./src/
COPY tests/ ./tests/
COPY CMakeLists.txt .

# собираем проект и тесты
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build

# финальный образ
FROM ubuntu:22.04

# минимальные зависимости для запуска
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# копируем только готовые исполняемые файлы из первого этапа
WORKDIR /app
COPY --from=builder /app/build/MazeGenerator .
COPY --from=builder /app/build/unit_tests .
COPY --from=builder /app/build/scenario_tests .

# точка входа по умолчанию — основная программа
CMD ["./MazeGenerator"]