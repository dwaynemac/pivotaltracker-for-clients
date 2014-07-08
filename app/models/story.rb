class Story

  HOST = "https://www.pivotaltracker.com/services/v5"
  PROJECT = ""

  def find(id)
    Typhoeus.get("#{HOST}/projects/#{PROJECT}/stories/#{id}")
  end
end
