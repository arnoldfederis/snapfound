import { CloudOff, ShieldCheck, Smartphone, Trash2, UserX } from "lucide-react";

const ITEMS = [
  { icon: CloudOff, label: "No cloud upload" },
  { icon: UserX, label: "No account required" },
  { icon: ShieldCheck, label: "No tracking" },
  { icon: Smartphone, label: "On-device OCR" },
  { icon: Trash2, label: "Delete local index anytime" },
];

export function PrivacyStrip() {
  return (
    <section className="border-border border-y bg-secondary/40">
      <div className="mx-auto max-w-6xl px-4 py-4 sm:px-6">
        <div className="flex flex-wrap items-center justify-center gap-x-8 gap-y-2.5 sm:gap-x-12">
          {ITEMS.map(({ icon: Icon, label }) => (
            <div className="flex items-center gap-2" key={label}>
              <Icon className="h-4 w-4 shrink-0 text-muted-foreground" />
              <span className="text-muted-foreground text-sm">{label}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
