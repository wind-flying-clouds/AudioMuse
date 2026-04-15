import type { ReactNode } from "react";

const base =
  "inline-flex items-center gap-2 px-[22px] py-[11px] rounded-lg text-sm font-medium no-underline transition-opacity duration-150 hover:opacity-80";

const variants = {
  primary: "bg-ink text-bg",
  secondary: "bg-[#f5f5f5] text-muted border border-border dark:bg-[#1a1a1a]",
} as const;

type Variant = keyof typeof variants;

export function ButtonLink({
  href,
  variant,
  children,
  className,
}: {
  href: string;
  variant: Variant;
  children: ReactNode;
  className?: string;
}) {
  return (
    <a
      href={href}
      className={`${base} ${variants[variant]} ${className ?? ""}`}
    >
      {children}
    </a>
  );
}

export function Button({
  variant,
  onClick,
  children,
  className,
}: {
  variant: Variant;
  onClick?: () => void;
  children: ReactNode;
  className?: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`${base} border-0 font-[inherit] cursor-pointer ${variants[variant]} ${className ?? ""}`}
    >
      {children}
    </button>
  );
}
