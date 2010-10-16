use inc::Module::Install;

name q(Video-Webcam-DCS6620);
all_from q(lib/Video/Webcam/DCS6620.pm);

test_requires q(Test::More) => 0.96;

bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=Video-Webcam-DCS6620);
homepage q(http://search.cpan.org/dist/Video-Webcam-DCS6620);
repository q(git://github.com//home/repositories/webcam-dcs6620.git);

# install_script glob('bin/*');
auto_install;
WriteAll;
