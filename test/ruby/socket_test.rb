require "test/unit"
require 'sappho-socket/safe_socket'
require 'sappho-socket/mock_socket'

class SocketTest < Test::Unit::TestCase

  def test_session
    @socket = Sappho::Socket::SafeSocket.mock Sappho::Socket::MockSocketSession.new [
        { :type => :open, :action => Sappho::Socket::MockSocketOpen.new('localhost', 80) },
        { :type => :settle, :action => Sappho::Socket::MockSocketSettle.new(42) },
        { :type => :read, :action => Sappho::Socket::MockSocketRead.new('login: ') },
        { :type => :write, :action => Sappho::Socket::MockSocketWrite.new('anon') },
        { :type => :write, :action => Sappho::Socket::MockSocketTimeout.new },
        { :type => :close, :action => Sappho::Socket::MockSocketClose.new },
        { :type => :attach, :action => Sappho::Socket::MockSocketAttach.new },
        { :type => :attach, :action => Sappho::Socket::MockSocketAttach.new },
        { :type => :close, :action => Sappho::Socket::MockSocketClose.new }
    ]
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
    assert_raises Sappho::Socket::MockSocketSessionError do
      @socket.attach nil
    end
    @socket.attach 1 # any object will do here to satisfy the nil test
    assert @socket.close
  end

  def test_attached_session
    Sappho::Socket::MockSocket.session Sappho::Socket::MockSocketSession.new [
        { :type => :read, :action => Sappho::Socket::MockSocketRead.new('xyz') },
        { :type => :write, :action => Sappho::Socket::MockSocketWrite.new('pqr') },
        { :type => :close, :action => Sappho::Socket::MockSocketClose.new }
    ]
    @socket = Sappho::Socket::SafeSocket.new
    @socket.attach Sappho::Socket::MockSocket.new
    assert @socket.open?
    assert_equal 'xyz', @socket.read(3)
    @socket.write 'pqr'
    start = Time.now
    @socket.settle 1
    elapsed = Time.now - start
    assert elapsed > 0.9 and elapsed < 1.1
    assert @socket.close
    assert !@socket.open?
  end

  def test_sequence_mismatch
    @socket = Sappho::Socket::SafeSocket.mock Sappho::Socket::MockSocketSession.new [
        { :type => :open, :action => Sappho::Socket::MockSocketOpen.new('localhost', 80) }
    ]
    assert_raises Sappho::Socket::MockSocketSessionError do
      @socket.settle 42
    end
  end

end
