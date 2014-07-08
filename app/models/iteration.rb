class Iteration
  include ActiveModel::Model

  ATTRIBUTES = [:story_ids,:finish,:number]
  ATTRIBUTES.each do |att|
    attr_accessor att
  end

  ##
  # returns 
  # @param options
  # @option options current_iteration_number
  def self.paginate options = {}

    current = if options[:current_iteration_number]
      options[:current_iteration_number]
    else
      Project.find(ENV['project_id']).current_iteration_number
    end

    response = Typhoeus.get("#{ENV['api_host']}/projects/#{ENV['project_id']}/iterations",
                 params: { offset: current-1, fields: ATTRIBUTES.join(',')},
                 headers: { 'X-TrackerToken' => ENV['pivotal_token']}
                )
    if response.success?
      initialize_from_response(response.body)
    else
      nil
    end
  end

  private

  def self.initialize_from_response(response_body)
    ActiveSupport::JSON.decode(response_body).map do |it_hash|
      self.new supported_attributes it_hash
    end
  end

  def self.supported_attributes(hash)
    hash.select{|k,v| k.to_sym.in?(ATTRIBUTES) }
  end
end
