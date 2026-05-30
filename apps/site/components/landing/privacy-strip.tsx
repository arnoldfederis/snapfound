import {
  CloudOffIcon,
  ShieldCheckIcon,
  SmartphoneIcon,
  Trash2Icon,
  UserXIcon,
} from "lucide-react";

const ITEMS = [
  { icon: CloudOffIcon, label: "No cloud upload" },
  { icon: UserXIcon, label: "No account required" },
  { icon: ShieldCheckIcon, label: "No tracking" },
  { icon: SmartphoneIcon, label: "On-device OCR" },
  { icon: Trash2Icon, label: "Delete local index anytime" },
];

export function PrivacyStrip() {
  return (
    <section className="border-b bg-muted/30 py-10">
      <div className="mx-auto max-w-6xl px-6">
        <p className="mb-6 text-center text-muted-foreground text-sm">
          Your screenshots never leave your iPhone
        </p>
        <div className="flex flex-wrap items-center justify-center gap-x-10 gap-y-4">
          {ITEMS.map(({ icon: Icon, label }) => (
            <div
              className="flex items-center gap-2 font-medium text-muted-foreground text-sm"
              key={label}
            >
              <Icon className="size-4" />
              {label}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
