import { FadeIn } from "@/components/common/motion";
import { PhoneMockup } from "@/components/common/phone-mockup";
import { ProgressiveImage } from "@/components/common/progressive-image";
import { deviceBlurDataURL } from "@/lib/image-placeholders";

const SHOWCASES = [
  {
    id: "search",
    eyebrow: "Full-text search",
    headline: "Search what's inside.",
    body: "Type what you remember: a receipt total, a booking reference, a Wi-Fi password. Find the exact screenshot in seconds. No folders, no tags.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-2.png",
    alt: "SnapFound full-text search finding a screenshot on iPhone",
  },
  {
    id: "privacy",
    eyebrow: "Private by design",
    headline: "Your screenshots stay on your iPhone.",
    body: "Text extraction happens on your device using Apple's on-device OCR. No account required, no screenshot uploads, no tracking. Delete the local index anytime.",
    phoneFirst: true,
    muted: true,
    src: "/assets/device-3.png",
    alt: "SnapFound on-device OCR processing screenshots privately on iPhone",
  },
  {
    id: "multi-language",
    eyebrow: "Multilingual search",
    headline: "Find text across languages.",
    body: "SnapFound automatically detects and indexes text from supported languages like English, Spanish, French, Japanese, Korean, Chinese, Thai, and more, privately on your iPhone.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-8.png",
    alt: "SnapFound multilingual OCR searching non-English screenshots on iPhone",
  },
  {
    id: "screenshots",
    eyebrow: "Your screenshot library",
    headline: "Every screenshot, beautifully organized.",
    body: "Browse all your screenshots in a clean date-grouped grid. Switch between 2, 3, or 4 columns to suit how you browse.",
    phoneFirst: true,
    muted: true,
    src: "/assets/device-4.png",
    alt: "SnapFound screenshot library grid view organized by date on iPhone",
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
              <div className="flex flex-1 justify-center">
                <div className="relative">
                  <div className="pointer-events-none absolute top-1/2 left-1/2 size-72 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/10 blur-3xl" />
                  <PhoneMockup className="relative">
                    <ProgressiveImage
                      alt={s.alt}
                      blurDataURL={deviceBlurDataURL}
                      className="h-auto w-65 sm:w-75"
                      height={2796}
                      placeholder="blur"
                      quality={85}
                      sizes="(max-width: 640px) 260px, 300px"
                      src={s.src}
                      width={1419}
                    />
                  </PhoneMockup>
                </div>
              </div>
            </div>
          </div>
        </section>
      ))}
    </>
  );
}
