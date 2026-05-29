"use client";

import { Menu, Search, X } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

const NAV_LINKS = [
  { label: "Features", href: "#features" },
  { label: "Privacy", href: "#privacy" },
  { label: "Pricing", href: "#pricing" },
  { label: "FAQ", href: "#faq" },
];

export function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 12);
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header
      className={cn(
        "fixed inset-x-0 top-0 z-50 transition-all duration-300",
        scrolled
          ? "border-border/60 border-b bg-background/85 backdrop-blur-2xl"
          : "bg-transparent",
      )}
    >
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6">
        {/* Wordmark */}
        <a className="flex items-center gap-2.5" href="/apps/site/public">
          <div className="flex h-8 w-8 items-center justify-center rounded-[10px] bg-primary shadow-sm">
            <Search className="h-4 w-4 text-primary-foreground" />
          </div>
          <span className="font-semibold text-[15px] tracking-tight">
            SnapFound
          </span>
        </a>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-7 md:flex">
          {NAV_LINKS.map(({ label, href }) => (
            <a
              className="text-muted-foreground text-sm transition-colors hover:text-foreground"
              href={href}
              key={label}
            >
              {label}
            </a>
          ))}
        </nav>

        {/* CTA + mobile toggle */}
        <div className="flex items-center gap-3">
          <Button asChild className="hidden sm:inline-flex" size="sm">
            <a href={APP_STORE_URL}>Download</a>
          </Button>
          <button
            aria-label="Toggle navigation"
            className="flex h-9 w-9 items-center justify-center rounded-xl text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground md:hidden"
            onClick={() => setMenuOpen((o) => !o)}
            type="button"
          >
            {menuOpen ? (
              <X className="h-5 w-5" />
            ) : (
              <Menu className="h-5 w-5" />
            )}
          </button>
        </div>
      </div>

      {/* Mobile drawer */}
      {menuOpen && (
        <div className="border-border border-t bg-background/95 backdrop-blur-2xl md:hidden">
          <nav className="flex flex-col gap-1 px-4 py-3">
            {NAV_LINKS.map(({ label, href }) => (
              <a
                className="rounded-xl px-3 py-2.5 font-medium text-muted-foreground text-sm transition-colors hover:bg-secondary hover:text-foreground"
                href={href}
                key={label}
                onClick={() => setMenuOpen(false)}
              >
                {label}
              </a>
            ))}
          </nav>
          <div className="border-border border-t px-4 py-4">
            <Button asChild className="w-full" size="sm">
              <a href={APP_STORE_URL}>Download on the App Store</a>
            </Button>
          </div>
        </div>
      )}
    </header>
  );
}
