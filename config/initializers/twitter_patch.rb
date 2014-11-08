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

  end
end