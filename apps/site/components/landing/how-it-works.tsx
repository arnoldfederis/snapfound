import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const STEPS = [
  {
    step: "1",
    title: "Take screenshots normally",
    description:
      "No change to your workflow. SnapFound works with screenshots already on your iPhone.",
  },
  {
    step: "2",
    title: "SnapFound reads the text",
    description:
      "On-device OCR extracts the text from each screenshot during indexing. Text extraction happens entirely on your iPhone.",
  },
  {
    step: "3",
    title: "Search what you remember",
    description:
      "Type a word or phrase from a screenshot, like a price, code, name, or booking reference.",
  },
];

export function HowItWorks() {
  return (
    <section className="bg-muted/40 py-24" id="how-it-works">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            How it works.
          </h2>
        </FadeIn>

        <Stagger
          className="mx-auto grid max-w-3xl gap-10 sm:grid-cols-3"
          staggerDelay={0.1}
        >
          {STEPS.map((s) => (
            <StaggerItem key={s.step}>
              <div className="flex flex-col gap-3">
                <span className="font-bold text-4xl text-primary/20 tabular-nums leading-none">
                  {s.step}
                </span>
                <h3 className="font-semibold">{s.title}</h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {s.description}
                </p>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
