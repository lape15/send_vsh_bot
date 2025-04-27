
FROM debian:bullseye-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set timezone
ENV TZ=Europe/Berlin


WORKDIR /app


COPY check_vsh_bot.sh .


RUN chmod +x check_vsh_bot.sh


CMD ["./check_vsh_bot.sh"]

