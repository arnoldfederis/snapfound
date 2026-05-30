import { CheckCircle2Icon, XCircleIcon } from "lucide-react";
import { FadeIn } from "@/components/common/motion";

const WITHOUT = [
  "Scroll through hundreds of screenshots to find one receipt",
  "Can't remember which screenshot has the Wi-Fi password",
  "Sensitive data like codes and bank details sits unorganized",
  "Search by date only - no way to search by content",
];

const WITH = [
  "Type what you remember and find it in seconds",
  "OCR reads the text inside every screenshot locally",
  "Private index stays on your iPhone, never uploaded",
  "Search across all your screenshots from one place",
];

export function Problem() {
  return (
    <section className="py-20">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-2xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Screenshots are useful until you need to find one.
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Your camera roll fills up with receipts, codes, orders, bookings,
            settings, errors, and notes. SnapFound turns your screenshot library
            into a private searchable memory.
          </p>
        </FadeIn>

        <div className="grid gap-8 md:grid-cols-2 lg:gap-12">
          <FadeIn delay={0.1} direction="left">
            <div className="flex h-full flex-col rounded-2xl border border-destructive/20 bg-destructive/[0.03] p-8">
              <p className="mb-6 font-medium text-destructive text-sm">
                Without SnapFound
              </p>
              <div className="space-y-4">
                {WITHOUT.map((p) => (
                  <div className="flex items-start gap-3" key={p}>
                    <XCircleIcon className="mt-0.5 size-5 shrink-0 text-destructive/60" />
                    <span className="text-sm">{p}</span>
                  </div>
                ))}
              </div>
            </div>
          </FadeIn>

          <FadeIn delay={0.2} direction="right">
            <div className="flex h-full flex-col rounded-2xl border border-primary/20 bg-primary/[0.03] p-8">
              <p className="mb-6 font-medium text-primary text-sm">
                With SnapFound
              </p>
              <div className="space-y-4">
                {WITH.map((s) => (
                  <div className="flex items-start gap-3" key={s}>
                    <CheckCircle2Icon className="mt-0.5 size-5 shrink-0 text-primary" />
                    <span className="text-sm">{s}</span>
                  </div>
                ))}
              </div>
            </div>
          </FadeIn>
        </div>
      </div>
    </section>
  );
}
