FROM oven/bun
ARG USER
ARG UID=1000
ARG GID
ENV NODE_ENV=production
WORKDIR /app
EXPOSE 4100

CMD ["bun", "-b", "start"]
