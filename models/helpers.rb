module Helpers
  public

  def link_tag(display_name:, url:, rel: nil, id_attr: nil, class_attr: nil)
    if url
      attrs = ["href='#{url}'"]
      attrs << "rel='#{rel}'" unless rel.nil?
      attrs << "id='#{id_attr}'" unless id_attr.nil?
      attrs << "class='#{class_attr}'" unless class_attr.nil?
      attrs << "target='_blank'" unless url.start_with?("/")

      "<a #{attrs.join(" ")}>#{display_name}</a>"
    else
      display_name
    end
  end

  def link_for(
    identifier,
    display_name: nil,
    show_location_details: false,
    omit_if_no_url: false,
    rel: nil,
    use_long_name: false,
    selected_url: :url
  )
    if (entity = Subject.find_by(short_name: identifier) || Location.find_by(short_name: identifier))
      return if omit_if_no_url && entity.public_send(selected_url).nil?
      display_name = if !display_name && use_long_name && entity.respond_to?(:long_name) && entity.long_name
        entity.long_name
      else
        display_name || entity.display_name
      end

      tag = link_tag(display_name: display_name, url: entity.public_send(selected_url))
      if (show_location_details && entity.is_a?(Location))
        tag = "#{tag}, #{entity.details}"
      end

      tag
    else
      puts("WARNING: Could not find '#{identifier}' in the directory")
      omit_if_no_url ? "" : identifier
    end
  end

  def display_name(identifier)
    entity = Subject.find_by(short_name: identifier) || Location.find_by(short_name: identifier)
    if entity
      entity.display_name
    else
      identifier
    end
  end

  def site_footer
    ERB.new(File.read(File.join(TEMPLATES_DIR, "footer.html.erb"))).result
  end

  def head_content(meta_property_tags)
    ERB
      .new(
        File.read(File.join(TEMPLATES_DIR, "head_content.html.erb"))
      )
      .result_with_hash({meta_property_tags: meta_property_tags})
  end
end
