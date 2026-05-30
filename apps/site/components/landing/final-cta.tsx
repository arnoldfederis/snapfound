import { DownloadIcon } from "lucide-react";
import { FadeIn } from "@/components/common/motion";
import { buttonVariants } from "@/components/ui/button";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

export function FinalCTA() {
  return (
    <section className="border-t">
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-primary/5 via-primary/[0.03] to-transparent" />
        <FadeIn className="relative mx-auto max-w-3xl px-6 py-24 text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Ready to find your screenshots faster?
          </h2>
          <p className="mx-auto mt-4 max-w-lg text-lg text-muted-foreground">
            Private. On-device. No account. One-time unlock. Your screenshots
            stay on your iPhone.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <a className={buttonVariants({ size: "lg" })} href={APP_STORE_URL}>
              <DownloadIcon className="size-4" />
              Download on the App Store
            </a>
            <a
              className={buttonVariants({ variant: "secondary", size: "lg" })}
              href="https://snapfound.app/privacy"
            >
              Read the privacy policy
            </a>
          </div>
          <p className="mt-4 text-muted-foreground text-xs">
            50 screenshots free · Pro unlocks unlimited indexing
          </p>
        </FadeIn>
      </div>
    </section>
  );
}
