import { ChevronDown, Download } from "lucide-react";
import { PhoneMockup } from "@/components/landing/phone-mockup";
import { Button } from "@/components/ui/button";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

export function Hero() {
  return (
    <section className="relative overflow-hidden pt-32 pb-24">
      {/* Background */}
      <div aria-hidden className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute inset-x-0 top-0 h-[480px] bg-gradient-to-b from-primary/[0.06] to-transparent" />
        <div className="absolute top-0 right-0 h-[640px] w-[640px] translate-x-1/3 -translate-y-1/4 rounded-full bg-primary/[0.06] blur-3xl" />
        <div className="absolute bottom-0 left-0 h-[400px] w-[400px] -translate-x-1/3 translate-y-1/4 rounded-full bg-primary/[0.04] blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-6xl px-4 sm:px-6">
        <div className="flex flex-col items-center gap-20 lg:flex-row lg:items-center">
          {/* Copy */}
          <div className="flex flex-1 flex-col items-center text-center lg:items-start lg:text-left">
            <div className="mb-5 inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/[0.06] px-3 py-1 font-medium text-primary text-xs">
              Private · On-device · iPhone
            </div>

            <h1 className="mb-5 font-extrabold text-5xl leading-[1.06] tracking-tight sm:text-6xl lg:text-[4.25rem]">
              Find any screenshot{" "}
              <span className="text-primary">instantly.</span>
            </h1>

            <p className="mb-9 max-w-xl text-lg text-muted-foreground leading-relaxed">
              Search receipts, Wi-Fi passwords, order confirmations, flight
              details, error messages, verification codes, and more. SnapFound
              indexes your screenshots locally, so your private information
              stays on your iPhone.
            </p>

            <div className="flex flex-col gap-3 sm:flex-row">
              <Button asChild className="gap-2 shadow-sm" size="lg">
                <a href={APP_STORE_URL}>
                  <Download className="h-4 w-4" />
                  Download on the App Store
                </a>
              </Button>
              <Button asChild className="gap-2" size="lg" variant="outline">
                <a href="#how-it-works">
                  See how it works
                  <ChevronDown className="h-4 w-4" />
                </a>
              </Button>
            </div>
          </div>

          {/* Mockup */}
          <div className="flex flex-1 justify-center lg:justify-end">
            <PhoneMockup />
          </div>
        </div>
      </div>
    </section>
  );
}
