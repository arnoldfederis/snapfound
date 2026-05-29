import { Check, Minus } from "lucide-react";

const SNAPFOUND = [
  "Local OCR",
  "No account required",
  "No tracking",
  "No cloud upload",
  "One-time unlock",
];

const CLOUD_TOOLS = [
  "Upload required",
  "Account required",
  "Possible ongoing cost",
  "Less private for screenshots",
  "Subscription model",
];

export function PrivacySection() {
  return (
    <section className="py-24" id="privacy">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Built for private screenshots.
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
            Screenshots often contain sensitive information: addresses, codes,
            receipts, banking details, messages, and passwords. SnapFound is
            designed so OCR and search happen locally on your iPhone.
          </p>
        </div>

        <div className="mx-auto max-w-2xl overflow-hidden rounded-2xl border border-border">
          {/* Table header */}
          <div className="grid grid-cols-2 border-border border-b">
            <div className="border-border border-r bg-primary/[0.06] px-6 py-4">
              <p className="font-semibold text-primary text-sm">SnapFound</p>
            </div>
            <div className="px-6 py-4">
              <p className="font-semibold text-muted-foreground text-sm">
                Cloud tools
              </p>
            </div>
          </div>

          {/* Rows */}
          {SNAPFOUND.map((feature, i) => (
            <div
              className="grid grid-cols-2 border-border border-b last:border-0"
              key={feature}
            >
              <div className="flex items-center gap-2.5 border-border border-r bg-primary/[0.03] px-6 py-3.5">
                <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary/15">
                  <Check className="h-3 w-3 text-primary" />
                </div>
                <span className="text-sm">{feature}</span>
              </div>
              <div className="flex items-center gap-2.5 px-6 py-3.5">
                <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-border">
                  <Minus className="h-3 w-3 text-muted-foreground" />
                </div>
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
