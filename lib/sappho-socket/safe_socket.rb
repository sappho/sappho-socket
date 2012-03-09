# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'timeout'

module Sappho
  module Socket

    class SafeSocket

      def initialize
        @socket = nil
        @open = false
        @timeout = 10
      end

      def socket socket
        @socket = socket
      end

      def timeout timeout
        @timeout = timeout
      end

      def open host, port
        wait do
          @socket.open host, port
        end
      end

      def read bytesNeeded
        wait do
          @socket.read bytesNeeded
        end
      end

      def write str
        wait do
          @socket.write str
        end
      end

      def close
        begin
          wait do
            @socket.close if @socket
          end
        rescue
        end
        @socket = nil
      end

      private

      def wait
        timeout @timeout do
          yield
        end
      end
    end

  end
end
