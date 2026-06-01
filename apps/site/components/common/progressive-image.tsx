"use client";

import Image, { type ImageProps } from "next/image";
import { useEffect, useLayoutEffect, useRef, useState } from "react";

// useLayoutEffect on client (fires before paint), useEffect on server (no-op during SSR)
const useIsomorphicLayoutEffect =
  typeof window !== "undefined" ? useLayoutEffect : useEffect;

type ProgressiveImageProps = ImageProps & {
  wrapperClassName?: string;
};

export function ProgressiveImage({
  className = "",
  wrapperClassName = "",
  ...props
}: ProgressiveImageProps) {
  const ref = useRef<HTMLDivElement | null>(null);
  const [isVisible, setIsVisible] = useState(false);

  useIsomorphicLayoutEffect(() => {
    const element = ref.current;
    if (!element) return;

    // Already in or near viewport — show immediately, skip animation
    const rect = element.getBoundingClientRect();
    if (rect.top < window.innerHeight + 200 && rect.bottom > -200) {
      setIsVisible(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          setIsVisible(true);
          observer.disconnect();
        }
      },
      { rootMargin: "200px", threshold: 0.1 },
    );

    observer.observe(element);
    return () => observer.disconnect();
  }, []);

  return (
    <div
      className={[
        wrapperClassName,
        "transition-all duration-700 ease-out",
        isVisible
          ? "scale-100 opacity-100 blur-0"
          : "scale-[1.01] opacity-0 blur-md",
      ]
        .filter(Boolean)
        .join(" ")}
      ref={ref}
    >
      <Image className={className} {...props} />
    </div>
  );
}
