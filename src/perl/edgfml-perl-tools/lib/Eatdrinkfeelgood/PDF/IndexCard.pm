{

=pod

=head1 NAME

Eatdrinkfeelgood::PDF::IndexCard

=head1 SUMMARY

 my $card = Eatdrinkfeelgood::PDF::IndexCard->new($file);
 $card->to_file(@recipes);

=head1 DESCRIPTION 

TBW

=cut

package Eatdrinkfeelgood::PDF::IndexCard;
use strict;

use vars qw ( $VERSION @ISA @EXPORT @EXPORT_OK );

$VERSION   = 0.1;
@ISA       = qw ( Eatdrinkfeelgood::PDF::Base );
@EXPORT    = qw ();
@EXPORT_OK = qw ();

# Modules
use Eatdrinkfeelgood::PDF::Base;
use Eatdrinkfeelgood::Recipe;

use DirHandle;

# Objects
my $recipe = undef;

# Constants
use constant FIRST_X     => 20;
use constant FIRST_Y     => 277;
use constant HEIGHT      => 14;
use constant WIDTH       => 381;
use constant PAPER       => "a6";
use constant ORIENTATION => "landscape";

=pod

=head1 PUBLIC METHODS

=cut

=pod

=head2 $pkg = Eatdrinkfeelgood::PDF::IndexCard->new($path)

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
    return $self->SUPER::init($_[0],x=>FIRST_X,y=>FIRST_Y,h=>HEIGHT,w=>WIDTH,paper=>PAPER,orientation=>ORIENTATION);
}

=pod

=head2 $pkg->to_string(@paths)

=cut

sub to_string {
    my $self = shift;
    $self->to_file(@_);
    return $self->get_buffer();
}

=pod

=head2 $pkg->to_file(@paths)

=cut

sub to_file {
    my $self = shift;

    foreach (&_visit(@_)) { 
	if ($self->page_num() == 1) {
	    $self->_write($_); 	    
	    next;
	}
	
	$self->new_pageset();
	$self->_write($_);
    } 

    return 1;
}

=pod

=head1 PRIVATE METHODS

=cut

=pod

=head2 $pkg->_write($path)

=cut

sub _write {
    my $self = shift;
    my $file = shift;

    $recipe = Eatdrinkfeelgood::Recipe->new($file);

    my $title = $recipe->title();
    $self->set_footer($title);

    if (my $source = $recipe->source()->{'content'}) {
	$title .= "  ($source)";
    }

    $self->print_block($title);
    $self->print_line();
    $self->print_break();

    foreach my $data ($recipe->ingredients()) { 
	my $line = join(" ", map { $data->{$_} } qw (amount measure item detail));
	$self->print_block($line,x=>30,h=>18);
    }

    $self->flip();

    $self->print_block("Directions");
    $self->print_break();

    my $i = 1;

    foreach my $step ($recipe->directions()) {
	$self->print_block_numbered($i,x=>30,paras=>$step);
	$self->print_break();
	$i++;
    }

    $self->print_blankline();

    if (my @notes = $recipe->notes()) {
	$self->print_block("Notes");
	$self->print_break();

	foreach my $note (@notes) {	    
	    $self->_write_paras($note->{'paras'});
	    $self->print_blankline();
	}
    }

#    if (my $history = $recipe->history()) {
#	if (my $paras = $history->{'paras'}) {
#	    $self->print_block("History");
#	    $self->print_break();
#	    $self->_write_paras($paras);
#	}
#    }
    
    return 1;
}

=pod

=head2 $pkg->_visit(@paths)

=cut

sub _visit {
    my @paths   = @_;
    my @recipes = ();

    foreach my $f (@paths) { 

	if (! -d $f) { 
	    push(@recipes,$f);
	    next;
	}
	
	my $dh=DirHandle->new($f); 
	push(@recipes,map { &_visit("$f/$_"); } grep { ! /^\./ && ! /~$/ } $dh->read());
    }
    
    return @recipes;
}

=pod

=head2 $pkg->_write_paras(\@paras)

=cut

sub _write_paras {
    my $self  = shift;
    my $paras = shift;

    for (my $i=0; $paras->[$i];$i++) {
	$self->print_block($paras->[$i],indent=>1);
	$self->print_break() if ($paras->[$i+1]);
    }

    return 1;
}

=pod

=head1 TO DO

=over 4

=item

Provide some sort of interface where a user may specify a code ref for dealing with attributes that may be defined using a database unique id, e.g. the source of a recipe.

=item 4

Better error-handling.

=back

=head1 VERSION 

0.2

=head1 DATE

$Date: 2002/12/20 04:44:28 $

=head1 AUTHOR 

Aaron Straup Cope

=head1 SEE ALSO

L<Eatdrinkfeelgood::PDF::Base>

http://www.aaronland.net/food/edfgml

=head1 LICENSE

Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
