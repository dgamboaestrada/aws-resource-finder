require 'json'

class Resource
  attr_accessor :description, :tags

  def initialize(description: nil, tags: nil)
    @description = description
    @tags = tags
  end

  def to_hash
    return {description: description, tags: tags}
  end
end
