import {
  LockIcon,
  SearchIcon,
  SmartphoneIcon,
  WifiOffIcon,
} from "lucide-react";
import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const FEATURES = [
  {
    icon: SmartphoneIcon,
    title: "On-device OCR",
    description:
      "Text is read from each screenshot on your iPhone. Nothing is sent to a server.",
  },
  {
    icon: SearchIcon,
    title: "Search by content",
    description:
      "Type what you remember: a receipt total, a booking reference, a Wi-Fi password. Find it instantly.",
  },
  {
    icon: WifiOffIcon,
    title: "Works offline",
    description:
      "Your index lives on your device. Search works without any internet connection.",
  },
  {
    icon: LockIcon,
    title: "Private by design",
    description:
      "No account. No tracking. No cloud upload. Delete the local index anytime.",
  },
];

export function FeatureGrid() {
  return (
    <section className="py-20" id="features">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Search what's inside your screenshots.
          </h2>
        </FadeIn>

        <Stagger
          className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4"
          staggerDelay={0.1}
        >
          {FEATURES.map((f) => (
            <StaggerItem key={f.title}>
              <div className="flex flex-col gap-3">
                <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10">
                  <f.icon className="size-5 text-primary" />
                </div>
                <h3 className="font-semibold">{f.title}</h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {f.description}
                </p>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
