require "test/unit"
require 'sappho-socket/safe_socket'
require 'sappho-socket/mock_socket'

module Sappho
  module Socket

    class SocketTest < Test::Unit::TestCase

      def test_session
        @socket = SafeSocket.mock MockSocketSession.new [
          { :type => :open, :action => MockSocketOpen.new('localhost', 80) },
          { :type => :settle, :action => MockSocketSettle.new(42) },
          { :type => :read, :action => MockSocketRead.new('login: ') },
          { :type => :write, :action => MockSocketWrite.new('anon') },
          { :type => :write, :action => MockSocketTimeout.new },
          { :type => :close, :action => MockSocketClose.new },
          { :type => :attach, :action => MockSocketAttach.new },
          { :type => :attach, :action => MockSocketAttach.new },
          { :type => :close, :action => MockSocketClose.new } ]
        # test of initiated connect
        @socket.open 'localhost', 80
        assert @socket.open?
        @socket.settle 42
        assert_equal 'login: ', @socket.read(7)
        @socket.write 'anon'
        assert_raises Timeout::Error do
          @socket.write 'abc'
        end
        assert @socket.close
        assert !@socket.open?
        assert !@socket.close # a second close does not actually close anything
        assert !@socket.open?
        # this should fail because the socket has been closed
        assert_raises SocketError do
          @socket.read(1)
        end
        # test of attached socket (ie. one that has come from a client connection to a server)
        assert_raises MockSocketSessionError do
          @socket.attach nil
        end
        @socket.attach 1 # any object will do here to satisfy the nil test
        assert @socket.close
      end

      def test_attached_session
        MockSocket.session MockSocketSession.new [
           { :type => :read, :action => MockSocketRead.new('xyz') },
           { :type => :write, :action => MockSocketWrite.new('pqr') },
           { :type => :close, :action => MockSocketClose.new } ]
        @socket = SafeSocket.new
        @socket.attach MockSocket.new
        assert @socket.open?
        assert_equal 'xyz', @socket.read(3)
        @socket.write 'pqr'
        start = Time.now
        @socket.settle 1
        elapsed = Time.now - start
        assert elapsed > 0.99 and elapsed < 1.01
        assert @socket.close
        assert !@socket.open?
      end

      def test_sequence_mismatch
        @socket = SafeSocket.mock MockSocketSession.new [
          { :type => :open, :action => MockSocketOpen.new('localhost', 80) } ]
        assert_raises MockSocketSessionError do
          @socket.settle 42
        end
      end

    end

  end
end
