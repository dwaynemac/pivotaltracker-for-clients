class Comment
  include ActiveModel::Model

  ATTRIBUTES = [:id,:story_id,:text,:created_at,:updated_at]
  ATTRIBUTES.each do |att|
    attr_accessor att
  end

  def public_text
    @public_text ||= text.gsub("[#{ENV['public_comment_tag']}]",'')
  end

  def self.for_story(id)
    response = Typhoeus.get("#{ENV['api_host']}/projects/#{ENV['project_id']}/stories/#{id}/comments",
                 params: { fields: ATTRIBUTES.join(',')},
                 headers: { 'X-TrackerToken' => ENV['pivotal_token']}
                )
    if response.success?
      initialize_from_response(response.body)
    else
      nil
    end
  end

  def commented_at
    DateTime.parse created_at
  end

  private

  def self.initialize_from_response(response_body)
    ActiveSupport::JSON.decode(response_body).map do |comm_hash|
      self.new supported_attributes comm_hash
    end
  end

  def self.supported_attributes(hash)
    hash.select{|k,v| k.to_sym.in?(ATTRIBUTES) }
  end

end
