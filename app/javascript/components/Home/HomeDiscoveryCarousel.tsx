import { Link } from "@inertiajs/react";
import * as React from "react";

export type DiscoveryTag = {
  name: string;
  path: string;
  icon_path: string;
};

type Props = {
  discoveryRows: { animation: string; tags: DiscoveryTag[] }[];
};

export function HomeDiscoveryCarousel({ discoveryRows }: Props) {
  return (
    <div className="group flex flex-wrap justify-center gap-x-4 gap-y-6" role="list">
      {discoveryRows.map((row, rowIndex) => (
        <div
          key={rowIndex}
          className="flex w-[200%] group-hover:[animation-play-state:paused] motion-safe:animate-[marquee_20s_linear_infinite] motion-reduce:animate-none motion-safe:md:animate-[marquee_60s_linear_infinite]"
        >
          {[...row.tags, ...row.tags].map((tag, tagIndex) => (
            <div key={tagIndex} className="mr-3 flex h-auto shrink-0 items-center justify-center gap-3">
              <img
                src={tag.icon_path}
                alt={`${tag.name} icon`}
                loading="lazy"
                className="h-auto w-12 shrink-0 md:w-20"
              />
              <Link
                href={Routes.discover_taxonomy_path(tag.path, { tags: tag.name })}
                className="rounded-full border border-gray-300 bg-white px-4 py-2 text-lg font-medium whitespace-nowrap text-black no-underline transition-all hover:shadow-[4px_4px_0_0_#000000] motion-safe:hover:-translate-x-1 motion-safe:hover:-translate-y-1 md:text-2xl"
              >
                {tag.name}
              </Link>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}
