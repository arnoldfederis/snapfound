import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["snapfound.dev", "*.snapfound.dev"],
  /* config options here */
  output: "standalone",
  reactCompiler: true,
};

export default nextConfig;
