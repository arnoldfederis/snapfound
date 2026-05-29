import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

export function FinalCTA() {
  return (
    <section className="relative overflow-hidden bg-secondary/20 py-28">
      <div aria-hidden className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-primary/20 to-transparent" />
        <div className="absolute inset-x-0 bottom-0 h-px bg-gradient-to-r from-transparent via-primary/20 to-transparent" />
        <div className="absolute top-0 left-1/2 h-[300px] w-[600px] -translate-x-1/2 rounded-full bg-primary/[0.05] blur-3xl" />
      </div>

      <div className="mx-auto max-w-2xl px-4 text-center sm:px-6">
        <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
          Ready to find your screenshots faster?
        </h2>
        <p className="mb-9 text-lg text-muted-foreground">
          Private. On-device. No account. One-time unlock.
        </p>

        <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
          <Button asChild className="gap-2 shadow-sm" size="lg">
            <a href={APP_STORE_URL}>
              <Download className="h-4 w-4" />
              Download on the App Store
            </a>
          </Button>
          <a
            className="text-muted-foreground text-sm underline-offset-4 transition-colors hover:text-foreground hover:underline"
            href="https://snapfound.app/privacy"
          >
            Read the privacy policy
          </a>
        </div>
      </div>
    </section>
  );
}
