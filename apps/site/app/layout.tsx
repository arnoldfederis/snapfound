import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "SnapFound — Private screenshot search for iPhone",
  description:
    "Find any screenshot instantly. SnapFound indexes your screenshots locally with on-device OCR, so your private information stays on your iPhone.",
  openGraph: {
    title: "SnapFound — Find any screenshot instantly",
    description:
      "Private screenshot search for iPhone. Local OCR, no account, no tracking, no cloud upload.",
    url: "https://snapfound.app",
    siteName: "SnapFound",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "SnapFound — Find any screenshot instantly",
    description:
      "Private screenshot search for iPhone. Local OCR, no account, no tracking, no cloud upload.",
  },
  metadataBase: new URL("https://snapfound.app"),
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html className={`${inter.variable} h-full antialiased`} lang="en">
      <body className="flex min-h-full flex-col">{children}</body>
    </html>
  );
}
