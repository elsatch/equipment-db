module PageModels
  module Home
    class Show
      class DeviceRow
        def initialize(device)
          @device = device
        end

        def asset_code
          @device.asset_code || '(untagged)'
        end

	def emphasize_status
          if @device.status && (@device.status.severity > Status::Severity::WARNING)
            true
          else
            false
          end
	end

	def highlight_style
          # Explicit: if no status recorded, return 'nil'
          return nil unless @device.status

          case @device.status.severity
          when Status::Severity::ERROR
            'error'
          when Status::Severity::WARNING
            'warning'
          end
	end

	def name
	  @device.name
	end

	def path
          "/devices/#{@device.id}"
	end

	def status
          @device.status ? @device.status.name : '(not set)'
	end
      end
    end
  end
end
