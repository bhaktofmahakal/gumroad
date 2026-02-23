# frozen_string_literal: true

class HomePresenter
  delegate :asset_path, :image_path, to: "ActionController::Base.helpers"

  def about_props
    {
      prev_week_payout: formatted_prev_week_payout,
      gumhead_animation_data: InertiaRails.once(&method(:gumhead_animation_data)),
      discovery_rows: InertiaRails.once(&method(:discovery_rows)),
      testimonials: InertiaRails.once(&method(:testimonials)),
      assets: InertiaRails.once(&method(:assets))
    }
  end

  private
    def formatted_prev_week_payout
      prev_week_payout = $redis.get(RedisKey.prev_week_payout_usd).presence || "3129297"
      ActiveSupport::NumberHelper.number_to_delimited(prev_week_payout)
    end

    def gumhead_animation_data
      gumhead_json = Rails.application.assets&.find_asset("about/gumhead.json")&.source ||
                     File.read(Rails.root.join("app/assets/images/about/gumhead.json"))
      JSON.parse(gumhead_json)
    end

    def discovery_rows
      [
        {
          animation: "marquee-left",
          tags: [
            { name: "blender", path: "3d", icon_path: image_path("discover/animation.svg") },
            { name: "meditation", path: "audio", icon_path: image_path("discover/audio.svg") },
            { name: "comic", path: "comics-and-graphic-novels", icon_path: image_path("discover/comics.svg") },
            { name: "notion template", path: "business-and-money", icon_path: image_path("discover/software.svg") },
            { name: "textures", path: "design", icon_path: image_path("discover/design.svg") },
            { name: "procreate", path: "drawing-and-painting", icon_path: image_path("discover/drawing.svg") },
            { name: "3d model", path: "3d", icon_path: image_path("discover/animation.svg") },
            { name: "hypnosis", path: "audio", icon_path: image_path("discover/audio.svg") },
            { name: "manga", path: "comics-and-graphic-novels", icon_path: image_path("discover/comics.svg") },
            { name: "investing", path: "business-and-money", icon_path: image_path("discover/software.svg") },
            { name: "mockup", path: "design", icon_path: image_path("discover/design.svg") },
            { name: "brushes", path: "drawing-and-painting", icon_path: image_path("discover/drawing.svg") },
            { name: "spark ar", path: "3d", icon_path: image_path("discover/animation.svg") },
            { name: "subliminal messages", path: "audio", icon_path: image_path("discover/audio.svg") },
            { name: "anime", path: "comics-and-graphic-novels", icon_path: image_path("discover/comics.svg") },
            { name: "instagram", path: "business-and-money", icon_path: image_path("discover/design.svg") },
            { name: "font", path: "design", icon_path: image_path("discover/design.svg") },
          ],
        },
        {
          animation: "marquee-right",
          tags: [
            { name: "art", path: "drawing-and-painting", icon_path: image_path("discover/drawing.svg") },
            { name: "after effects", path: "films", icon_path: image_path("discover/film.svg") },
            { name: "education", path: "education", icon_path: image_path("discover/education.svg") },
            { name: "fitness", path: "fitness-and-health", icon_path: image_path("discover/sports.svg") },
            { name: "sci-fi", path: "fiction-books", icon_path: image_path("discover/writing.svg") },
            { name: "vrchat", path: "gaming", icon_path: image_path("discover/games.svg") },
            { name: "ableton", path: "music-and-sound-design", icon_path: image_path("discover/music.svg") },
            { name: "certification exams", path: "education", icon_path: image_path("discover/education.svg") },
            { name: "vj loops", path: "films", icon_path: image_path("discover/film.svg") },
            { name: "workout program", path: "fitness-and-health", icon_path: image_path("discover/sports.svg") },
            { name: "poetry", path: "fiction-books", icon_path: image_path("discover/writing.svg") },
            { name: "avatar", path: "gaming", icon_path: image_path("discover/games.svg") },
            { name: "sample pack", path: "music-and-sound-design", icon_path: image_path("discover/music.svg") },
            { name: "learning", path: "education", icon_path: image_path("discover/education.svg") },
            { name: "luts", path: "films", icon_path: image_path("discover/film.svg") },
            { name: "yoga", path: "fitness-and-health", icon_path: image_path("discover/sports.svg") },
            { name: "fiction", path: "fiction-books", icon_path: image_path("discover/writing.svg") },
            { name: "assets", path: "gaming", icon_path: image_path("discover/games.svg") },
            { name: "sheet music", path: "music-and-sound-design", icon_path: image_path("discover/music.svg") },
          ],
        },
        {
          animation: "marquee-left",
          tags: [
            { name: "reference photos", path: "photography", icon_path: image_path("discover/photography.svg") },
            { name: "coloring page", path: "self-improvement", icon_path: image_path("discover/drawing.svg") },
            { name: "singles", path: "recorded-music", icon_path: image_path("discover/music.svg") },
            { name: "programming", path: "software-development", icon_path: image_path("discover/software.svg") },
            { name: "kdp interior", path: "writing-and-publishing", icon_path: image_path("discover/writing.svg") },
            { name: "stock photos", path: "photography", icon_path: image_path("discover/photography.svg") },
            { name: "printable", path: "self-improvement", icon_path: image_path("discover/crafts.svg") },
            { name: "jazz", path: "recorded-music", icon_path: image_path("discover/music.svg") },
            { name: "windows", path: "software-development", icon_path: image_path("discover/software.svg") },
            { name: "ebook", path: "writing-and-publishing", icon_path: image_path("discover/writing.svg") },
            { name: "photobash", path: "photography", icon_path: image_path("discover/photography.svg") },
            { name: "productivity", path: "self-improvement", icon_path: image_path("discover/software.svg") },
            { name: "instrumental music", path: "recorded-music", icon_path: image_path("discover/music.svg") },
            { name: "theme", path: "software-development", icon_path: image_path("discover/software.svg") },
            { name: "low content books", path: "writing-and-publishing", icon_path: image_path("discover/writing.svg") },
          ],
        },
      ]
    end

    def testimonials
      [
        {
          quote: "I launched MaxPacks as an experimental side gig; but within 2 years those Procreate brushes were earning more than my 6-figure salary in CG. Leaving in favor of Gumroad enabled me to explore other aspects of my art, develop new hobbies, and finally prioritize my personal life.",
          avatar_path: image_path("creators/max-full.png"),
          name: "Max Ulichney",
          description: "Sells Procreate brush packs",
          image_path: image_path("icons/quote-squared.svg")
        },
        {
          quote: "For years, I had a goal to develop 'passive' income streams, but struggled to make that a reality. Last year, I started selling informational products on Gumroad and since then have made $10k+ per month building products that I love.",
          avatar_path: image_path("creators/steph-full.png"),
          name: "Steph Smith",
          description: "Sells content tutorials",
          image_path: image_path("icons/quote-squared.svg")
        },
        {
          quote: "Originally, I took pre-orders for my Trend Reports on Gumroad. But I received... exactly $0. So I changed tactics: I made half of my report free, and the other half paid. Today, 99% of Trends.VC revenue is recurring in the form of annual and quarterly subscriptions.",
          avatar_path: image_path("creators/dru-full.png"),
          name: "trendsvc",
          description: "Sells business insights and expertise",
          image_path: image_path("icons/quote-squared.svg")
        },
        {
          quote: "I love Gumroad because it can't be any simpler. I upload a file, set a price, and I can start selling on the internet. The money I make from my sales lands directly in my bank account every Friday.",
          avatar_path: image_path("creators/daniel-full.png"),
          name: "Daniel Vassallo",
          description: "Sells business insights and expertise",
          image_path: image_path("icons/quote-squared.svg")
        }
      ]
    end

    def assets
      {
        arrow_right: image_path("about/arrowhead-right.svg"),
        coin_1: image_path("about/coin-1.svg"),
        coin_2: image_path("about/coin-2.svg"),
        coin_3: image_path("about/coin-3.svg"),
        coin_4: image_path("about/coin-4.svg"),
        coin_5: image_path("about/coin-5.svg"),
        ukulele: image_path("about/ukulele.png"),
        make_your_road: image_path("about/make-your-road.svg"),
        check_circle: image_path("icons/outline-check-circle-about.svg"),
        sell_anywhere: image_path("about/sell-anywhere.png"),
        side_project_1: image_path("about/side-project-1.svg"),
        side_project_2: image_path("about/side-project-2.svg"),
        blog_post_circle_1: image_path("about/blog-post-circle-1.svg"),
        blog_post_circle_2: image_path("about/blog-post-circle-2.svg"),
        new_sale: image_path("about/new-sale.svg")
      }
    end
end
