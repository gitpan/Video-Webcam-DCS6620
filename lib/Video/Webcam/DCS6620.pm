package Video::Webcam::DCS6620;

=head1 NAME

Video::Webcam::DCS6620 - Webcam interface to D-LINK DCS6620

=head1 VERSION

0.01

=head1 SYNOPSIS

    my $camera = Video::Webcam::DCS6620->new;
    my $res = $camera->snapshot; # might die
    print $res->body;

=head1 DESCRIPTION

All the methods take an extra argument, which is an hash ref. The
values in the hash ref can be used to override the default L</ATTRIBUTES>
of this object.

=head1 FAULT HANDLING

Each method will die with a "Usage..." string on invalid input, and die
with the response object, if the response code is something else than 200.

=cut

use strict;
use warnings;
use LWP::UserAgent;

our $VERSION = eval '0.01';
our $UA = LWP::UserAgent->new(timeout => 10); # Subject for change - meant for internal usage

=head1 ATTRIBUTES

=head2 hostname

The peer hostname or IP address of the webcam. Default: "localhost".

=head2 port

The peer port or IP address of the webcam. Default: 80.

=head2 username

Username to use for login at the webcam webserver. Default: "admin".

=head2 password

Password to use for login at the webcam webserver. Default: "admin".

=cut

{
    my %attrs = (
        hostname => 'localhost',
        port => 80,
        username => 'admin',
        password => 'admin',
    );

    no strict 'refs';

    for my $name (keys %attrs) {
        *$name = sub {
            my $self = shift;
            return $self->{$name} if(exists $self->{$name}); # constructor values
            return $attrs{$name}; # default
        };
    }
}

=head1 METHODS

=head2 new

This is the object constructor. It should receive key/value pairs matching
the L</ATTRIBUTES>. It can also take a hash ref, with the same key/values.

=cut

sub new {
    my $class = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};

    $args->{'strict'} = 1 unless(exists $args->{'strict'});

    return bless $args, $class;
}

=head2 snapshot

Returns a L<HTTP::Response> object, containing a JPEG image
in the response body.

=cut

sub snapshot {
    shift->_request('cgi-bin/video.jpg', @_);
}

=head2 move

Input is a string: "up", "down", "left" or "right".
This method returns a L<HTTP::Response> object.

=cut

sub move {
    my $self = shift;
    my $direction = shift || q();

    for my $valid (qw/up down left right/) {
        next unless($direction eq $valid);
        return $self->_request("cgi-bin/camctrl.cgi?move=$direction", @_);
    }

    die 'Usage: $self->move(up|down|left|right). Got ' .$direction;
}

=head2 zoom

Input is a string: "tele" or "wide".
This method returns a L<HTTP::Response> object

=cut

sub zoom {
    my $self = shift;
    my $zoom = shift || q();

    for my $valid (qw/tele wide/) {
        next unless($zoom eq $valid);
        return $self->_request("cgi-bin/camctrl.cgi?zoom=$zoom", @_);
    }

    die 'Usage: $self->zoom(tele|wide). Got ' .$zoom;
}

=head2 focus

Input is a string: "near", "far" or "auto".
This method returns a L<HTTP::Response> object.

=cut

sub focus {
    my $self = shift;
    my $focus = shift || q();

    for my $valid (qw/near far auto/) {
        next unless($focus eq $valid);
        return $self->_request("cgi-bin/camctrl.cgi?focus=$focus", @_);
    }

    die 'Usage: $self->focus(near|far|auto). Got ' .$focus;
}

=head2 iris

input is a string: "open", "close" or "auto".
This method returns a L<HTTP::Response> object.

=cut

sub iris {
    my $self = shift;
    my $mode = shift || q();

    for my $valid (qw/open close auto/) {
        next unless($mode eq $valid);
        return $self->_request("cgi-bin/camctrl.cgi?iris=$mode", @_);
    }

    die 'Usage: $self->iris(open|close|auto). Got '. $mode;
}

=head2 save_preset

Will save a preset with the given id and name.
Input is C<($id, $name)>. C<$name> is then used in L</goto_preset> to recall
a given preset.
This method returns a L<HTTP::Response> object.

=cut

sub save_preset {
    my $self = shift;
    my $id = shift;
    my $name = shift;

    if(defined $id and $name) {
        return $self->_request("cgi-bin/admin/setparam.cgi?CAMCTRL_presetname_$id=$name", @_)
    }

    $id = 'UNDEF' unless(defined $id);
    $name = 'UNDEF' unless(defined $name);

    die 'Usage: $self->save_preset($id, $name). Got id='. $id .', name=' .$name;
}

=head2 goto_preset

Will go th the given preset, previously saved by L</save_preset>. C<$name>
can also have the special value "home", which will move the camera to the
default "home" position.
This method returns a L<HTTP::Response> object.

=cut

sub goto_preset {
    my $self = shift;
    my $name = shift || q();

    if($name eq 'home') {
        return $self->_request('cgi-bin/camctrl.cgi?move=home', @_);
    }
    elsif($name) {
        return $self->_request("cgi-bin/recall.cgi?recall=$name", @_);
    }

    die 'Usage: $self->goto_preset($str)';
}

sub _request {
    my $self = shift;
    my $path = shift or return;
    my $args = shift || {};
    my $res;

    $res = $UA->get(sprintf 'http://%s:%s@%s:%i/%s',
        $args->{'username'} || $self->username,
        $args->{'password'} || $self->password,
        $args->{'hostname'} || $self->hostname,
        $args->{'port'} || $self->port,
        $path,
    );

    if($self->{'strict'}) {
        die $res unless($res->code eq 200);
    }

    return $res;
}

=head1 AUTHOR

Jan Henning Thorsen - C<< jhthorsen at cpan.org >>

=cut

1;
