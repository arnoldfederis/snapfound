import { CheckIcon } from "lucide-react";
import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";
import { buttonVariants } from "@/components/ui/button";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

const PLANS = [
  {
    name: "Free",
    price: "$0",
    description: "Get started with no commitment.",
    cta: "Download free",
    ctaVariant: "outline" as const,
    features: [
      "Index up to 50 screenshots",
      "Full-text search",
      "On-device OCR",
      "No account required",
    ],
  },
  {
    name: "SnapFound Pro",
    price: "One-time purchase",
    description: "Unlock everything, pay once.",
    cta: "Get Pro",
    ctaVariant: "default" as const,
    features: [
      "Unlimited screenshots",
      "Everything in Free",
      "Future updates included",
      "No subscription, ever",
    ],
    highlight: true,
  },
];

export function Pricing() {
  return (
    <section className="py-20" id="pricing">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Simple pricing.
          </h2>
          <p className="mt-4 text-muted-foreground">
            Start free. Upgrade once when you're ready.
          </p>
        </FadeIn>

        <Stagger
          className="mx-auto grid max-w-3xl gap-6 sm:grid-cols-2"
          staggerDelay={0.1}
        >
          {PLANS.map((plan) => (
            <StaggerItem key={plan.name}>
              <div
                className={`flex h-full flex-col rounded-2xl border p-8 ${
                  plan.highlight
                    ? "border-primary/30 bg-primary/[0.03]"
                    : "bg-card"
                }`}
              >
                <div className="mb-6">
                  <p className="font-semibold">{plan.name}</p>
                  <p className="mt-1 font-bold text-2xl tracking-tight">
                    {plan.price}
                  </p>
                  <p className="mt-1 text-muted-foreground text-sm">
                    {plan.description}
                  </p>
                </div>

                <ul className="mb-8 flex flex-1 flex-col gap-2.5">
                  {plan.features.map((f) => (
                    <li className="flex items-center gap-2.5 text-sm" key={f}>
                      <CheckIcon className="size-4 shrink-0 text-primary" />
                      {f}
                    </li>
                  ))}
                </ul>

                <a
                  className={buttonVariants({
                    variant: plan.ctaVariant,
                    size: "sm",
                  })}
                  href={APP_STORE_URL}
                >
                  {plan.cta}
                </a>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
