FROM node:16-alpine as dependencies
# ARG BRANCH
WORKDIR /app

COPY package.json ./
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile

FROM node:16-alpine as builder
# ARG BRANCH
WORKDIR /app
COPY . .
# RUN echo $BRANCH
# COPY "config/.env.$BRANCH" .env.production
COPY --from=dependencies /app/node_modules ./node_modules
RUN yarn build

FROM node:16-alpine AS server
# ARG BRANCH
WORKDIR /app
ENV NODE_ENV production
# RUN yarn install --production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public
COPY --from=builder /app/yarn.lock ./yarn.lock
COPY --from=builder /app/*.config.js ./
# RUN echo $BRANCH
# COPY "config/.env.$BRANCH" .env.production
# COPY --from=builder /app/sentry.properties ./

EXPOSE 3000
CMD ["yarn", "start"]