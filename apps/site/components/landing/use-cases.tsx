import {
  AlertTriangleIcon,
  Building2Icon,
  FileTextIcon,
  KeyRoundIcon,
  MapPinIcon,
  PackageIcon,
  PlaneIcon,
  ReceiptIcon,
  ShoppingBagIcon,
  WifiIcon,
} from "lucide-react";
import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const USE_CASES = [
  { icon: ReceiptIcon, label: "Receipts", query: "store receipt June" },
  { icon: WifiIcon, label: "Wi-Fi passwords", query: "wifi password" },
  { icon: Building2Icon, label: "Hotel bookings", query: "hotel confirmation" },
  { icon: PlaneIcon, label: "Flights", query: "flight boarding pass" },
  { icon: ShoppingBagIcon, label: "Orders", query: "order confirmation" },
  { icon: PackageIcon, label: "Tracking numbers", query: "tracking shipped" },
  { icon: AlertTriangleIcon, label: "Error messages", query: "error code" },
  { icon: KeyRoundIcon, label: "Verification codes", query: "2FA code" },
  { icon: FileTextIcon, label: "Meeting notes", query: "meeting agenda" },
  { icon: MapPinIcon, label: "Maps", query: "directions address" },
];

export function UseCases() {
  return (
    <section className="py-20">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-2xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Find the screenshot you actually need.
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            SnapFound handles the things you screenshot every day.
          </p>
        </FadeIn>

        <Stagger
          className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5"
          staggerDelay={0.07}
        >
          {USE_CASES.map(({ icon: Icon, label, query }) => (
            <StaggerItem key={label}>
              <div className="group flex flex-col items-center gap-3 rounded-2xl border bg-card p-5 text-center transition-all hover:border-primary/30 hover:shadow-lg hover:shadow-primary/5">
                <div className="flex size-10 items-center justify-center rounded-xl bg-muted transition-colors group-hover:bg-primary/10">
                  <Icon className="size-5 text-muted-foreground transition-colors group-hover:text-primary" />
                </div>
                <div>
                  <p className="font-medium text-sm">{label}</p>
                  <p className="mt-0.5 text-muted-foreground text-xs">
                    "{query}"
                  </p>
                </div>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
