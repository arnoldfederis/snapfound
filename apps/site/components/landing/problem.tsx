import { Layers, Lightbulb, ShieldCheck } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";

const CARDS = [
  {
    icon: Layers,
    title: "Too many screenshots",
    body: "Hundreds of screenshots accumulate fast. Finding the one you need becomes slow and frustrating — endless scrolling through a camera roll.",
  },
  {
    icon: Lightbulb,
    title: "Search by meaning",
    body: "SnapFound reads the text inside each screenshot, so you can search by what's written — not just dates or filenames.",
  },
  {
    icon: ShieldCheck,
    title: "Keep private data private",
    body: "Screenshots often hold sensitive info: banking details, verification codes, addresses, and passwords. SnapFound keeps everything on your device.",
  },
];

export function Problem() {
  return (
    <section className="py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Screenshots are useful until you need to find one.
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
            Your camera roll fills up with receipts, codes, orders, bookings,
            settings, errors, and notes. SnapFound turns your screenshot library
            into a private searchable memory.
          </p>
        </div>

        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {CARDS.map(({ icon: Icon, title, body }) => (
            <Card className="border-border/60" key={title}>
              <CardContent className="p-7">
                <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10">
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
