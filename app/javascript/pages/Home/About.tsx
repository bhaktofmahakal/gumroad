import { usePage } from "@inertiajs/react";
import * as React from "react";
import { cast } from "ts-safe-cast";

import HomeLayout from "$app/layouts/Home";

import { HomeButton } from "$app/components/Home/HomeButton";
import { type DiscoveryTag, HomeDiscoveryCarousel } from "$app/components/Home/HomeDiscoveryCarousel";
import { type Testimonial, HomeTestimonial } from "$app/components/Home/HomeTestimonial";

interface LottiePlayer extends HTMLElement {
  load: (data: Record<string, unknown>) => void;
}

function useLottieAnimation(animationData: Record<string, unknown>) {
  const lottieRef = React.useRef<LottiePlayer | null>(null);

  React.useEffect(() => {
    const loadAnimation = () => {
      const player = lottieRef.current;
      if (player?.load) {
        player.load(animationData);
      }
    };

    // Check if lottie-player is already defined
    if (customElements.get("lottie-player")) {
      // Wait for the element to be ready
      requestAnimationFrame(loadAnimation);
      return;
    }

    const script = document.createElement("script");
    script.src = "https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js";
    script.async = true;
    script.onload = () => {
      // Wait for custom element to be defined and ready
      void customElements.whenDefined("lottie-player").then(() => {
        requestAnimationFrame(loadAnimation);
      });
    };
    document.body.appendChild(script);
    // Don't remove the script on unmount since custom elements persist globally
  }, [animationData]);

  return lottieRef;
}

interface ParallaxState {
  scrollOffsetY: number;
  currentMouseX: number;
  currentMouseY: number;
  targetMouseX: number;
  targetMouseY: number;
}

function useHeroParallax() {
  React.useEffect(() => {
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mediaQuery.matches) return;

    const container = document.querySelector<HTMLElement>("[data-hero-parallax-container]");
    if (!container) return;

    const coins = Array.from(container.querySelectorAll<HTMLElement>(".hero-coin"));
    if (coins.length === 0) return;

    // Store parallax state for each coin in a Map
    const coinState = new Map<HTMLElement, ParallaxState>();
    coins.forEach((coin) => {
      coinState.set(coin, {
        scrollOffsetY: 0,
        currentMouseX: 0,
        currentMouseY: 0,
        targetMouseX: 0,
        targetMouseY: 0,
      });
    });

    let animationFrameId: number | null = null;

    function lerp(start: number, end: number, factor: number) {
      return start + (end - start) * factor;
    }

    function animate() {
      coins.forEach((coin) => {
        const state = coinState.get(coin);
        if (!state) return;

        state.currentMouseX = lerp(state.currentMouseX, state.targetMouseX, 0.1);
        state.currentMouseY = lerp(state.currentMouseY, state.targetMouseY, 0.1);

        const combinedY = state.currentMouseY + state.scrollOffsetY;
        coin.style.transform = `translate3d(${state.currentMouseX}px, ${combinedY}px, 0)`;
      });

      animationFrameId = requestAnimationFrame(animate);
    }

    const handleMouseMove = (event: MouseEvent) => {
      const rect = container.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;

      const mouseX = event.clientX;
      const mouseY = event.clientY;

      const deltaX = mouseX - centerX;
      const deltaY = mouseY - centerY;

      coins.forEach((coin) => {
        const state = coinState.get(coin);
        if (!state) return;

        const intensity = parseFloat(coin.dataset.parallaxIntensity ?? "0.05");
        state.targetMouseX = deltaX * intensity;
        state.targetMouseY = deltaY * intensity;
      });
    };

    const handleScroll = () => {
      const scrollY = window.scrollY;
      coins.forEach((coin) => {
        const state = coinState.get(coin);
        if (!state) return;

        const scrollIntensity = parseFloat(coin.dataset.scrollIntensity ?? "-0.05");
        state.scrollOffsetY = scrollY * scrollIntensity;
      });
    };

    const isTouchDeviceOrSmallScreen = window.matchMedia("(pointer: coarse)").matches || window.innerWidth < 1024;

    if (!isTouchDeviceOrSmallScreen) {
      container.addEventListener("mousemove", handleMouseMove);
    }

    animationFrameId = requestAnimationFrame(animate);

    window.addEventListener("scroll", handleScroll);
    handleScroll();

    return () => {
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
      }
      container.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);
}

type Assets = {
  arrow_right: string;
  coin_1: string;
  coin_2: string;
  coin_3: string;
  coin_4: string;
  coin_5: string;
  ukulele: string;
  make_your_road: string;
  check_circle: string;
  sell_anywhere: string;
  side_project_1: string;
  side_project_2: string;
  blog_post_circle_1: string;
  blog_post_circle_2: string;
  new_sale: string;
};

type AboutPageProps = {
  prev_week_payout: string;
  gumhead_animation_data: Record<string, unknown>;
  discovery_rows: { animation: string; tags: DiscoveryTag[] }[];
  testimonials: Testimonial[];
  assets: Assets;
};

const sellToAnyoneFeatures = [
  "Go from 0 to $1 and automated workflows.",
  "Let your customers pay in their own currency.",
  "Choose between one-time, recurring, or fixed-length payments in your currency of choice.",
];

function AboutPage() {
  const {
    prev_week_payout: prevWeekPayout,
    gumhead_animation_data: gumheadAnimationData,
    discovery_rows: discoveryRows,
    testimonials,
    assets,
  } = cast<AboutPageProps>(usePage().props);

  const lottieRef = useLottieAnimation(gumheadAnimationData);
  useHeroParallax();

  return (
    <HomeLayout>
      <div className="min-h-screen bg-gray">
        <header className="grid grid-cols-1 bg-gray">
          <div
            data-hero-parallax-container
            className="relative flex items-center justify-center px-8 py-40 md:py-56 lg:px-[8vw]"
          >
            <div className="z-10 flex max-w-3xl flex-col items-center gap-6 text-center">
              <h1 className="text-6xl leading-none md:text-7xl lg:text-8xl">
                Go from
                <br className="sm:hidden" /> <span className="whitespace-nowrap">0 to $1</span>
              </h1>
              <div className="max-w-md text-xl lg:max-w-3xl lg:text-2xl">
                Anyone can earn their first dollar online. Just start with what you know, see what sticks, and get paid.
                It's that easy.
              </div>
              <div className="mx-auto mt-2 flex w-full max-w-[384px] flex-col items-center justify-center gap-3 sm:w-auto sm:max-w-none sm:flex-row sm:gap-4">
                <div className="w-full sm:w-auto [&>div]:block!">
                  <HomeButton text="Start selling" href={Routes.new_user_registration_path()} />
                </div>
                <form action={Routes.discover_path()} method="get" className="relative w-full sm:w-auto">
                  <label htmlFor="marketplace-search" className="sr-only">
                    Search marketplace
                  </label>
                  <input
                    id="marketplace-search"
                    type="text"
                    name="query"
                    placeholder="Search marketplace ..."
                    className="dark:placeholder:!text-gray-00/50 mr-8 h-14! w-full rounded-lg border !border-dark-gray !bg-gray text-xl! focus:border-black/60 focus:ring-1 focus:ring-black focus:outline-hidden sm:w-64 lg:h-16! dark:border-gray-600 dark:!bg-dark-gray dark:bg-gray-800 dark:text-white!"
                    style={{ paddingLeft: "2rem", paddingRight: "5rem" }}
                  />
                  <button
                    type="submit"
                    aria-label="Search"
                    className="absolute top-1/2 right-0 mr-3 -translate-y-[50%] rounded-md bg-white p-2"
                    style={{ border: "1px solid #242423" }}
                  >
                    <svg
                      className="h-6 w-6 text-dark-gray"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                      />
                    </svg>
                  </button>
                </form>
              </div>
              <div className="text-base">
                <p className="text-dark-gray/50">
                  Contribute or fork on{" "}
                  <a
                    href="https://github.com/antiwork/gumroad"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="ml-1 inline-flex items-center gap-1 underline hover:text-black"
                  >
                    <svg className="h-4 w-4" viewBox="0 0 16 16" fill="currentColor">
                      <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
                    </svg>
                    GitHub
                  </a>
                </p>
              </div>
            </div>
            <div className="parallax-up pointer-events-none absolute inset-0 overflow-visible">
              <div
                className="hero-coin invisible absolute z-1 w-32 sm:top-80 sm:-right-12 sm:w-32 md:visible md:top-232 md:right-60 md:w-40 lg:top-220 lg:w-48"
                data-parallax-intensity="0.03"
                data-scroll-intensity="-0.20"
              >
                <img src={assets.coin_1} loading="lazy" alt="Decorative coin 1" className="h-auto w-full" />
              </div>
              <div
                className="hero-coin absolute top-112 left-[-12vw] z-1 w-40 sm:left-[-7vw] md:top-120 md:left-[3vw] md:w-44"
                data-parallax-intensity="-0.02"
                data-scroll-intensity="-0.15"
              >
                <img src={assets.coin_2} loading="lazy" alt="Decorative coin 2" className="h-auto w-full" />
              </div>
              <div
                className="hero-coin invisible absolute -top-28 right-[-3vw] z-1 w-36 sm:visible md:top-104 md:right-[6vw] md:w-32"
                data-parallax-intensity="0.05"
                data-scroll-intensity="-0.18"
              >
                <img src={assets.coin_3} loading="lazy" alt="Decorative coin 3" className="h-auto w-full" />
              </div>
              <div
                className="hero-coin absolute top-212 right-[-14vw] z-1 w-36 sm:top-168 sm:-right-20 md:top-176 md:-right-20 md:w-44 lg:top-184 lg:-right-16 lg:w-48"
                data-parallax-intensity="-0.035"
                data-scroll-intensity="-0.16"
              >
                <img src={assets.coin_4} loading="lazy" alt="Decorative Coin 4" className="h-auto w-full" />
              </div>
              <div
                className="hero-coin absolute top-252 -left-8 z-1 w-40 sm:top-200 sm:left-12 sm:w-40 md:top-180 md:-left-24 md:w-56 lg:-left-12 lg:w-[16rem]"
                data-parallax-intensity="0.04"
                data-scroll-intensity="-0.17"
              >
                <img src={assets.coin_5} loading="lazy" alt="Decorative Coin 5" className="h-auto w-full" />
              </div>
            </div>
          </div>
        </header>

        <div className="mx-auto flex max-w-6xl flex-col gap-8 bg-gray px-4 md:-mt-20">
          <div className="flex flex-col gap-8 lg:flex-row">
            <div className="flex h-auto flex-col rounded-3xl border border-dark-gray/50 bg-white p-8 md:relative md:h-120 lg:basis-2/3">
              <div className="order-1 md:order-0">
                <p className="text-4xl text-balance">Sell anything</p>
                <p className="mt-4 text-lg md:absolute md:bottom-8 md:left-8 md:mt-0 md:w-1/2">
                  Video lessons. Monthly subscriptions. Whatever! Gumroad was created to help you experiment with all
                  kinds of ideas and formats.
                </p>
              </div>
              <div className="order-2 mt-4 w-[484px] md:absolute md:-top-16 md:-right-2 md:order-0 md:mt-0">
                <img src={assets.ukulele} alt="Sell anything feature illustration" className="h-auto w-full" />
              </div>
            </div>
            <div className="flex h-auto flex-col overflow-hidden rounded-3xl border border-dark-gray/50 bg-white p-8 md:relative md:h-120 lg:basis-1/3">
              <div className="order-1 md:order-0">
                <p className="mb-4 text-4xl text-balance">Make your own road</p>
                <p className="mb-4 text-lg">
                  Whether you need more balance, flexibility, or just a different gig, we make it easy to chart a new
                  path.
                </p>
              </div>
              <div className="order-2 mt-8 md:absolute md:bottom-0 md:left-0 md:order-0 md:mt-0">
                <img
                  src={assets.make_your_road}
                  alt="Make your own road feature illustration"
                  className="h-auto w-full"
                />
              </div>
            </div>
          </div>
          <div className="flex flex-col gap-8 lg:flex-row">
            <div className="flex h-auto flex-col justify-between overflow-hidden rounded-3xl border border-dark-gray/50 bg-white p-8 md:h-120 lg:basis-1/3">
              <p className="mb-8 text-4xl text-balance md:mb-0">Sell to anyone</p>
              <div className="flex flex-col gap-4">
                {sellToAnyoneFeatures.map((text, index) => (
                  <div key={index} className="flex gap-4">
                    <div className="flex h-7 flex-none items-center justify-center">
                      <img src={assets.check_circle} alt="Check" className="s-5" />
                    </div>
                    <p className="text-lg text-balance">{text}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className="flex h-auto flex-col rounded-3xl border border-dark-gray/50 bg-white p-8 md:relative md:h-120 lg:basis-2/3">
              <div className="order-1 md:order-0">
                <p className="text-4xl text-balance">Sell anywhere</p>
                <p className="mt-4 text-lg md:absolute md:bottom-8 md:left-8 md:mt-0 md:w-[18rem]">
                  Create and customize your storefront with our all-in-one platform or choose to use your personal site
                  instead. Seamlessly connect your Gumroad account to thousands of apps in your current stack.
                </p>
              </div>
              <div className="order-2 mt-8 w-[389px] md:absolute md:top-8 md:-right-8 md:order-0 md:mt-0">
                <img src={assets.sell_anywhere} alt="Sell to anyone feature illustration" className="h-auto w-full" />
              </div>
            </div>
          </div>
          <div className="flex flex-col gap-9 sm:flex-row">
            <div className="flex-1 rounded-3xl border border-dark-gray/50 bg-white p-8 md:p-14">
              <div className="flex flex-col md:relative">
                <div className="order-2 md:order-0">
                  <img src={assets.side_project_1} alt="Side project 1" className="h-auto w-full" />
                </div>
                <div className="order-1 mb-4 rounded-2xl border border-black bg-white px-6 py-4 sm:px-8 md:absolute md:-top-4 md:left-0 md:order-0 md:mb-0 sm:md:-left-8">
                  <p className="m-0 text-xl font-medium">Instead of building a company...</p>
                </div>
              </div>
            </div>
            <div className="flex-1 rounded-3xl border border-dark-gray/50 bg-white p-8">
              <div className="flex flex-col md:relative">
                <div className="order-2 md:order-0">
                  <img
                    src={assets.side_project_2}
                    alt="Side project 2"
                    className="mx-auto h-auto w-full object-cover"
                  />
                </div>
                <div className="order-1 mb-4 rounded-2xl border border-black bg-white px-6 py-4 sm:px-6 md:absolute md:bottom-1 md:order-0 md:mb-0">
                  <p className="m-0 text-xl font-medium">...start selling a side project!</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="relative bg-gray py-24 lg:py-32">
          <div className="px-8 lg:px-[4vw]">
            <div className="mx-auto mb-20 max-w-4xl text-center text-4xl lg:mb-24 lg:text-5xl lg:leading-tight">
              You know all those great ideas you have?
            </div>
          </div>
          <div className="relative mx-auto mb-12 h-80 max-w-6xl border-y border-black bg-orange p-8 lg:rounded-full lg:border">
            <div
              id="lottie-animation"
              className="absolute top-1/2 left-1/2 z-20 h-56 w-56 -translate-x-1/2 -translate-y-1/2 lg:top-20 lg:h-80 lg:w-80"
            >
              <lottie-player ref={lottieRef} speed="1" loop autoplay />
            </div>
            <div className="relative z-10 flex h-full flex-col justify-between rounded-2xl border border-black bg-orange lg:rounded-full lg:px-8">
              <div className="override -mt-3 hidden justify-between px-4 md:flex lg:px-40">
                <div className="flex h-6 items-center bg-orange pr-6 lg:gap-x-10">
                  <img src={assets.arrow_right} alt="Right arrow" className="h-6 w-6 -translate-x-3" />
                  <div className="lg:text-2xl">The Gumroad Way</div>
                </div>
                <div className="flex h-6 items-center bg-orange pr-6 lg:gap-x-10">
                  <img src={assets.arrow_right} alt="Right arrow" className="h-6 w-6 -translate-x-3" />
                  <div className="lg:text-2xl">Start Small</div>
                </div>
              </div>
              <div className="override -mb-3 hidden justify-between px-4 md:flex lg:flex lg:px-40">
                <div className="flex h-6 items-center bg-orange pl-6 lg:gap-x-10">
                  <div className="lg:text-2xl">Get Better Together</div>
                  <img src={assets.arrow_right} alt="Left arrow" className="h-6 w-6 translate-x-3 rotate-180" />
                </div>
                <div className="flex h-6 items-center bg-orange pl-6 lg:gap-x-10">
                  <div className="lg:text-2xl">Learn Quickly</div>
                  <img src={assets.arrow_right} alt="Left arrow" className="h-6 w-6 translate-x-3 rotate-180" />
                </div>
              </div>
              <div className="override absolute top-0 left-1/2 -mt-3 -ml-2 flex h-6 -translate-x-1/2 items-center bg-orange pr-3 lg:hidden">
                <img src={assets.arrow_right} alt="Right arrow" className="h-4 w-4 -translate-x-2 -translate-y-px" />
                <div className="whitespace-nowrap lg:text-2xl">The Gumroad Way</div>
              </div>
              <div className="override absolute top-1/2 right-0 flex h-6 origin-center translate-x-1/2 -translate-y-1/2 rotate-90 items-center bg-orange pr-3 lg:hidden">
                <img src={assets.arrow_right} alt="Right arrow" className="h-4 w-4 -translate-x-2 -translate-y-px" />
                <div className="whitespace-nowrap lg:text-2xl">Start Small</div>
              </div>
              <div className="override absolute bottom-0 left-1/2 -mb-3 -ml-2 flex h-6 -translate-x-1/2 items-center bg-orange pl-3 lg:hidden">
                <div className="whitespace-nowrap lg:text-2xl">Get Better Together</div>
                <img
                  src={assets.arrow_right}
                  alt="Left arrow"
                  className="h-4 w-4 translate-x-2 translate-y-px rotate-180"
                />
              </div>
              <div className="override absolute top-1/2 left-0 flex h-6 origin-center -translate-x-1/2 -translate-y-1/2 -rotate-90 items-center bg-orange pr-3 lg:hidden">
                <img src={assets.arrow_right} alt="Right arrow" className="h-4 w-4 -translate-x-2 -translate-y-px" />
                <div className="whitespace-nowrap lg:text-2xl">Learn Quickly</div>
              </div>
            </div>
          </div>
          <div className="mx-auto flex max-w-4xl flex-col gap-4 px-8 text-center">
            <h2 className="text-4xl lg:text-5xl lg:leading-tight">
              We want you to try them, lots of them, and find out what works.
            </h2>
            <p className="mx-auto max-w-2xl text-xl">
              You don't have to be a tech expert or even understand how to start a business. You just gotta take what
              you know and sell it.
            </p>
            <div className="mt-4 w-full">
              <HomeButton text="Find out how" href={Routes.features_path()} />
            </div>
          </div>
        </div>

        <div className="relative w-full bg-gray">
          <div className="flex flex-col justify-center gap-8 px-8 py-20 text-center md:items-center md:gap-16 md:pt-40">
            <h1 className="text-center text-6xl font-medium sm:text-7xl md:text-9xl md:leading-[0.9] lg:text-[12rem]">
              ${prevWeekPayout}
            </h1>
            <div className="max-w-2xl text-center text-2xl text-balance md:text-3xl">
              The amount of income earned by Gumroad digital entrepreneurs last week.
            </div>
          </div>
        </div>

        <div className="mx-auto grid max-w-6xl grid-cols-1 gap-x-8 gap-y-12 bg-gray px-4 lg:grid-cols-2">
          {testimonials.map((testimonial, index) => (
            <HomeTestimonial key={index} {...testimonial} />
          ))}
        </div>

        <div className="flex flex-col gap-16 py-16 lg:gap-24 lg:py-64">
          <div className="mx-auto flex max-w-5xl flex-col justify-center gap-6 px-8 text-center lg:px-[4vw]">
            <h2 className="text-5xl md:text-6xl lg:text-7xl">Unlimited possibilities</h2>
            <p className="text-xl md:text-2xl">Discover the best-selling products and creators on Gumroad</p>
          </div>

          <HomeDiscoveryCarousel discoveryRows={discoveryRows} />
        </div>

        <div className="mx-auto flex max-w-6xl flex-col gap-8 rounded-2xl bg-gray px-4 lg:flex-row">
          <div className="flex flex-col gap-8 overflow-hidden lg:w-1/2 lg:flex-col">
            <div className="flex items-center rounded-2xl border border-dark-gray/50 bg-white px-4 py-10 md:p-10 lg:border">
              <h3 className="text-4xl font-medium md:text-5xl">
                Don't take risks.
                <br />
                That's scary!
              </h3>
            </div>
            <div className="flex items-center justify-center rounded-2xl border border-dark-gray/50 bg-white p-8 py-12 sm:p-32 md:p-32 md:py-24 lg:border lg:px-12 lg:py-10">
              <div className="relative">
                <img
                  src={assets.blog_post_circle_1}
                  alt="Sell anywhere feature illustration"
                  className="mx-auto h-auto w-full object-cover"
                  data-parallax
                />
                <div className="absolute -top-4 left-0 rounded-2xl border border-black bg-white px-6 py-4 sm:-left-8 sm:px-8">
                  <p className="m-0 text-xl font-medium">Instead of selling a book...</p>
                </div>
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-8 overflow-hidden lg:w-1/2 lg:flex-col">
            <div className="flex items-center justify-center rounded-2xl border border-dark-gray/50 bg-white p-8 py-12 sm:p-32 md:p-32 md:py-24 lg:border lg:px-12 lg:py-10">
              <div className="relative">
                <img
                  src={assets.blog_post_circle_2}
                  alt="Sell anywhere feature illustration"
                  className="mx-auto h-auto w-full object-cover"
                  data-parallax
                />
                <div className="absolute -bottom-2 left-0 rounded-2xl border border-black bg-white px-6 py-4 sm:-left-8 sm:px-6">
                  <p className="m-0 text-xl font-medium">...start by selling a blog post!</p>
                </div>
              </div>
            </div>
            <div className="flex items-center rounded-2xl border border-dark-gray/50 bg-white px-4 py-10 md:p-10 lg:border">
              <h3 className="text-4xl font-medium md:text-5xl">
                Place small bets.
                <br />
                That's exciting!
              </h3>
            </div>
          </div>
        </div>

        <div className="px-8 py-16 lg:px-[4vw] lg:py-24">
          <div className="mx-auto flex max-w-5xl flex-col gap-8 lg:flex-col lg:items-center lg:gap-16">
            <h1 className="text-center text-4xl font-medium sm:text-5xl lg:text-7xl">
              {" "}
              Share your work. <br /> Someone out there needs it.
            </h1>
            <HomeButton text="Start selling" href={Routes.new_user_registration_path()} />
          </div>
        </div>

        <img src={assets.new_sale} alt="New sale illustration" className="min-h-[300px] w-full object-cover" />
      </div>
    </HomeLayout>
  );
}

AboutPage.publicLayout = true;
export default AboutPage;
