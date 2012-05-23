class String
  # Taken from ActiveSupport
  # File activesupport/lib/active_support/inflector.rb, line 188

  unless self.new.respond_to? :underscore
    def underscore
      gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
