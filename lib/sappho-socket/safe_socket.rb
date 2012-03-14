# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

module Sappho
  module Socket

    require 'timeout'
    require 'socket'
    require 'sappho-socket/connected_socket'

    class SafeSocket

      def SafeSocket.mock session, timeout = 10
        MockSocket.session session
        SafeSocket.new timeout, MockSocket.new
      end

      def initialize timeout = 10, socket = ConnectedSocket.new
        @socket = socket
        @open = false
        @timeout = timeout
      end

      def attach socket
        @socket.attach socket
        @open = true
      end

      def open host, port
        timeout @timeout do
          @socket.open host, port
          @open = true
        end
      end

      def setTimeout timeout
        @timeout = timeout
      end

      def read bytesNeeded
        check
        timeout @timeout do
          @socket.read bytesNeeded
        end
      end

      def write str
        check
        timeout @timeout do
          @socket.write str
        end
      end

      def settle seconds
        @socket.settle seconds
      end

      def close
        actuallyClosed = false
        begin
          timeout @timeout do
            if @open
              @socket.close
              actuallyClosed = true
            end
          end
        rescue
        end
        @open = false
        actuallyClosed
      end

      def open?
        @open
      end

      private

      def check
        raise SocketError, 'Attempt to access unopened TCP/IP socket' unless @open
      end

    end

  end
end
