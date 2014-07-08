class Story
  include ActiveModel::Model

  ATTRIBUTES = [:id,:current_state, :name, :description, :url]
  ATTRIBUTES.each do |att|
    attr_accessor att
  end

  def self.find(id)
    response = Typhoeus.get("#{ENV['api_host']}/projects/#{ENV['project_id']}/stories/#{id}",
                 params: { fields: ATTRIBUTES.join(',')},
                 headers: { 'X-TrackerToken' => ENV['pivotal_token']}
                )
    if response.success?
      initialize_from_response(response.body)
    else
      nil
    end
  end

  # @argument format [Symbol] can be :plain or :html (:plain)
  def public_description(format = :plain)
    if description
      m = description.match(/\[#{ENV['begin_public_observations_tag']}\](.*)\[#{ENV['end_public_observations_tag']}\]/m)
      pd = m.try :[], 1
      case format
      when :plain
        pd
      when :html
        if m
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
          markdown.render( pd ).html_safe
        end
      else
        pd
      end
    end
  end

  def comments
    unless @comments
      @comments = Comment.for_story self.id
      @comments = @comments.select{|comm| comm.text =~ /\[#{ENV['public_comment_tag']}\]/}
      if @comments
        # sort latest first
        @comments = @comments.sort{|a,b| b.commented_at <=> a.commented_at }
      end
    end
    @comments
  end

  # returns ETA(Date), :next_deploy or :unknown
  def eta
    case public_state
    when :finished
      :next_deploy
    when :scheduled, :inprogress
      next_iterations = Iteration.paginate
      story_eta = next_iterations.select{|i| id.in?(i.story_ids) }.first.try :finish
      if story_eta
        Date.parse story_eta
      else
        :unknown
      end
    else
      :unknown
    end
  end

  # a simpler mapping of states 
  # for clients view
  # V5 notes:
  #   current_state valid values:
  #     - unscheduled: in icebox 
  #     - unstarted: in backlog
  #
  #     - started
  #     - finished
  #     - delivered
  #     - rejected
  #
  #     - accepted: finished
  #
  # Public states
  #   1. unscheduled
  #   2. scheduled
  #   3. inprogress
  #   4. finished
  def public_state
    case current_state.to_sym
    when :unscheduled
      :unscheduled
    when :unstarted
      :scheduled
    when :started, :finished, :delivered, :rejected
      :inprogress
    when :accepted
      :finished
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
