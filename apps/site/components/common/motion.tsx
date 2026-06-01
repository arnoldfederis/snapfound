"use client";

type Direction = "up" | "down" | "left" | "right" | "none";

export function FadeIn({
  children,
  className,
  delay: _delay = 0,
  direction: _direction = "up",
}: {
  children: React.ReactNode;
  className?: string;
  delay?: number;
  direction?: Direction;
}) {
  return <div className={className}>{children}</div>;
}

export function Stagger({
  children,
  className,
  staggerDelay: _staggerDelay = 0.1,
}: {
  children: React.ReactNode;
  className?: string;
  staggerDelay?: number;
}) {
  return <div className={className}>{children}</div>;
}

export function StaggerItem({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={className}>{children}</div>;
}
