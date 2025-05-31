class Views::Account::Teams::Show < Views::Base
  include Phlex::Rails::Helpers::ImageURL

  def view_template
    RubyUI::Carousel(options: {loop: false}, class: "w-full max-w-xs") do
      render RubyUI::CarouselContent.new do
        5.times do |index|
          render RubyUI::CarouselItem.new do
            div(class: "p-1") do
              render RubyUI::Card.new do
                render RubyUI::CardContent.new(class: "flex aspect-square items-center justify-center p-6") do
                  span(class: "text-4xl font-semibold") { index + 1 }
                end
              end
            end
          end
        end
      end
      RubyUI::CarouselPrevious()
      RubyUI::CarouselNext()
    end

    RubyUI::Card(class: 'w-96 overflow-hidden') do
      RubyUI::AspectRatio(aspect_ratio: "16/9", class: "border-b overflow-hidden") do
        img(
          alt: "Placeholder",
          loading: "lazy",
          src: image_url('dev-marketing-tips/funnelsonrails-wide.png')
        )
      end

      render RubyUI::CardHeader.new do
        RubyUI::CardTitle { 'Introducing RubyUI' }
        RubyUI::CardDescription { "Kickstart your project today!" }
      end

      RubyUI::CardFooter(class: 'flex justify-end') do
        RubyUI::Button(variant: :outline) { "Get started" }
      end
    end
  end
end