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
			"Automatically send Tg Messgae when sessions are created and closed."
		end

		class NotifyDispatcher
			include Msf::Ui::Console::CommandDispatcher
			def myconfs
				{
					'token' => 'your token',
					'chat_id' => 'your chat_id',
					'proxy_addr' => '127.0.0.1',
					'proxy_port' => 1080
			}
			end
			$opened = Array.new
			$closed = Array.new


			def on_session_open(session)
				url="https://api.telegram.org/bot#{myconfs['token']}/sendMessage?chat_id=#{myconfs['chat_id']}&text=fuck yeah! #{session.session_host} connected back"
				sslget(url,session.sid,"open")
				return
			end


			def on_session_close(session,reason = "")
				url="https://api.telegram.org/bot#{myconfs['token']}/sendMessage?chat_id=#{myconfs['chat_id']}&text=we lose #{session.session_host}"
				sslget(url,session.sid,"close")
				return
			end


			def name
				"notify"
			end

			def sslget(url,session_id,event)
				if event == "open" and $opened.exclude?(session_id)
					url = URI(url)
					http = Net::HTTP.new(url.host, url.port,myconfs['proxy_addr'], myconfs['proxy_port'])
					http.use_ssl = true
					resp = http.get(url)
					$opened.push(session_id)
				elsif event == "close" and $closed.exclude?(session_id)
					url = URI(url)
					http = Net::HTTP.new(url.host, url.port,myconfs['proxy_addr'], myconfs['proxy_port'])
					http.use_ssl = true
					resp = http.get(url)
					$closed.push(session_id)
				end
				
			end

			def commands
				{
					'notify_start'				=> "start monitoring for new session.",
					'notify_stop'					=> "stop monitoring for new sessions.",
				}
			end

			def cmd_notify_start
				self.framework.events.add_session_subscriber(self)
				print_good("notify successfully started")
			end

			def cmd_notify_stop
				print_status("notify successfully stoped")
				self.framework.events.remove_session_subscriber(self)
			end

		end
	end
end
