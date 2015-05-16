module Blog
  def calculate_page_range(paginator) 
    return nil if paginator == nil
    range_limit = 5
    min_page = paginator["page"] - (range_limit/2).floor
    min_page = 1 if min_page < 1

    max_page = paginator["page"] + (range_limit/2).floor

    if max_page - min_page < range_limit - 1
      _max_page = min_page + range_limit - 1
      max_page = _max_page > paginator["total_pages"] ? paginator["total_pages"] : _max_page
    end

    if max_page - min_page < range_limit - 1
      temp = range_limit - 1 - (max_page - min_page)
      _min_page = min_page - temp
      min_page = _min_page < 1 ? 1 : _min_page
    end

    (min_page..max_page).to_a
  end

  def generate_page_url(page) 
    return "/" if page == 1
    "/page#{page}"
  end

  def tag_url(tag)
    "/tag/#{tag}.html"
  end
end

Liquid::Template.register_filter(Blog)