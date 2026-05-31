import Image from "next/image";
import { FadeIn } from "@/components/common/motion";
import { PhoneMockup } from "@/components/common/phone-mockup";

const SHOWCASES = [
  {
    id: "search",
    eyebrow: "Full-text search",
    headline: "Search what's inside.",
    body: "Type what you remember: a receipt total, a booking reference, a Wi-Fi password. Find the exact screenshot in seconds. No folders, no tags.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-2.png",
  },
  {
    id: "privacy",
    eyebrow: "Private by design",
    headline: "Your screenshots stay on your iPhone.",
    body: "Text extraction happens on your device using Apple's on-device OCR. No account required, no screenshot uploads, no tracking. Delete the local index anytime.",
    phoneFirst: true,
    muted: true,
    src: "/assets/device-3.png",
  },
  {
    id: "screenshots",
    eyebrow: "Your screenshot library",
    headline: "Every screenshot, beautifully organized.",
    body: "Browse all your screenshots in a clean date-grouped grid. Switch between 2, 3, or 4 columns to suit how you browse.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-4.png",
  },
];

export function FeatureShowcase() {
  return (
    <>
      {SHOWCASES.map((s) => (
        <section
          className={`py-24 ${s.muted ? "border-y bg-muted/40" : ""}`}
          id={s.id}
          key={s.id}
        >
          <div className="mx-auto max-w-6xl px-6">
            <div
              className={`flex flex-col items-center gap-16 md:gap-20 ${
                s.phoneFirst ? "md:flex-row-reverse" : "md:flex-row"
              }`}
            >
              {/* Text */}
              <FadeIn className="flex-1">
                <p className="mb-3 font-medium text-primary text-sm uppercase tracking-widest">
                  {s.eyebrow}
                </p>
                <h2 className="font-bold text-4xl leading-[1.1] tracking-tight sm:text-5xl">
                  {s.headline}
                </h2>
                <p className="mt-5 max-w-md text-muted-foreground leading-relaxed">
                  {s.body}
                </p>
              </FadeIn>

              {/* Phone */}
              <FadeIn className="flex flex-1 justify-center" delay={0.1}>
                <div className="relative">
                  <div className="pointer-events-none absolute top-1/2 left-1/2 size-72 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/10 blur-3xl" />
                  <PhoneMockup className="relative">
                    <Image
                      alt="App screenshot"
                      className="h-auto w-65 sm:w-75"
                      height={2796}
                      src={s.src}
                      width={1419}
                    />
                  </PhoneMockup>
                </div>
              </FadeIn>
            </div>
          </div>
        </section>
      ))}
    </>
  );
}
