FROM oven/bun:1 AS deps
WORKDIR /app

COPY package.json bun.lock turbo.json ./
COPY apps/ios/package.json apps/ios/package.json
COPY apps/site/package.json apps/site/package.json

RUN bun install --frozen-lockfile

FROM deps AS build

ENV SKIP_ENV_VALIDATION=1
ENV NEXT_TELEMETRY_DISABLED=1

COPY . .
RUN cd apps/site && bun run build

FROM node:22-slim AS sharp-installer
WORKDIR /install
RUN npm install --no-package-lock sharp@0.34.5

FROM oven/bun:1-slim AS runner
WORKDIR /app

ENV SKIP_ENV_VALIDATION=1
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=4000
ENV HOSTNAME=0.0.0.0

COPY --from=build /app/apps/site/.next/standalone ./
COPY --from=build /app/apps/site/.next/static ./apps/site/.next/static
COPY --from=build /app/apps/site/public ./apps/site/public
COPY --from=sharp-installer /install/node_modules/sharp ./node_modules/sharp
COPY --from=sharp-installer /install/node_modules/@img ./node_modules/@img

EXPOSE 4000
CMD ["bun", "apps/site/server.js"]
