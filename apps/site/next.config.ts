import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["snapfound.dev", "*.snapfound.dev"],
  output: "standalone",
  reactCompiler: true,
  images: {
    unoptimized: true,
    remotePatterns: [{ protocol: "https", hostname: "**.snapfound.app" }],
  },
};

export default nextConfig;
