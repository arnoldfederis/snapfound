import type { MetadataRoute } from "next";

const BASE = "https://snapfound.app";

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: BASE,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 1,
    },
    {
      url: `${BASE}/support`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${BASE}/privacy`,
      lastModified: new Date("2026-05-30"),
      changeFrequency: "yearly",
      priority: 0.3,
    },
    {
      url: `${BASE}/terms`,
      lastModified: new Date("2026-05-30"),
      changeFrequency: "yearly",
      priority: 0.3,
    },
  ];
}
