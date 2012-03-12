# See https://github.com/sappho/sappho-socket/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'timeout'

module Sappho
  module Socket

    class MockSocket

      def MockSocket.session session
        @@session = session
      end

      def attach socket
        @@session.action :attach, socket
      end

      def open host, port
        @@session.action :open, host, port
      end

      def read bytesNeeded
        @@session.action :read, bytesNeeded
      end

      def write str
        @@session.action :write, str
      end

      def settle seconds
        @@session.action :settle, seconds
      end

      def close
        @@session.action :close
      end

    end

    class MockSocketSession

      def initialize activities
        @activities = activities
        @index = -1
      end

      def action expectedActivityType, *parameters
        activity = @activities[@index += 1]
        activityType = activity[:type]
        unless activityType == expectedActivityType
          raise MockSocketSessionError,
                "Expected #{activityType} call but code under test asked for #{expectedActivityType}"
        end
        activity[:action].action *parameters
      end

    end

    class MockSocketAttach

      def action socket
        raise MockSocketSessionError, 'Nil socket supplied' unless socket
      end

    end

    class MockSocketOpen

      def initialize host, port
        @host = host
        @port = port
      end

      def action host, port
        unless host == @host and port == @port
          raise MockSocketSessionError,
                "Expected connection to #{@host}:#{@port} but got #{host}:#{port}"
        end
      end

    end

    class MockSocketRead

      def initialize str
        @str = str
      end

      def action bytesNeeded
        unless bytesNeeded >= @str.length
          raise MockSocketSessionError,
                "Expected read of #{@str.length} bytes but got request for #{bytesNeeded}"
        end
        raise Timeout::Error if bytesNeeded > @str.length
        @str
      end

    end

    class MockSocketWrite

      def initialize str
        @str = str
      end

      def action str
        raise MockSocketSessionError, 'Unexpected string on write' unless str == @str
      end

    end

    class MockSocketSettle

      def initialize seconds
        @seconds = seconds
      end

      def action seconds
        unless seconds == @seconds
          raise MockSocketSessionError,
                "Expected settle sleep of #{@seconds} seconds but got request for #{seconds}"
        end
      end

    end

    class MockSocketClose

      def action
      end

    end

    class MockSocketTimeout

      def action
        raise Timeout::Error
      end

    end

    class MockSocketSessionError < RuntimeError
    end

  end
end
