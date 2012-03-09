# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'timeout'

module Sappho
  module Socket

    class ConnectedSocket < Socket

      def initialize
        @socket = nil
        @timeout = 10
      end

      def socket socket
        @socket = socket
      end

      def timeout timeout
        @timeout = timeout
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
