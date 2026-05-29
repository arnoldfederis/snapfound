import {
  Images,
  Lock,
  ScanText,
  Search,
  Sparkles,
  WifiOff,
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";

const FEATURES = [
  {
    icon: Search,
    title: "Smart screenshot search",
    body: "Search by text, tags, and dates. Find exactly what you need without scrolling through hundreds of screenshots.",
  },
  {
    icon: ScanText,
    title: "Private OCR",
    body: "Text is extracted on your iPhone using on-device machine learning. Nothing is sent to a server.",
  },
  {
    icon: Lock,
    title: "Screenshot-only indexing",
    body: "SnapFound focuses on screenshots, not your entire photo library. Your personal photos stay private.",
  },
  {
    icon: Images,
    title: "Photos-like browsing",
    body: "Browse, search, and open screenshots in a familiar iOS-style interface that feels native on iPhone.",
  },
  {
    icon: WifiOff,
    title: "Fast local index",
    body: "Indexed screenshots are searchable even when offline. No internet connection required to search.",
  },
  {
    icon: Sparkles,
    title: "Pro unlock",
    body: "Start with 50 screenshots for free, then unlock unlimited indexing with a one-time purchase.",
  },
];

export function FeatureGrid() {
  return (
    <section className="bg-secondary/20 py-24" id="features">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Search what's inside your screenshots.
          </h2>
          <p className="mx-auto max-w-xl text-lg text-muted-foreground">
            Built to work privately, offline, and exactly the way you'd expect
            from a native iPhone app.
          </p>
        </div>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map(({ icon: Icon, title, body }) => (
            <Card
              className="group border-border/60 transition-shadow duration-200 hover:shadow-md"
              key={title}
            >
              <CardContent className="p-7">
                <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 transition-colors duration-200 group-hover:bg-primary/15">
                  <Icon className="h-5 w-5 text-primary" />
                </div>
                <h3 className="mb-2 font-semibold">{title}</h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {body}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
