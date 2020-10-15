package App::SVG::Graph;

use strict;
use warnings;

use autodie;

use 5.008;

our $VERSION = 'v0.0.2';

use SVG::Graph::Kit;
use Getopt::Long qw( GetOptionsFromArray );
use Pod::Usage;

sub argv
{
    my $self = shift;

    if (@_)
    {
        $self->{argv} = shift;
    }

    return $self->{argv};
}

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

sub _init
{
    my ( $self, $args ) = @_;

    $self->argv( $args->{argv} );

    return;
}

sub _slurp_lines
{
    my $in = shift;

    my @ret = <$in>;
    chomp(@ret);

    return \@ret;
}

sub _render_as_svg
{
    my ( $self, $args ) = @_;

    my $g = SVG::Graph::Kit->new( data => $args->{data} );
    print { $args->{out_fh} } $g->draw;

    return;
}

sub run
{
    my ($self) = @_;

    my $output_fn;
    my $man     = 0;
    my $help    = 0;
    my $version = 0;

    my @argv = @{ $self->argv };

    GetOptionsFromArray(
        \@argv,
        "output|o" => \$output_fn,
        "help|h"   => \$help,
        "man"      => \$man,
        "version"  => \$version,
    ) or pod2usage(2);

    if ($help)
    {
        pod2usage(1);
    }

    if ($man)
    {
        pod2usage( -verbose => 2 );
    }

    if ($version)
    {
        print "svg-graph version $VERSION\n";
        exit(0);
    }

    my $in_fh;

    my $filename = shift(@argv);
    if ( !defined($filename) )
    {
        $in_fh = \*STDIN;
    }
    else
    {
        open $in_fh, '<', $filename;
    }

    my $out_fh;

    if ( !defined($output_fn) )
    {
        $out_fh = \*STDOUT;
    }
    else
    {
        open $out_fh, '>', $output_fn;
    }

    my $data = [ map { [ split /\t/, $_ ] } @{ _slurp_lines($in_fh) } ];
    $self->_render_as_svg( { data => $data, out_fh => $out_fh } );

    close($out_fh);

    if ( defined($filename) )
    {
        close($in_fh);
    }

    return;
}

1;

=head1 NAME

App::SVG::Graph - generate SVG graphs from the command line.

=head1 DESCRIPTION

This accepts tab-separated data (TSV) on STDIN and emits an SVG graph.

=head1 NOTE

Everything here is subject to change. The API is for internal use.

=head1 METHODS

=head2 my $app = App::SVG::Graph->new({argv => \@ARGV})

The constructor. Accepts the @ARGV array as a parameter and parses it.

=head2 $app->run()

Runs the application.

=head2 $app->argv()

B<For internal use.>

=head1 SEE ALSO

L<SVG::Graph::Kit> , L<SVG::Graph> .

L<https://github.com/FormidableLabs/victory-cli> is a similar tool for
Node.js/npm , but I had trouble installing it so I decided to create
L<svg-graph>. It may work well enough for you, though.

=cut
