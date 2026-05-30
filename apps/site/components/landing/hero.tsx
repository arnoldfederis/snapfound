import { DownloadIcon } from "lucide-react";
import Image from "next/image";
import { FadeIn } from "@/components/common/motion";
import { PhoneMockup } from "@/components/common/phone-mockup";
import { buttonVariants } from "@/components/ui/button";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

export function Hero() {
  return (
    <section className="overflow-hidden pt-24">
      <div className="mx-auto max-w-3xl px-6 text-center">
        <FadeIn>
          <h1 className="font-bold text-5xl leading-[1.05] tracking-tight sm:text-6xl lg:text-7xl">
            Find any screenshot <span className="text-primary">instantly.</span>
          </h1>
        </FadeIn>

        <FadeIn delay={0.1}>
          <p className="mx-auto mt-6 max-w-lg text-lg text-muted-foreground leading-relaxed">
            SnapFound indexes your screenshots with on-device OCR. Search
            receipts, Wi-Fi passwords, order confirmations, privately on your
            iPhone.
          </p>
        </FadeIn>

        <FadeIn delay={0.2}>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <a className={buttonVariants({ size: "lg" })} href={APP_STORE_URL}>
              <DownloadIcon className="size-4" />
              Download on the App Store
            </a>
            <a
              className={buttonVariants({ variant: "secondary", size: "lg" })}
              href="#features"
            >
              See how it works
            </a>
          </div>
          <p className="mt-4 text-muted-foreground text-xs">
            50 screenshots free · one-time Pro unlock · no account
          </p>
        </FadeIn>
      </div>

      {/* Hero phone mockup */}
      <FadeIn
        className="relative mt-16 flex justify-center px-6 pb-0"
        delay={0.3}
      >
        {/* Glow */}
        <div className="pointer-events-none absolute top-1/2 left-1/2 size-96 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/15 blur-3xl" />
        <PhoneMockup className="relative">
          <Image
            alt="App screenshot"
            className="h-auto w-65 sm:w-75"
            height={2796}
            src="/assets/device-1.png"
            width={1419}
          />
        </PhoneMockup>
      </FadeIn>
    </section>
  );
}
