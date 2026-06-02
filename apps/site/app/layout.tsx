import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import { ThemeProvider } from "@/components/providers/theme";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

const BASE = "https://snapfound.app";
const FOUNDER_SAME_AS = [
  "https://linkedin.com/in/arnoldfederis",
  "https://x.com/arnoldfederis",
  "https://threads.com/arnoldfederis",
  "https://github.com/arnoldfederis",
];
const siteJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": `${BASE}/#website`,
      url: BASE,
      name: "SnapFound",
      description: "Private screenshot search for iPhone using on-device OCR.",
    },
    {
      "@type": "Person",
      "@id": `${BASE}/#founder`,
      name: "Arnolfo Federis",
      alternateName: "Arnold Federis",
      url: "https://arnoldfederis.com",
      sameAs: FOUNDER_SAME_AS,
    },
    {
      "@type": "Organization",
      "@id": `${BASE}/#organization`,
      name: "SnapFound",
      url: BASE,
      logo: {
        "@type": "ImageObject",
        url: `${BASE}/snapfound-icon-512x512.png`,
      },
      contactPoint: {
        "@type": "ContactPoint",
        email: "support@snapfound.app",
        contactType: "customer support",
      },
      founder: { "@id": `${BASE}/#founder` },
    },
  ],
};

export const metadata: Metadata = {
  metadataBase: new URL("https://snapfound.app"),
  title: "SnapFound - Private screenshot search for iPhone",
  description:
    "Find any screenshot instantly. SnapFound indexes your screenshots locally with on-device OCR, so your private information stays on your iPhone.",
  applicationName: "SnapFound",
  keywords: [
    "screenshot search",
    "search screenshots",
    "find text in screenshots",
    "iPhone screenshot search",
    "OCR screenshot app",
    "screenshot text recognition",
    "iPhone screenshots",
    "OCR",
    "private search",
    "local OCR",
    "on-device OCR",
    "screenshot organizer",
    "photo search",
    "receipts",
    "Wi-Fi password",
    "order confirmation",
  ],
  robots: {
    index: true,
    follow: true,
  },
  appleWebApp: {
    title: "SnapFound",
    capable: true,
  },
  alternates: {
    canonical: "https://snapfound.app",
  },
  openGraph: {
    title: "SnapFound - Private screenshot search for iPhone",
    description:
      "Find any screenshot instantly. SnapFound indexes your screenshots locally with on-device OCR, so your private information stays on your iPhone.",
    url: "https://snapfound.app",
    siteName: "SnapFound",
    type: "website",
    locale: "en_US",
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "SnapFound - Search Your iPhone Screenshots Instantly",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "SnapFound - Private screenshot search for iPhone",
    description:
      "Find any screenshot instantly. SnapFound indexes your screenshots locally with on-device OCR, so your private information stays on your iPhone.",
    images: ["/opengraph-image"],
  },
  icons: {
    icon: [
      { url: "/favicon.ico" },
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
    ],
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
    ],
  },
  manifest: "/site.webmanifest",
};

export const viewport: Viewport = {
  themeColor: "#6468F0",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      className={`${inter.variable} h-full antialiased`}
      lang="en"
      suppressHydrationWarning
    >
      <body className="flex min-h-full flex-col">
        <script
          // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
          dangerouslySetInnerHTML={{ __html: JSON.stringify(siteJsonLd) }}
          type="application/ld+json"
        />
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
