module Twitter
	module Autolink extend self

    def link_to_hashtag(entity, chars, options = {})
      hash = chars[entity[:indices].first]
      hashtag = entity[:hashtag]
      hashtag = yield(hashtag) if block_given?
      hashtag_class = options[:hashtag_class]

      if hashtag.match Twitter::Regex::REGEXEN[:rtl_chars]
        hashtag_class += ' rtl'
      end

      href = if options[:hashtag_url_block]
        options[:hashtag_url_block].call(hashtag.downcase)
      else
        "#{options[:hashtag_url_base]}#{hashtag.downcase}"
      end

      html_attrs = {
        :class => hashtag_class,
        # FIXME As our conformance test, hash in title should be half-width,
        # this should be bug of conformance data.
        :title => "##{hashtag}"
      }.merge(options[:html_attrs])

      link_to_text_with_symbol(entity, hash, hashtag, href, html_attrs, options)
    end

    def link_to_screen_name(entity, chars, options = {})
      name  = "#{entity[:screen_name]}#{entity[:list_slug]}"

      chunk = name.dup
      chunk = yield(chunk) if block_given?

      at = chars[entity[:indices].first]

      html_attrs = options[:html_attrs].dup

      if entity[:list_slug] && !entity[:list_slug].empty? && !options[:suppress_lists]
        href = if options[:list_url_block]
          options[:list_url_block].call(name)
        else
          "#{options[:list_url_base]}#{name}"
        end
        html_attrs[:class] ||= "#{options[:list_class]}"
      else
        href = if options[:username_url_block]
          options[:username_url_block].call(chunk)
        else
          "#{options[:username_url_base]}#{@dream.screennames.where(name: name.downcase).take.id}"
        end
        html_attrs[:class] ||= "#{options[:username_class]}"
      end

      link_to_text_with_symbol(entity, at, chunk, href, html_attrs, options)
    end


  end
end