require 'json'
class Result
  attr_accessor :resources

  def initialize(resources=[])
    @resources = resources
  end

  def push(resource)
    resources.push(resource)
  end

  def to_hash
    resource_hashes = []
    resources.each do |resource|
      resource_hashes.push(resource.to_hash)
    end
    return {resources: resource_hashes}
  end

  def to_json
    return to_hash.to_json
  end
end
