{

=pod

=head 1 NAME

Eatdrinkfeelgood::PDF::Base

=head1 SUMMARY

 use base Eatdrinkfeelgood::PDF::Base

=head1 DESCRIPTION

=cut

package Eatdrinkfeelgood::PDF::Base;
use strict;

# Modules CPAN
use PDFLib;

# Objects
my $pdf   = undef;

# Globals
my $x     = undef;
my $y     = undef;
my $h     = undef;
my $w     = undef;

my $pg    = 1;
my $pgnum = 1;
my $pgset = 1;

=pod

=head1 PUBLIC METHODS

=cut

=pod

=head2 $pkg = Eatdrinkfeelgood::PDF::Base->new(%args)

=cut

sub new {
    my $pkg  = shift;
    my $self = {};
    bless $self,$pkg;

    $self->init(@_) || return undef;
    return $self;
}

sub init {
    my $self = shift;
    my $file = shift;
    my $args = { @_ };

    $pdf = PDFLib->new(
		       papersize   => $args->{'paper'},
		       filename    => $file,
		       orientation => $args->{'orientation'},
		       );

    map { $self->{ join("_","default",$_) } = $args->{$_}; } qw ( x y h w );
    
    $x = $self->{ 'default_x' };
    $y = $self->{ 'default_y' };
    $h = $self->{ 'default_h' };
    $w = $self->{ 'default_w' };

    return 1;
}

=pod

=head2 $pkg->print_block($text,%args)

=cut

sub print_block {
    my $self = shift;
    my $text = shift;
    my $args = { @_ };

    my $last_x = $x;
    $x = $args->{'x'} || $last_x;

    my $last_h = $h;
    $h = $args->{'h'} || $last_h;

    my $indent = ($args->{"indent"}) ? 16 : 0;
    my $chars  = length($text);
    my $bottom = ($self->{'default_x'} * 2) + 10;

    while ($chars) {

	#my $local_h = $y - $h;

	if (($y < $bottom) || (($y - $h) < $bottom)) {
	    #print "flip : $pgnum ($pg) H : $h, Y : $y , Y-H : $local_h,  Bottom : $bottom\n";# if ($pgnum == 7);
	    $self->flip();
	}

#	print "X :". int($x + $indent)."\n";
#	print "Y :". int($y - $h)."\n";
#	print "H :$h\n";
#	print "W :".int($w - $x)."\n";

	$chars = $pdf->print_boxed(
				   $text,
				   x=>$x + $indent,
				   y=>$y - $h,
				   h=>$h,
				   w=>$w - ($x ),
				   );
	
	if ($chars) {
	    my $len = length($text);
	    $text   = substr($text,$len-$chars,$len);
	    
	    # I'm not sure why I need to do this but
	    # if I don't, it can sometimes be the cause
	    # of an ugly infinite loop.
	    # 20011010 (asc)
	    $text =~ s/^(\n)*//m;
	}

	$indent = 0;
	$y = $y - $h;
    }

    $h = $last_h;
    $x = $last_x;

    return 1;
}

=pod

=head2 $pkg->print_block_numbered($num,%args)

=cut

sub print_block_numbered {
    my $self = shift;
    my $num  = shift;
    my %args = @_;

    my $last_y = $y;
    my $last_x = $x;

    $x = $args{'x'} || $last_x;
    delete $args{'x'};

    $self->print_block("$num) ");

    $y = ($y == ($self->{'default_y'} - $self->{'default_h'})) ? $self->{'default_y'} : $last_y;
    $x = $x + 20;

    my @paras = @{$args{"paras"}};
    delete $args{"paras"};

    for (my$i=0;$paras[$i];$i++) {
	$self->print_block($paras[$i],%args);
	$self->print_break() if ($paras[$i+1]);
    }

    $x = $last_x;
}

=pod

=head2 $pkg->print_line()

=cut

sub print_line {
    my $self = shift;

    $self->print_break(2);

    my ($x,$y) = $pdf->get_text_pos();

    while ($x <= $w) {
	$pdf->print_at("_", x=>$x,y=>$y);
	($x,$y) = $pdf->get_text_pos();
    }
    
    $self->print_break(2);
    return 1;
}

=pod

=head2 $pkg->print_blankline($height)

=cut

sub print_blankline {
    my $self = shift;
    $self->print_break($h);
    return 1;
}

=pod

=head2 $pkg->print_break($height)

=cut

sub print_break {
    my $self  = shift;
    my $break = shift || 6;
    $y = $y - $break;
    $pdf->set_text_pos($x,$y);
    return 1;
}

=pod

=head2 $pkg->flip($force)

=cut

sub flip {
    my $self  = shift;
    my $force = shift;

    $pgnum++;

    if (($y == $self->{'default_y'}) && (! $force)) {
	return;
    }

    $self->footer() unless ($force > 1);
    $pdf->end_page();

    $y = $self->{ "default_y" };   
    $pdf->start_page();

    $pg++;
    return;
}

=pod

=head2 $pkg->set_footer($text)

=cut

sub set_footer {
    my $self = shift;
    my $text = shift;
    $self->{'_footer'} = $text;
}

=pod

=head2 $pkg->footer()

=cut

sub footer {
    my $self = shift;
    return if ($pg == 1);

    my $last_x = $x;
    my $last_y = $y;

    $x = $self->{'default_x'};
    $y = $self->{'default_x'} * 2 + 5;

    $pdf->set_text_pos($x,$y);
    $self->print_line();

    $pdf->set_text_pos($pdf->get_text_pos());
    $pdf->print_boxed("$pg | $self->{'_footer'}",x=>$x,y=>$y - $h,h=>$h,w=>$w);

    $x = $last_x;
    $y = $last_y;

    return 1;
}

=pod

=head2 $pkg->pagenum()

=cut

sub page_num {
    return $pgnum;
}

=pod

=head2 $pkg->new_pageset()

=cut

sub new_pageset {
    my $self = shift;

    $self->flip(1);
    
    while (! ($self->page_num() % 2)) {
	$self->flip(2);
    }

    $pg    = 1;
    $pgset = 1;
    return 1;
}

=pod

=head2 $pkg->get_buffer()

=cut

sub get_buffer {
    return $pdf->get_buffer();
}

sub DESTROY {
    my $self = shift;
    $pdf->finish();
}

=pod

=head1 TO DO 

=over 4

=item 

Finish POD

=back

=head1 VERSION

0.1

=head1 DATE

$Date: 2002/12/20 04:44:28 $

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<PDFLib>

http://www.aaronland.net/food/edfgml

=head1 LICENSE

Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
