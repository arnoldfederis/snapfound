import { ArrowLeftIcon } from "lucide-react";
import type { Metadata } from "next";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";

export const metadata: Metadata = {
  title: "Terms of Service - SnapFound",
  description:
    "Terms for using SnapFound, a private screenshot search app for iPhone.",
  alternates: {
    canonical: "https://snapfound.app/terms",
  },
  openGraph: {
    title: "Terms of Service - SnapFound",
    description:
      "Terms for using SnapFound, a private screenshot search app for iPhone.",
  },
};

const EFFECTIVE_DATE = "May 30, 2026";
const LAST_UPDATED = "May 30, 2026";

export default function TermsPage() {
  return (
    <>
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

        {/* Page header */}
        <div className="mb-2">
          <h1 className="font-bold text-3xl tracking-tight">
            Terms of Service
          </h1>
          <p className="mt-3 text-muted-foreground text-sm">
            Effective date: {EFFECTIVE_DATE} &middot; Last updated:{" "}
            {LAST_UPDATED}
          </p>
        </div>

        <p className="mt-5 text-muted-foreground leading-relaxed">
          These terms explain the rules for using SnapFound.
        </p>

        <div className="mt-10 space-y-10 border-t pt-10">
          {/* A */}
          <section>
            <h2 className="mb-3 font-semibold">Acceptance of Terms</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              By downloading or using SnapFound, you agree to these Terms of
              Service. If you do not agree, please do not use the app.
            </p>
          </section>

          {/* B */}
          <section>
            <h2 className="mb-3 font-semibold">What SnapFound Does</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound helps you index and search your screenshots locally on
              your iPhone using on-device OCR and local search. SnapFound does
              not send your screenshots, OCR text, search queries, or screenshot
              metadata to external servers.
            </p>
          </section>

          {/* C */}
          <section>
            <h2 className="mb-3 font-semibold">Local Processing</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound is designed to work locally on your device. You are
              responsible for the content in your Photos library and the data
              indexed on your device. SnapFound does not control or verify the
              content of your screenshots.
            </p>
          </section>

          {/* D */}
          <section>
            <h2 className="mb-3 font-semibold">Photos Access</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              You control Photos access through iOS permissions. SnapFound only
              accesses the screenshots you allow through iOS. You can change
              these permissions at any time in iOS Settings &rsaquo; Apps
              &rsaquo; SnapFound &rsaquo; Photos.
            </p>
          </section>

          {/* E */}
          <section>
            <h2 className="mb-3 font-semibold">In-App Purchases</h2>
            <p className="mb-3 text-muted-foreground text-sm leading-relaxed">
              SnapFound is free to download and includes indexing for up to 50
              screenshots. SnapFound Pro unlocks unlimited screenshot indexing
              with a one-time purchase.
            </p>
            <ul className="space-y-2 text-muted-foreground text-sm">
              {[
                "Purchases are processed by Apple through StoreKit.",
                "Refund requests and purchase issues are handled in accordance with Apple's App Store policies.",
                "You can restore previous purchases from within the app.",
              ].map((item) => (
                <li className="flex items-start gap-2" key={item}>
                  <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
                  {item}
                </li>
              ))}
            </ul>
          </section>

          {/* F */}
          <section>
            <h2 className="mb-3 font-semibold">User Responsibilities</h2>
            <p className="mb-3 text-muted-foreground text-sm">
              By using SnapFound, you agree:
            </p>
            <ul className="space-y-2 text-muted-foreground text-sm">
              {[
                "Not to misuse or tamper with the app.",
                "Not to attempt to reverse engineer the app.",
                "To comply with applicable laws.",
                "To manage your own device, Photos permissions, and backups.",
              ].map((item) => (
                <li className="flex items-start gap-2" key={item}>
                  <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
                  {item}
                </li>
              ))}
            </ul>
          </section>

          {/* G */}
          <section>
            <h2 className="mb-3 font-semibold">No Guarantee</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound attempts to provide accurate OCR and search results, but
              OCR is not perfect. The app may not find every screenshot or
              recognize every word accurately. We make no warranty about the
              completeness or accuracy of search results.
            </p>
          </section>

          {/* H */}
          <section>
            <h2 className="mb-3 font-semibold">Availability and Changes</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound may change over time. Features may be added, modified,
              or removed. We may update the app or stop supporting it in the
              future.
            </p>
          </section>

          {/* I */}
          <section>
            <h2 className="mb-3 font-semibold">Privacy</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Your privacy matters. Please read our{" "}
              <a
                className="text-primary underline underline-offset-3 hover:text-primary/80"
                href="/privacy"
              >
                Privacy Policy
              </a>{" "}
              to understand how SnapFound handles your data.
            </p>
          </section>

          {/* J */}
          <section>
            <h2 className="mb-3 font-semibold">Disclaimer of Warranties</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound is provided "as is" without warranties of any kind, to
              the extent permitted by applicable law. We do not warrant that the
              app will be error-free or uninterrupted.
            </p>
          </section>

          {/* K */}
          <section>
            <h2 className="mb-3 font-semibold">Limitation of Liability</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              To the extent permitted by applicable law, SnapFound and its
              developer are not liable for indirect, incidental, special, or
              consequential damages arising from your use of the app.
            </p>
          </section>

          {/* L */}
          <section>
            <h2 className="mb-3 font-semibold">Termination</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              You can stop using SnapFound at any time and delete the local
              index from within the app. The developer may stop supporting or
              change the availability of the app in the future.
            </p>
          </section>

          {/* M */}
          <section>
            <h2 className="mb-3 font-semibold">Governing Law</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              These terms are governed by the laws of the Republic of the
              Philippines, without regard to conflict of law principles.
            </p>
          </section>

          {/* N */}
          <section className="border-t pt-10">
            <h2 className="mb-3 font-semibold">Contact</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Questions about these Terms? Reach out at{" "}
              <a
                className="text-primary underline underline-offset-3 hover:text-primary/80"
                href="mailto:support@snapfound.app"
              >
                support@snapfound.app
              </a>
              .
            </p>
          </section>
        </div>
      </main>
      <Footer />
    </>
  );
}
