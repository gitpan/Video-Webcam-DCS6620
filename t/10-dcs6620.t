use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Video::Webcam::DCS6620;

plan tests => 32;

{
    my $webcam = Video::Webcam::DCS6620->new;

    is($webcam->hostname, 'localhost', 'default hostname is set');
    is($webcam->port, 80, 'default port is set');
    is($webcam->username, 'admin', 'default username is set');
    is($webcam->password, 'admin', 'default password is set');
}

{
    my $webcam = Video::Webcam::DCS6620->new(
                     hostname => 'foo.com',
                     port => 443,
                     username => 'someuser',
                     password => 'mysecret',
                 );

    is($webcam->hostname, 'foo.com', 'hostname is set');
    is($webcam->port, 443, 'port is set');
    is($webcam->username, 'someuser', 'username is set');
    is($webcam->password, 'mysecret', 'password is set');
}

{
    my $webcam = Video::Webcam::DCS6620->new(port => 0);
    my $description = 'snapshot() died: request failed';

    if(eval { $webcam->snapshot }) {
        ok(0, $description);
    }
    else {
        isnt($@->code, 200, $description);
    }
}

{
    mock_dcs6620();
    my $webcam = Video::Webcam::DCS6620->new(strict => 0);
    my $prefix = 'http://admin:admin@localhost:80';

    # snapshot
    is($webcam->snapshot, "$prefix/cgi-bin/video.jpg", 'got snapshot');

    # move
    for(qw/ up down left right /) {
        is($webcam->move($_), "$prefix/cgi-bin/camctrl.cgi?move=$_", "move($_)");
    }

    eval { $webcam->move('foo') };
    like($@, qr{Usage}, 'failed to move(foo)');

    # zoom
    for(qw/ tele wide /) {
        is($webcam->zoom($_), "$prefix/cgi-bin/camctrl.cgi?zoom=$_", "zoom($_)");
    }

    eval { $webcam->zoom('foo') };
    like($@, qr{Usage}, 'failed to zoom(foo)');

    # focus
    for(qw/ near far auto /) {
        is($webcam->focus($_), "$prefix/cgi-bin/camctrl.cgi?focus=$_", "focus($_)");
    }

    eval { $webcam->focus('foo') };
    like($@, qr{Usage}, 'failed to focus(foo)');

    # iris
    for(qw/ open close auto /) {
        is($webcam->iris($_), "$prefix/cgi-bin/camctrl.cgi?iris=$_", "iris($_)");
    }

    eval { $webcam->iris('foo') };
    like($@, qr{Usage}, 'failed to iris(foo)');

    # save_preset
    is($webcam->save_preset(42, 'foo'), "$prefix/cgi-bin/admin/setparam.cgi?CAMCTRL_presetname_42=foo", "save_preset(42, 'foo')");

    eval { $webcam->save_preset };
    like($@, qr{Usage}, 'save_preset() requires id and name');

    eval { $webcam->save_preset(1) };
    like($@, qr{Usage}, 'save_preset() requires a name');

    # goto_preset
    is($webcam->goto_preset('home'), "$prefix/cgi-bin/camctrl.cgi?move=home", 'goto_preset(home)');
    is($webcam->goto_preset('foo'), "$prefix/cgi-bin/recall.cgi?recall=foo", 'goto_preset(foo)');

    eval { $webcam->goto_preset };
    like($@, qr{Usage}, 'goto_preset() requires a name');
}

sub mock_dcs6620 {
    eval q/
        package Test::UA;
        use HTTP::Headers;
        use HTTP::Response;
        sub get { $_[1] }
        1;
    / or die $@;

    no warnings;
    $Video::Webcam::DCS6620::UA = bless {}, 'Test::UA';
}
