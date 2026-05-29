import { Search } from "lucide-react";
import { Separator } from "@/components/ui/separator";

const YEAR = new Date().getFullYear();

export function Footer() {
  return (
    <footer className="border-border border-t py-14">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="flex flex-col gap-8 sm:flex-row sm:items-start sm:justify-between">
          {/* Brand */}
          <div>
            <div className="mb-2 flex items-center gap-2">
              <div className="flex h-7 w-7 items-center justify-center rounded-[8px] bg-primary">
                <Search className="h-3.5 w-3.5 text-primary-foreground" />
              </div>
              <span className="font-semibold text-sm">SnapFound</span>
            </div>
            <p className="text-muted-foreground text-xs">
              Private screenshot search for iPhone.
            </p>
          </div>

          {/* Links */}
          <nav
            aria-label="Footer navigation"
            className="flex flex-col gap-2.5 sm:items-end"
          >
            <a
              className="text-muted-foreground text-xs transition-colors hover:text-foreground"
              href="https://snapfound.app/privacy"
            >
              Privacy Policy
            </a>
            <a
              className="text-muted-foreground text-xs transition-colors hover:text-foreground"
              href="https://snapfound.app/support"
            >
              Support
            </a>
            <a
              className="text-muted-foreground text-xs transition-colors hover:text-foreground"
              href="mailto:hello@snapfound.app"
            >
              Contact
            </a>
          </nav>
        </div>

        <Separator className="my-8" />

        <p className="text-center text-muted-foreground text-xs">
          &copy; {YEAR} SnapFound. All rights reserved.
        </p>
      </div>
    </footer>
  );
}
