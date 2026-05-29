const STEPS = [
  {
    number: "01",
    title: "Allow screenshot access",
    body: "SnapFound scans accessible screenshots from your Photos library. You stay in control of what's shared.",
  },
  {
    number: "02",
    title: "Index locally",
    body: "OCR, tags, and metadata are created entirely on your iPhone. The searchable index never leaves your device.",
  },
  {
    number: "03",
    title: "Search naturally",
    body: 'Find screenshots by typing things like "receipt," "Wi-Fi password," or "flight from last month."',
  },
];

export function HowItWorks() {
  return (
    <section className="py-24" id="how-it-works">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Private search in three steps.
          </h2>
          <p className="mx-auto max-w-xl text-lg text-muted-foreground">
            SnapFound is designed to be simple, private, and fast from the
            start.
          </p>
        </div>

        <div className="relative grid gap-10 sm:grid-cols-3">
          {/* Connector */}
          <div
            aria-hidden
            className="absolute top-11 right-0 left-0 hidden h-px bg-gradient-to-r from-transparent via-border to-transparent sm:block"
          />

          {STEPS.map(({ number, title, body }) => (
            <div
              className="relative flex flex-col items-center text-center"
              key={number}
            >
              <div className="relative z-10 mb-7 flex h-[88px] w-[88px] items-center justify-center rounded-full border border-border bg-background shadow-sm">
                <span className="font-extrabold text-3xl text-primary tracking-tight">
                  {number}
                </span>
              </div>
              <h3 className="mb-3 font-semibold text-lg">{title}</h3>
              <p className="text-muted-foreground text-sm leading-relaxed">
                {body}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
