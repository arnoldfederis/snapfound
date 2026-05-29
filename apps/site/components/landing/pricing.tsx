import { Check } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

// TODO: Set actual price when available on App Store
const PRO_PRICE = "One-time purchase";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

const FREE_FEATURES = [
  "Index up to 50 screenshots",
  "Local OCR",
  "Private search",
  "No account required",
];

const PRO_FEATURES = [
  "Unlimited screenshot indexing",
  "One-time purchase",
  "No subscription ever",
  "Restore with Apple ID",
  "Private local processing",
];

export function Pricing() {
  return (
    <section className="bg-secondary/20 py-24" id="pricing">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Start free. Unlock once.
          </h2>
          <p className="mx-auto max-w-xl text-lg text-muted-foreground">
            No subscription. No account. Pay once, use forever.
          </p>
        </div>

        <div className="mx-auto grid max-w-2xl gap-5 sm:grid-cols-2">
          {/* Free */}
          <Card className="border-border/60">
            <CardContent className="p-7">
              <p className="mb-1 font-medium text-muted-foreground text-sm">
                Free
              </p>
              <p className="mb-7 font-bold text-3xl">$0</p>
              <ul className="space-y-3">
                {FREE_FEATURES.map((f) => (
                  <li className="flex items-center gap-2.5" key={f}>
                    <Check className="h-4 w-4 shrink-0 text-muted-foreground" />
                    <span className="text-sm">{f}</span>
                  </li>
                ))}
              </ul>
            </CardContent>
          </Card>

          {/* Pro */}
          <Card className="relative border-primary/30 shadow-lg">
            <div className="absolute -top-3.5 left-1/2 -translate-x-1/2">
              <Badge className="shadow-sm">Pro</Badge>
            </div>
            <CardContent className="p-7">
              <p className="mb-1 font-medium text-muted-foreground text-sm">
                SnapFound Pro
              </p>
              <p className="mb-7 font-bold text-3xl">{PRO_PRICE}</p>
              <ul className="mb-7 space-y-3">
                {PRO_FEATURES.map((f) => (
                  <li className="flex items-center gap-2.5" key={f}>
                    <Check className="h-4 w-4 shrink-0 text-primary" />
                    <span className="font-medium text-sm">{f}</span>
                  </li>
                ))}
              </ul>
              <Button asChild className="w-full shadow-sm">
                <a href={APP_STORE_URL}>Unlock in the iOS app</a>
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  );
}
