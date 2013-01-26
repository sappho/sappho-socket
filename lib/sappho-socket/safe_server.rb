# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

module Sappho
  module Socket

    require 'sappho-basics/auto_flush_log'
    require 'thread'
    require 'socket'

    class SafeServer

      def initialize name, port, maxClients = 10, timeout = 10, detailedLogging = false
        @name = name
        @port = port
        @maxClients = maxClients
        @timeout = timeout
        @detailedLogging = detailedLogging
        @clients = {}
        @mutex = Mutex.new
        @log = Sappho::ApplicationAutoFlushLog.instance
      end

      def serve
        Thread.new do
          begin
            @log.info "opening #{@name} server port #{@port}"
            @server = TCPServer.open @port
            @log.info "#{@name} server port #{@port} is now open"
            loop do
              if clientCount >= @maxClients
                sleep 1
              else
                @log.info "listening for new clients on #{@name} server port #{@port}" if @detailedLogging
                client = @server.accept
                port, ip = Socket.unpack_sockaddr_in(client.getpeername)
                @mutex.synchronize do
                  @clients[client] = ip
                  log ip, 'connected' if @detailedLogging
                end
                Thread.new client, ip do | client, ip |
                  socket = SafeSocket.new @timeout
                  socket.attach client
                  begin
                    yield socket, ip, @name, @port
                  rescue => error
                    @log.error error
                  end
                  socket.close
                  @mutex.synchronize do
                    @clients.delete client
                    log ip, 'disconnected' if @detailedLogging
                  end
                end
              end
            end
          end
        end
      end

      def clientCount
        @mutex.synchronize do
          @clients.size
        end
      end

      private

      def log ip, status
        @log.info "client #{ip} #{status}"
        @log.info "clients: #{@clients.size > 0 ? (@clients.collect{|client, ip| ip}).join(', ') : 'none'}"
      end

    end

  end
end
