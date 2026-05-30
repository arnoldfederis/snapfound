import { CheckCircle2Icon, MinusCircleIcon } from "lucide-react";
import { FadeIn } from "@/components/common/motion";

const SNAPFOUND = [
  "Local OCR - text extraction happens on your iPhone",
  "No account required",
  "No tracking or analytics",
  "No cloud upload",
  "One-time unlock",
];

const CLOUD_TOOLS = [
  "Screenshots uploaded to remote servers",
  "Account and login required",
  "Possible ongoing or subscription cost",
  "Less private for sensitive screenshot content",
  "Often subscription-based",
];

export function PrivacySection() {
  return (
    <section className="border-y bg-muted/30 py-20" id="privacy">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-2xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Built for private screenshots.
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Screenshots often contain sensitive information: addresses, codes,
            receipts, banking details, messages, and passwords. SnapFound is
            designed so OCR and search happen locally on your iPhone.
          </p>
        </FadeIn>

        <div className="mx-auto max-w-2xl overflow-hidden rounded-2xl border bg-card">
          {/* Header row */}
          <div className="grid grid-cols-2 border-b">
            <div className="border-r bg-primary/[0.03] px-6 py-4">
              <p className="font-semibold text-primary text-sm">SnapFound</p>
            </div>
            <div className="px-6 py-4">
              <p className="font-semibold text-muted-foreground text-sm">
                Cloud tools
              </p>
            </div>
          </div>

          {/* Data rows */}
          {SNAPFOUND.map((feature, i) => (
            <div
              className="grid grid-cols-2 border-b last:border-0"
              key={feature}
            >
              <div className="flex items-start gap-2.5 border-r bg-primary/[0.02] px-6 py-3.5">
                <CheckCircle2Icon className="mt-0.5 size-4 shrink-0 text-primary" />
                <span className="text-sm">{feature}</span>
              </div>
              <div className="flex items-start gap-2.5 px-6 py-3.5">
                <MinusCircleIcon className="mt-0.5 size-4 shrink-0 text-muted-foreground/50" />
                <span className="text-muted-foreground text-sm">
                  {CLOUD_TOOLS[i]}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
