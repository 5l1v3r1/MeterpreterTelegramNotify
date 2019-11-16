##
# Author: sayhi2urmom
#
##

require 'open-uri'
require 'net/http'
require 'net/https'

module Msf

	class Plugin::Notify < Msf::Plugin
		include Msf::SessionEvent


		def initialize(framework, opts)
			super
			add_console_dispatcher(NotifyDispatcher)
		end

		def cleanup
			self.framework.events.remove_session_subscriber(self)
			remove_console_dispatcher('notify')
		end


		def name
			"notify"
		end

		def desc
			"Automatically send Telegram notifications when sessions are created and closed."
		end

		class NotifyDispatcher
			include Msf::Ui::Console::CommandDispatcher
			$opened = Array.new
			$closed = Array.new


			def on_session_open(session)
				url="https://api.telegram.org/bot780097728:AAGWa_BVRGWoumJoz5PjJ5QW3gz6rvLeCG4/sendMessage?chat_id=-1001425973394&text=fuck yeah! #{session.session_host} connected back"
				sslget(url,session.sid,"open")
				return
			end


			def on_session_close(session,reason = "")
				url="https://api.telegram.org/bot780097728:AAGWa_BVRGWoumJoz5PjJ5QW3gz6rvLeCG4/sendMessage?chat_id=-1001425973394&text=we lose #{session.session_host}"
				sslget(url,session.sid,"close")
				return
			end


			def name
				"notify"
			end

			def sslget(url,session_id,event)
				if event == "open" and $opened.exclude?(session_id)
					url = URI(url)
					http = Net::HTTP.new(url.host, url.port,"127.0.0.1", 1080)
					http.use_ssl = true
					resp = http.get(url)
					$opened.push(session_id)
				elsif event == "close" and $closed.exclude?(session_id)
					url = URI(url)
					http = Net::HTTP.new(url.host, url.port,"127.0.0.1", 1080)
					http.use_ssl = true
					resp = http.get(url)
					$closed.push(session_id)
				end
				
			end

			def commands
				{
					'notify_start'				=> "Start Notify Plugin after saving settings.",
					'notify_stop'					=> "Stop monitoring for new sessions.",
				}
			end

			def cmd_notify_start
				self.framework.events.add_session_subscriber(self)
				print_good("Notify Plugin Started, Monitoring Sessions")
			end

			def cmd_notify_stop
				print_status("Stopping the monitoring of sessions to Slack")
				self.framework.events.remove_session_subscriber(self)
			end

		end
	end
end
