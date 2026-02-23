import React from "react";

import { HomeFooter } from "$app/components/Home/Shared/Footer";
import { HomeNav } from "$app/components/Home/Shared/Nav";

type Props = {
  children: React.ReactNode;
};

export default function HomeLayout({ children }: Props) {
  return (
    <div className="flex flex-1 flex-col bg-white text-black">
      <div className="flex flex-1 flex-col font-['ABC_Favorit'] text-base leading-relaxed font-normal tracking-tight">
        <HomeNav />
        <div className="flex-1 overflow-hidden">{children}</div>
      </div>
      <HomeFooter />
    </div>
  );
}
