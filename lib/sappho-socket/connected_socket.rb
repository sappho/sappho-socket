# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

module Sappho
  module Socket

    class ConnectedSocket

      def socket socket
        @socket = socket
      end

      def open host, port
        @socket = TCPSocket.new host, port
      end

      def read bytesNeeded
        @socket.read bytesNeeded
      end

      def write str
        @socket.write str
      end

      def settle seconds
        sleep seconds
      end

      def close
        @socket.close
      end

    end

  end
end
