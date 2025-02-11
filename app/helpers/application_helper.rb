module ApplicationHelper

  def self.format_errors(errors)
    formatted_errors = {}
    errors.attribute_names.each do |name|
      formatted_errors[name] = errors.full_messages_for(name)
    end

    formatted_errors
  end
end
