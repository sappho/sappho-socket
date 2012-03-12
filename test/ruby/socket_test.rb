require "test/unit"
require 'sappho-socket/safe_socket'
require 'sappho-socket/mock_socket'

class SocketTest < Test::Unit::TestCase

  def test_session
    @socket = Sappho::Socket::SafeSocket.mock Sappho::Socket::MockSocketSession.new [
        { :type => :open, :action => Sappho::Socket::MockSocketOpen.new('localhost', 80) },
        { :type => :settle, :action => Sappho::Socket::MockSocketSettle.new(1) },
        { :type => :read, :action => Sappho::Socket::MockSocketRead.new('login: ') },
        { :type => :write, :action => Sappho::Socket::MockSocketWrite.new('anon') },
        { :type => :close, :action => Sappho::Socket::MockSocketClose.new },
        { :type => :attach, :action => Sappho::Socket::MockSocketAttach.new },
        { :type => :attach, :action => Sappho::Socket::MockSocketAttach.new },
        { :type => :close, :action => Sappho::Socket::MockSocketClose.new }
    ]
    # test of initiated connect
    @socket.open 'localhost', 80
    @socket.settle 1
    assert_equal 'login: ', @socket.read(7)
    @socket.write 'anon'
    @socket.close
    # this should fail because the socket has been closed
    assert_raises SocketError do
      @socket.read(1)
    end
    # test of attached socket (ie. one that has come from a client connection to a server)
    assert_raises Sappho::Socket::MockSocketSessionError do
      @socket.attach nil
    end
    @socket.attach 1 # any object will do here to satisfy the nil test
    @socket.close
  end

  def test_attached_session
    @socket = Sappho::Socket::SafeSocket.new
    @socket.attach MockClientInitiatedSocket.new
    @socket.close
  end

  class MockClientInitiatedSocket

    def initialize
      @sequence = 0
    end

    def attach socket
      checkSequence 1
      raise Sappho::Socket::MockSocketSessionError, 'Not test socket' unless socket == self
    end

    def open host, port
    end

    def read bytesNeeded
    end

    def write str
    end

    def settle seconds
    end

    def close
      checkSequence 2
    end

    private

    def checkSequence number
      @sequence += 1
      raise Sappho::Socket::MockSocketSessionError, 'Call sequence error' unless @sequence == number
    end

  end

end
