import { FAQ } from "@/components/landing/faq";
import { FeatureShowcase } from "@/components/landing/feature-showcase";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";
import { Hero } from "@/components/landing/hero";
import { HowItWorks } from "@/components/landing/how-it-works";
import { ScreenshotGallery } from "@/components/landing/screenshot-gallery";

const BASE = "https://snapfound.app";

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "SoftwareApplication",
      name: "SnapFound",
      operatingSystem: "iOS",
      applicationCategory: "ProductivityApplication",
      description:
        "Search your screenshots instantly using on-device OCR. Find receipts, Wi-Fi passwords, order confirmations, and more — privately, with no account required.",
      url: BASE,
      creator: { "@id": "https://snapfound.app/#founder" },
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "USD",
      },
    },
    {
      "@type": "FAQPage",
      mainEntity: [
        {
          "@type": "Question",
          name: "Does SnapFound upload my screenshots?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "No. OCR, tagging, indexing, and search all happen on your iPhone. Your screenshots, OCR text, and search queries are not uploaded.",
          },
        },
        {
          "@type": "Question",
          name: "Does SnapFound need an account?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "No account is required. SnapFound works entirely on-device with no sign-in.",
          },
        },
        {
          "@type": "Question",
          name: "Does it search all photos?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "SnapFound is designed for screenshots. It focuses on your screenshot library, not your entire photo collection.",
          },
        },
        {
          "@type": "Question",
          name: "What can I search for?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Receipts, Wi-Fi passwords, order confirmations, flights, bookings, error messages, verification codes, notes, and more. Any text that appears in an indexed screenshot.",
          },
        },
        {
          "@type": "Question",
          name: "Does it work offline?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Yes. Once screenshots are indexed, search works locally — no internet connection required.",
          },
        },
        {
          "@type": "Question",
          name: "Is SnapFound a subscription?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "No. SnapFound Pro is a one-time purchase with no recurring charges.",
          },
        },
      ],
    },
  ],
};

export default function Home() {
  return (
    <>
      {/* trusted static data — standard Next.js JSON-LD pattern */}
      <script
        // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        type="application/ld+json"
      />
      <Header />
      <main>
        <Hero />
        <FeatureShowcase />
        <ScreenshotGallery />
        <HowItWorks />
        <FAQ />
      </main>
      <Footer />
    </>
  );
}
