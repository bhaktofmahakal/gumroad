import { Link } from "@inertiajs/react";
import * as React from "react";

type HomeButtonProps = {
  text: string;
  href: string;
  variant?: "light" | "dark" | "pink";
  size?: "small" | "default";
  type?: "link" | "submit";
};

const variantClasses = {
  light: "bg-black text-white",
  dark: "bg-white text-black",
  pink: "bg-pink text-black",
};

const sizeClasses = {
  small: "h-12 px-3 text-base lg:h-12 lg:px-6 lg:text-base",
  default: "h-14 px-8 text-xl lg:h-16 lg:px-10 lg:text-xl",
};

export function HomeButton({ text, href, variant = "light", size = "default", type = "link" }: HomeButtonProps) {
  const buttonClasses = `relative inline-flex rounded-sm no-underline items-center justify-center border border-black transition-all duration-150 group-hover:-translate-x-2 group-hover:-translate-y-2 z-3 w-full lg:w-auto cursor-pointer ${sizeClasses[size]} ${variantClasses[variant]}`;

  return (
    <div className="group relative inline-block">
      <div className="absolute inset-0 z-2 rounded-sm border border-black bg-yellow transition-transform duration-150" />
      <div className="absolute inset-0 z-1 rounded-sm border border-black bg-red transition-transform duration-150 group-hover:translate-x-2 group-hover:translate-y-2" />
      {type === "submit" ? (
        <button type="submit" className={buttonClasses}>
          {text}
        </button>
      ) : (
        <Link href={href} className={buttonClasses}>
          {text}
        </Link>
      )}
    </div>
  );
}
