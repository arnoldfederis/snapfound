import { cn } from "@/lib/utils";

export function PhoneMockup({
  className,
  children,
}: {
  className?: string;
  children?: React.ReactNode;
}) {
  return <div className={cn("relative", className)}>{children}</div>;
}
