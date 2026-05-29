import {
  AlertTriangle,
  Building2,
  FileText,
  KeyRound,
  MapPin,
  Package,
  Plane,
  Receipt,
  ShoppingBag,
  Wifi,
} from "lucide-react";

const USE_CASES = [
  { icon: Receipt, label: "Receipts", query: "store receipt June" },
  { icon: Wifi, label: "Wi-Fi passwords", query: "wifi password network" },
  { icon: Building2, label: "Hotel bookings", query: "hotel confirmation" },
  { icon: Plane, label: "Flights", query: "flight boarding pass" },
  { icon: ShoppingBag, label: "Orders", query: "order confirmation" },
  {
    icon: Package,
    label: "Tracking numbers",
    query: "tracking number shipped",
  },
  { icon: AlertTriangle, label: "Error messages", query: "error code failed" },
  {
    icon: KeyRound,
    label: "Verification codes",
    query: "2FA verification code",
  },
  { icon: FileText, label: "Meeting notes", query: "meeting agenda notes" },
  { icon: MapPin, label: "Maps", query: "directions address" },
];

export function UseCases() {
  return (
    <section className="bg-secondary/20 py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mb-16 text-center">
          <h2 className="mb-4 font-bold text-3xl tracking-tight sm:text-4xl">
            Find the screenshot you actually need.
          </h2>
          <p className="mx-auto max-w-xl text-lg text-muted-foreground">
            SnapFound handles the things you screenshot every day.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
          {USE_CASES.map(({ icon: Icon, label, query }) => (
            <div
              className="group flex flex-col items-center gap-3 rounded-2xl border border-border/60 bg-card p-5 text-center transition-all duration-200 hover:border-primary/30 hover:shadow-sm"
              key={label}
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-secondary transition-colors duration-200 group-hover:bg-primary/10">
                <Icon className="h-5 w-5 text-muted-foreground transition-colors duration-200 group-hover:text-primary" />
              </div>
              <div>
                <p className="font-medium text-sm">{label}</p>
                <p className="mt-0.5 text-muted-foreground text-xs">
                  "{query}"
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
