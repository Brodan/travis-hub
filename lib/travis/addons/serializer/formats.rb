module Travis
  module Addons
    module Serializer
      module Formats
        def format_date(date)
          date && date.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      end
    end
  end
end
