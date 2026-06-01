import { FadeIn } from "@/components/common/motion";
import { ProgressiveImage } from "@/components/common/progressive-image";
import { deviceBlurDataURL } from "@/lib/image-placeholders";

export function ScreenshotGallery() {
  return (
    <section className="overflow-hidden border-y py-24">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-16 max-w-2xl text-center">
          <h2 className="font-bold text-4xl leading-[1.1] tracking-tight sm:text-5xl">
            Make your screenshots instantly searchable.
          </h2>
          <p className="mt-5 text-lg text-muted-foreground leading-relaxed">
            SnapFound reads text from your indexed screenshots and makes them
            easy to find later. Search for a word, code, receipt, booking, or
            note and get back to the right screenshot quickly.
          </p>
        </FadeIn>

        {/* 3-phone lineup, center elevated */}
        <FadeIn
          className="relative flex items-end justify-center gap-4 sm:gap-6"
          delay={0.15}
        >
          {/* Glow */}
          <div className="pointer-events-none absolute top-1/2 left-1/2 size-[500px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/10 blur-3xl" />

          {/* Left */}
          <div className="relative translate-y-10 opacity-75">
            <ProgressiveImage
              alt="SnapFound screenshot detail view on iPhone"
              blurDataURL={deviceBlurDataURL}
              className="h-auto w-44 sm:w-52"
              height={2796}
              placeholder="blur"
              quality={85}
              sizes="(max-width: 640px) 176px, 208px"
              src="/assets/device-7.png"
              width={1419}
            />
          </div>

          {/* Center — most prominent */}
          <div className="relative z-10">
            <ProgressiveImage
              alt="SnapFound search results showing matched screenshots on iPhone"
              blurDataURL={deviceBlurDataURL}
              className="h-auto w-56 sm:w-64"
              height={2796}
              placeholder="blur"
              quality={85}
              sizes="(max-width: 640px) 224px, 256px"
              src="/assets/device-2.png"
              width={1419}
            />
          </div>

          {/* Right */}
          <div className="relative translate-y-10 opacity-75">
            <ProgressiveImage
              alt="SnapFound multilingual search finding non-English screenshots on iPhone"
              blurDataURL={deviceBlurDataURL}
              className="h-auto w-44 sm:w-52"
              height={2796}
              placeholder="blur"
              quality={85}
              sizes="(max-width: 640px) 176px, 208px"
              src="/assets/device-8.png"
              width={1419}
            />
          </div>
        </FadeIn>
      </div>
    </section>
  );
}
