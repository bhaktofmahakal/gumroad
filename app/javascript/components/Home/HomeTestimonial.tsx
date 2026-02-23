import * as React from "react";

export type Testimonial = {
  quote: string;
  avatar_path: string;
  name: string;
  description: string;
  image_path: string;
};

export function HomeTestimonial({ quote, avatar_path, name, description, image_path }: Testimonial) {
  return (
    <div className="space-y-6">
      <div className="relative rounded-3xl rounded-tl-3xl rounded-tr-3xl rounded-br-3xl rounded-bl-sm border border-dark-gray/50 bg-white px-8 py-4">
        <div className="mb-4">
          <img src={image_path} alt="Quote" className="h-3 w-5" />
        </div>
        <blockquote className="text-xl leading-relaxed font-medium text-black">{quote}</blockquote>
      </div>
      <div className="flex items-center gap-4 pl-2">
        <div className="rounded-full p-1">
          <div className="flex h-12 w-12 items-center justify-center overflow-hidden rounded-full bg-white">
            <img src={avatar_path} alt={name} className="h-full w-full rounded-full object-cover" />
          </div>
        </div>
        <div>
          <h3 className="text-lg font-bold text-black">{name}</h3>
          <p className="text-sm text-black">{description}</p>
        </div>
      </div>
    </div>
  );
}
