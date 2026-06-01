"use client";

import Image from "next/image";
import { ThemeSwitcher } from "@/components/common/theme-switcher";
import { buttonVariants } from "@/components/ui/button";
import { iconBlurDataURL } from "@/lib/image-placeholders";

// TODO: Replace with actual App Store URL when available
const APP_STORE_URL = "#";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-border/50 border-b bg-background/80 backdrop-blur-lg">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
        <a
          className="flex items-center gap-2 font-bold text-xl tracking-tight"
          href="/"
        >
          <Image
            alt="App icon"
            blurDataURL={iconBlurDataURL}
            className="size-8"
            height={128}
            placeholder="blur"
            priority
            quality={85}
            src="/snapfound-icon-128x128.png"
            width={128}
          />
          SnapFound
        </a>

        <div className="flex items-center gap-2">
          <ThemeSwitcher />
          <a className={buttonVariants({ size: "sm" })} href={APP_STORE_URL}>
            Download
          </a>
        </div>
      </div>
    </header>
  );
}
