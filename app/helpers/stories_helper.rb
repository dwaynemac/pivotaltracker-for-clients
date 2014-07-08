module StoriesHelper

  def render_eta(eta)
    if eta.is_a?(Date)
      "~ #{l eta, format: :short}"
    else
      t("story.eta.#{eta}")
    end
  end
end
