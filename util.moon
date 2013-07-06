import graphics from love

-- cache images and provid helper method to easily load new ones.
image_cache = {}
export imgfy = (img) ->
    if "string" == type img
        cached = image_cache[img]
        img = if not cached
            new = graphics.newImage img
            image_cache[img] = new
            new
        else
            cached
    img
