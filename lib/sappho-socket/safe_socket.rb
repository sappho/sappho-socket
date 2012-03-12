# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'timeout'

module Sappho
  module Socket

    class SafeSocket

      def initialize timeout = 10
        @open = false
        @timeout = timeout
      end

      def socket socket, open = false
        @socket = socket
        @open = open
      end

      def timeout timeout
        @timeout = timeout
      end

      def open host, port
        timeout @timeout do
          @socket.open host, port
          @open = true
        end
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
        begin
          timeout @timeout do
            @socket.close if @open
          end
        rescue
        end
        @socket = nil
        @open = false
      end

      private

      def check
        raise SocketError, 'Attempt to access unopened TCP/IP socket' unless @open
      end

    end

  end
end
