import { Lock, Plane, Receipt, Search, ShoppingBag, Wifi } from "lucide-react";

const CHIPS = [
  { label: "Receipts", icon: Receipt },
  { label: "Wi-Fi", icon: Wifi },
  { label: "Orders", icon: ShoppingBag },
  { label: "Flights", icon: Plane },
];

const GRID_COLORS = [
  "bg-indigo-100 dark:bg-indigo-950",
  "bg-amber-100 dark:bg-amber-950",
  "bg-emerald-100 dark:bg-emerald-950",
  "bg-rose-100 dark:bg-rose-950",
  "bg-sky-100 dark:bg-sky-950",
  "bg-violet-100 dark:bg-violet-950",
  "bg-orange-100 dark:bg-orange-950",
  "bg-teal-100 dark:bg-teal-950",
  "bg-neutral-200 dark:bg-neutral-800",
];

export function PhoneMockup() {
  return (
    <div className="relative mx-auto w-[270px] sm:w-[300px]">
      {/* Ambient glow */}
      <div className="absolute inset-4 -z-10 rounded-[52px] bg-primary/25 blur-3xl" />

      {/* Phone shell */}
      <div className="relative rounded-[44px] border-[7px] border-neutral-800 bg-neutral-900 shadow-2xl dark:border-neutral-700">
        {/* Dynamic island */}
        <div className="absolute top-2.5 left-1/2 z-10 h-[26px] w-[90px] -translate-x-1/2 rounded-full bg-neutral-900" />

        {/* Screen */}
        <div
          className="overflow-hidden rounded-[37px] bg-[oklch(98%_0_0)] dark:bg-[oklch(10%_0_0)]"
          style={{ aspectRatio: "9/19.5" }}
        >
          {/* Status bar */}
          <div className="flex items-center justify-between px-6 pt-10 pb-1">
            <span className="font-semibold text-[11px] text-neutral-800 tabular-nums dark:text-neutral-100">
              9:41
            </span>
            <div className="flex items-center gap-1">
              <div className="flex items-end gap-[2px]">
                {[3, 5, 7, 9].map((h, i) => (
                  <div
                    className={`w-[3px] rounded-sm bg-neutral-700 dark:bg-neutral-300 ${i < 3 ? "opacity-40" : ""}`}
                    key={h}
                    style={{ height: h }}
                  />
                ))}
              </div>
              <div className="ml-0.5 flex h-[9px] w-[14px] items-center rounded-[2px] border border-neutral-700/60 px-[1px] dark:border-neutral-300/60">
                <div className="h-[5px] w-[8px] rounded-[1px] bg-neutral-700 dark:bg-neutral-300" />
              </div>
            </div>
          </div>

          {/* App title */}
          <div className="px-4 pt-2 pb-1">
            <p className="font-bold text-[18px] text-neutral-900 dark:text-neutral-50">
              Screenshots
            </p>
          </div>

          {/* Search bar */}
          <div className="px-4 pb-3">
            <div className="flex h-8 items-center gap-2 rounded-[10px] bg-neutral-200/90 px-2.5 dark:bg-neutral-800">
              <Search className="h-3.5 w-3.5 shrink-0 text-neutral-500" />
              <span className="text-[13px] text-neutral-500">
                hotel booking
              </span>
            </div>
          </div>

          {/* Category chips */}
          <div className="flex gap-1.5 overflow-hidden px-4 pb-3">
            {CHIPS.map(({ label, icon: Icon }) => (
              <div
                className="flex shrink-0 items-center gap-1 rounded-full bg-primary/10 px-2 py-[3px] font-medium text-[10px] text-primary"
                key={label}
              >
                <Icon className="h-2.5 w-2.5" />
                {label}
              </div>
            ))}
          </div>

          {/* Screenshot grid */}
          <div className="grid grid-cols-3 gap-[2px] px-4">
            {GRID_COLORS.map((color, i) => (
              <div className={`aspect-[9/16] rounded-lg ${color}`} key={i} />
            ))}
          </div>

          {/* Privacy badge */}
          <div className="flex justify-center pt-3 pb-4">
            <div className="flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 dark:border-emerald-800 dark:bg-emerald-950">
              <Lock className="h-2.5 w-2.5 text-emerald-600 dark:text-emerald-400" />
              <span className="font-medium text-[10px] text-emerald-700 dark:text-emerald-300">
                On-device only
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
