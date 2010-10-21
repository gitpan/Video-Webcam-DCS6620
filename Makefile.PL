use inc::Module::Install;

name q(Video-Webcam-DCS6620);
all_from q(lib/Video/Webcam/DCS6620.pm);

requires q(LWP::UserAgent) => 5.835;

test_requires q(HTTP::Headers) => 5.835;
test_requires q(HTTP::Response) => 5.836;
test_requires q(Test::More) => 0.96;

bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=Video-Webcam-DCS6620);
homepage q(http://search.cpan.org/dist/Video-Webcam-DCS6620);
repository q(git://github.com//home/repositories/video-webcam-dcs6620.git);

# install_script glob('bin/*');
auto_install;
WriteAll;
