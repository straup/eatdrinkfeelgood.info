{

=pod

=head1 NAME

Eatdrinkfeelgood::Recipe

=head1 SUMMARY

 use Eatdrinkfeelgood::Recipe;
 my $recipe = Eatdrinkfeelgood::Recipe->new(/path/to/edfg/doc)

 print $recipe->title(),"\n";

 if (my @notes = $recipe->notes()) {

   foreach my $note (@notes) {
       print join("\n",@{$note->{'paras'}});
   }

 }

=head1 DESCRIPTION

As of this writing, there is no interface for writing eatdrinkfeelgood documents.

=cut

package Eatdrinkfeelgood::Recipe;
use strict;

use vars qw ( $VERSION @EXPORT @EXPORT_OK );

$VERSION   = 0.2;
@EXPORT    = qw ();
@EXPORT_OK = qw ();

use Carp;
use XML::XPath;

# Objects
my $xpath = undef;

=pod

=head1 PUBLIC METHODS

=cut

=pod

=head2 $pkg = Eatdrinkfeelgood::Recipe->new($path)

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

    eval { $xpath = XML::XPath->new(filename=>$file); };

    if ($@) {
	carp $@;
	return 0;
    }
    
    return 1;
}

=pod

=head2 $pkg->title()

=cut

sub title {
    return $xpath->findvalue("/eatdrinkfeelgood/recipe/name/common");
}

=pod

=head2 $pkg->source()

Returns a hash ref.

=cut

sub source {
    my $source = (@{$xpath->find("/eatdrinkfeelgood/recipe/source")})[0];
    return &_type_content($source);
}

=pod

=head2 $pkg->yield()

=cut

sub yield {
    my $self = shift;
    return $self->_measure($xpath->find("/eatdrinkfeelgood/recipe/yield"));
}

=pod

=head2 $pkg->categories()

=cut

sub categories {
    my $self = shift;
    my @cats = ();
    
    foreach my $category (@{$xpath->find("/eatdrinkfeelgood/recipe/category")}) {
	push(@cats,&_type_content($category));
    }

    return @cats;
}

=pod

=head2 $pkg->customfields()

=cut

sub customfields {
    my @custom = ();
    
    foreach my $category (@{$xpath->find("/eatdrinkfeelgood/recipe/custom")}) {
	push(@custom,&_type_content($category));
    }

    return @custom;
}

=pod

=head2 $pkg->ingredients()

=cut

sub ingredients {
    my @ings = ();

    foreach my $ing (@{$xpath->find("/eatdrinkfeelgood/recipe/ingredients/ing")}) {
	push(@ings,&_ingredient($ing));
    }

    return @ings;
}

=pod

=head2 $pkg->directions()

=cut

sub directions {
    my @steps = ();

    foreach my $step (@{$xpath->find("/eatdrinkfeelgood/recipe/directions/step")}) {
	my @paras = ();
	foreach my $el (@{$step->getChildNodes()}) {
	    if (my $name = $el->getName() eq "para") { 
		push(@paras,$el->string_value());
	    }
	}

	push(@steps,\@paras);
    }

    return @steps;
}    

=pod

=head2 $pkg->notes()

=cut

sub notes {
    my @notes = ();
    
    foreach my $node (@{$xpath->find("/eatdrinkfeelgood/recipe/notes/note")}) {
	push(@notes,&_note($node));
    }

    return @notes;
}

=pod

=head2 $pkg->history()

=cut

sub history {
    my @paras = ();

    foreach my $para(@{$xpath->findnodes("/eatdrinkfeelgood/recipe/history/para")}) {
	push(@paras,$para->string_value());
    }
    
    return {
	paras  => ((@paras)?\@paras:undef),
	author => &_author(($xpath->findnodes("/eatdrinkfeelgood/recipe/history/author"))[0]),
	date   => &_date(($xpath->findnodes("/eatdrinkfeelgood/recipe/history/date"))[0]),	
    };
}

=pod

=head1 PRIVATE METHODS

=cut

=pod

=head2 $pkg->ingredient($node)

=cut

sub _ingredient {
    my $node = shift;
    my %ing  = ();

    foreach my $el (@{$node->getChildNodes()}) {    
	if (my $name = $el->getName()) {

	    if ((grep/^($name)$/,qw(amount item detail)) && (my $content = $el->string_value())) {
		$ing{ $name } = $content;
	    }

	    if (($name eq "measure") && (my $content = &_measure($el))) {
		$ing{ $name } = $content;
	    }
	}
    }

    return \%ing;
}

=pod

=head2 $pkg->_measure($node)

=cut

sub _measure {
    my $node    = shift;
    my $measure = undef;

    foreach my $el (@{$node->getChildNodes()}) {
	if (my $name = $el->getName()) { 
	    $measure = ($name eq "customunit") ? $el->string_value : $el->getAttribute("content");
	}
    }

    return $measure;
}

=pod

=head2 $pkg->_note($node)

=cut

sub _note {
    my $node = shift;

    my @paras  = ();
    my $author = "";
    my $date   = "";

    foreach my $el (@{$node->getChildNodes()}) {
	if (my $name = $el->getName()) { 
	    
	    if ($name eq "para") {
		push(@paras,$el->string_value());
		next;
	    }
	    
	    if ($name eq "author") {
		$author = &_author($el);
		next;
	    }
	    
	    if ($name eq "date") {
		$date = &_date($el);
		next;
	    }
	}
    }
    
    return {
	paras  => ((@paras)?\@paras:undef),
	author => $author,
	date   => $date,
    };
}

=pod

=head2 $pkg->_author($node)

=cut

sub _author {
    return &_simple($_[0]," ","firstname","surname");
}

=pod

=head2 $pkg->_date($node)

=cut

sub _date {
    return &_simple($_[0],"/","year","month","day");
}

=pod

=head2 $pkg->_simple($node,$join)

This method desperately needs to be renamed.

=cut

sub _simple {
    my $node  = shift || return undef;
    my $join  = shift;
    my @attrs = @_;
    
    my %key = ();
    
    foreach my $el (@{$node->getChildNodes()}) {
	if (my $name = $el->getName()) {
	    $key{ $name } = $el->string_value();
	}
    }
    
    return join($join, map { $key{$_} } @attrs );
}

=pod

=head2 $pkg->_type_content($node)

=cut


sub _type_content {
    my $node = shift;
    return {	
	type    => $node->getAttribute("type"),
	content => $node->getAttribute("content"),
    }
}

=pod

=head1 TO DO

=over 4

=item

Finish POD

=item 

A proper, full-on OOP interface

=back

=head1 VERSION

0.2

=head2 DATE

$Date: 2002/12/20 04:44:27 $

=head1 CHANGES

=head2 0.1

=over 4

=item

Initial revision.

=back

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO 

L<XML::XPath>

http://www.aaronland.net/food/edfgml

=head1 LICENSE

Copyright 2001, Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
