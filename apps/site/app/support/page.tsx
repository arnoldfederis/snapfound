import { ArrowLeftIcon, MailIcon } from "lucide-react";
import type { Metadata } from "next";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";
import { buttonVariants } from "@/components/ui/button";

export const metadata: Metadata = {
  title: "Support - SnapFound",
  description:
    "Get help with SnapFound, the private screenshot search app for iPhone.",
  alternates: {
    canonical: "https://snapfound.app/support",
  },
  openGraph: {
    title: "Support - SnapFound",
    description:
      "Get help with SnapFound, the private screenshot search app for iPhone.",
  },
};

const FAQS = [
  {
    q: "Why can't SnapFound find a screenshot I know I took?",
    a: "Screenshots need to be indexed before they can be searched. Open the app, start indexing, and wait for it to complete. If you recently took the screenshot, index it first and then search.",
  },
  {
    q: "How do I delete my SnapFound index?",
    a: "Go to Settings inside the app and tap Delete Index. This removes all OCR text, tags, and metadata stored by SnapFound. Your original photos are not affected.",
  },
  {
    q: "Does SnapFound upload my screenshots?",
    a: "No. OCR, indexing, and search all happen on your iPhone. Your screenshots, OCR text, and search queries are not uploaded.",
  },
  {
    q: "How do I change which photos SnapFound can access?",
    a: "Go to iOS Settings > Apps > SnapFound > Photos and adjust the permission. You can grant full access, limited access, or remove access entirely.",
  },
  {
    q: "How do I restore my Pro purchase on a new iPhone?",
    a: "Open SnapFound, go to Settings, and tap Restore Purchases. Your purchase is tied to your Apple ID.",
  },
  {
    q: "How do I request a refund?",
    a: "Refunds are handled by Apple. Visit reportaproblem.apple.com or go to your purchase history in the App Store.",
  },
];

const faqJsonLd = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: FAQS.map(({ q, a }) => ({
    "@type": "Question",
    name: q,
    acceptedAnswer: { "@type": "Answer", text: a },
  })),
};

export default function SupportPage() {
  return (
    <>
      <script
        // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
        type="application/ld+json"
      />
      <Header />
      <main className="mx-auto max-w-2xl px-6 py-16">
        {/* Back */}
        <a
          className="mb-10 inline-flex items-center gap-1.5 text-muted-foreground text-sm transition-colors hover:text-primary"
          href="/"
        >
          <ArrowLeftIcon className="size-3.5" />
          Back to home
        </a>

        <h1 className="font-bold text-3xl tracking-tight">Support</h1>
        <p className="mt-4 text-muted-foreground leading-relaxed">
          Need help with SnapFound? Check the common questions below or send an
          email and I'll get back to you.
        </p>

        {/* Contact CTA */}
        <div className="mt-8 flex items-center gap-4 rounded-2xl border bg-muted/30 px-6 py-5">
          <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10">
            <MailIcon className="size-5 text-primary" />
          </div>
          <div className="flex-1">
            <p className="font-medium text-sm">Email support</p>
            <p className="text-muted-foreground text-sm">
              For bug reports, questions, or feedback.
            </p>
          </div>
          <a
            className={buttonVariants({ size: "sm" })}
            href="mailto:support@snapfound.app"
          >
            Send email
          </a>
        </div>

        {/* FAQ */}
        <div className="mt-12 space-y-8 border-t pt-10">
          <h2 className="font-semibold">Common questions</h2>

          <div className="space-y-6">
            {FAQS.map(({ q, a }) => (
              <div key={q}>
                <p className="font-medium text-sm">{q}</p>
                <p className="mt-1.5 text-muted-foreground text-sm leading-relaxed">
                  {a}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Links */}
        <div className="mt-12 flex flex-wrap gap-4 border-t pt-8 text-sm">
          <a
            className="text-muted-foreground hover:text-primary"
            href="/privacy"
          >
            Privacy Policy
          </a>
          <a className="text-muted-foreground hover:text-primary" href="/terms">
            Terms of Service
          </a>
        </div>
      </main>
      <Footer />
    </>
  );
}
