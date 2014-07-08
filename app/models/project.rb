class Project
  include ActiveModel::Model

  ATTRIBUTES = [:current_iteration_number]
  ATTRIBUTES.each do |att|
    attr_accessor att
  end

  def self.find(id)
    response = Typhoeus.get("#{ENV['api_host']}/projects/#{id}",
                 params: { fields: ATTRIBUTES.join(',')},
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
    self.new supported_attributes ActiveSupport::JSON.decode(response_body)
  end

  def self.supported_attributes(hash)
    hash.select{|k,v| k.to_sym.in?(ATTRIBUTES) }
  end
end
