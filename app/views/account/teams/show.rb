class Views::Account::Teams::Show < Views::Base
  include Phlex::Rails::Helpers::ImageURL

  def view_template
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