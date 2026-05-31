"use client";

import Image from "next/image";
import { usePathname } from "next/navigation";
import { iconBlurDataURL } from "@/lib/image-placeholders";
import { cn } from "@/lib/utils";

const LINKS = [
  { label: "Privacy", href: "/privacy" },
  { label: "Terms", href: "/terms" },
  { label: "Support", href: "/support" },
];

export function Footer() {
  const path = usePathname();

  return (
    <footer className="border-t py-10">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 px-6 sm:flex-row sm:justify-between">
        <a
          className="flex items-center gap-2 font-bold text-sm tracking-tight"
          href="/"
        >
          <Image
            alt="App icon"
            blurDataURL={iconBlurDataURL}
            className="size-6"
            height={128}
            loading="eager"
            placeholder="blur"
            src="/snapfound-icon-128x128.png"
            width={128}
          />
          SnapFound
        </a>

        <nav className="flex flex-wrap justify-center gap-6">
          {LINKS.map((link) => (
            <a
              className={cn(
                "text-muted-foreground text-sm transition-colors hover:text-primary",
                {
                  "text-primary": path === link.href,
                },
              )}
              href={link.href}
              key={link.href}
            >
              {link.label}
            </a>
          ))}
        </nav>

        <p className="text-muted-foreground text-xs">
          © {new Date().getFullYear()} SnapFound
        </p>
      </div>
    </footer>
  );
}
