import { ArrowLeftIcon } from "lucide-react";
import type { Metadata } from "next";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";

export const metadata: Metadata = {
  title: "Privacy Policy - SnapFound",
  description:
    "SnapFound is designed for private screenshot search. Screenshots, OCR text, search queries, and metadata stay on your iPhone.",
  alternates: {
    canonical: "https://snapfound.app/privacy",
  },
  openGraph: {
    title: "Privacy Policy - SnapFound",
    description:
      "SnapFound is designed for private screenshot search. Screenshots, OCR text, search queries, and metadata stay on your iPhone.",
  },
};

const EFFECTIVE_DATE = "May 30, 2026";
const LAST_UPDATED = "May 30, 2026";

export default function PrivacyPage() {
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
          <h1 className="font-bold text-3xl tracking-tight">Privacy Policy</h1>
          <p className="mt-3 text-muted-foreground text-sm">
            Effective date: {EFFECTIVE_DATE} &middot; Last updated:{" "}
            {LAST_UPDATED}
          </p>
        </div>

        <p className="mt-5 text-muted-foreground leading-relaxed">
          SnapFound is designed to help you search your screenshots privately.
          The app processes screenshots on your device and does not upload your
          screenshots, OCR text, search queries, or photo metadata to our
          servers.
        </p>

        <div className="mt-10 space-y-10 border-t pt-10">
          {/* A */}
          <section>
            <h2 className="mb-3 font-semibold">Overview</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound is a local-first iPhone app. It uses on-device OCR to
              make your screenshot library searchable without sending your data
              anywhere. Processing happens entirely on your iPhone. There is no
              backend server, no account system, and no remote processing.
            </p>
          </section>

          {/* B */}
          <section>
            <h2 className="mb-3 font-semibold">
              Information We Do Not Collect
            </h2>
            <p className="mb-3 text-muted-foreground text-sm leading-relaxed">
              SnapFound does not collect or transmit any of the following:
            </p>
            <ul className="space-y-2 text-muted-foreground text-sm">
              {[
                "Screenshots",
                "OCR text extracted from your screenshots",
                "Search queries",
                "Photo metadata",
                "Analytics or usage data",
                "Device identifiers for tracking",
                "Personal information for advertising",
              ].map((item) => (
                <li className="flex items-start gap-2" key={item}>
                  <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
                  {item}
                </li>
              ))}
            </ul>
            <p className="mt-3 text-muted-foreground text-sm">
              SnapFound does not require an account. We do not sell personal
              information.
            </p>
          </section>

          {/* C */}
          <section>
            <h2 className="mb-3 font-semibold">
              Information Processed On Your Device
            </h2>
            <p className="mb-3 text-muted-foreground text-sm leading-relaxed">
              To provide search functionality, SnapFound may process and store
              the following locally on your device:
            </p>
            <ul className="space-y-2 text-muted-foreground text-sm">
              {[
                "Screenshot asset identifiers",
                "Screenshot creation date and dimensions",
                "OCR text extracted from screenshots",
                "Locally generated tags",
                "Thumbnail data or cache",
                "Search index",
                "Purchase state cache",
              ].map((item) => (
                <li className="flex items-start gap-2" key={item}>
                  <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
                  {item}
                </li>
              ))}
            </ul>
            <p className="mt-3 text-muted-foreground text-sm leading-relaxed">
              This information stays on your device. SnapFound has no backend
              server. If your device backs up to iCloud or another service, that
              is controlled by your device settings and Apple's services, not by
              SnapFound.
            </p>
          </section>

          {/* D */}
          <section>
            <h2 className="mb-3 font-semibold">Photos Permission</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound requests access to your Photos library to find and index
              screenshots. You can grant full or limited photo access. You can
              change this permission at any time in iOS Settings &rsaquo; Apps
              &rsaquo; SnapFound &rsaquo; Photos.
            </p>
          </section>

          {/* E */}
          <section>
            <h2 className="mb-3 font-semibold">OCR and Local Search</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Text recognition and search happen locally on your iPhone using
              Apple's on-device OCR frameworks. SnapFound does not send
              screenshot content to a remote server for processing.
            </p>
          </section>

          {/* F */}
          <section>
            <h2 className="mb-3 font-semibold">In-App Purchases</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound uses Apple StoreKit for in-app purchases. All purchases
              are processed by Apple. SnapFound does not receive, process, or
              store your payment card details.
            </p>
          </section>

          {/* G */}
          <section>
            <h2 className="mb-3 font-semibold">No Tracking or Advertising</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound does not use third-party advertising SDKs, tracking
              SDKs, or analytics services. There is no telemetry in the app.
            </p>
          </section>

          {/* H */}
          <section>
            <h2 className="mb-3 font-semibold">Data Deletion</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              You can delete SnapFound's local index from within the app. This
              removes locally stored OCR text, tags, thumbnails, and metadata
              from SnapFound's storage. It does not delete your original photos
              from the Photos app.
            </p>
          </section>

          {/* I */}
          <section>
            <h2 className="mb-3 font-semibold">Children's Privacy</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              SnapFound is not designed to knowingly collect personal
              information from children under 13. Since SnapFound does not
              collect personal data on any server, there is no server-side user
              profile for any user.
            </p>
          </section>

          {/* J */}
          <section>
            <h2 className="mb-3 font-semibold">Changes to This Policy</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              We may update this Privacy Policy from time to time. The updated
              version will be posted at{" "}
              <a
                className="text-primary underline underline-offset-3 hover:text-primary/80"
                href="https://snapfound.app/privacy"
              >
                snapfound.app/privacy
              </a>
              . Please review the latest version when it changes.
            </p>
          </section>

          {/* K */}
          <section className="border-t pt-10">
            <h2 className="mb-3 font-semibold">Contact</h2>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Questions about this Privacy Policy? Reach out at{" "}
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
