package Progress::Any::Output;

use 5.010001;
use strict;
use warnings;

# VERSION

require Progress::Any;

sub _set_or_add {
    my $class = shift;
    my $which = shift;

    my $opts;
    if (@_ && ref($_[0]) eq 'HASH') {
        $opts = shift;
    } else {
        $opts = {};
    }

    my $output = shift or die "Please specify output name";
    $output =~ /\A\w+(::\w+)*\z/ or die "Invalid output syntax '$output'";

    my $task = $opts->{task} // "main";

    my $outputo;
    {
        my $outputpm = $output; $outputpm =~ s!::!/!g; $outputpm .= ".pm";
        require "Progress/Any/Output/$outputpm";
        no strict 'refs';
        $outputo = "Progress::Any::Output::$output"->new(@_);
    }

    if ($which eq 'set') {
        $Progress::Any::outputs{$task} = [$outputo];
    } else {
        $Progress::Any::outputs{$task} //= [];
        push @{ $Progress::Any::outputs{$task} }, $outputo;
    }
}

sub set {
    my $class = shift;
    $class->_set_or_add('set', @_);
}

sub add {
    my $class = shift;
    $class->_set_or_add('add', @_);
}

1;
# ABSTRACT: Assign output to progress indicators

=head1 SYNOPSIS

In your application:

 use Progress::Any::Output;
 Progress::Any::Output->set('TermProgressBarColor');

To give parameters to output:

 Progress::Any::Output->set('TermProgressBarColor', width=>50, ...);

To assign output to a certain (sub)task:

 Progress::Any::Output->set({task=>'main.download'}, 'TermMessage');

To add additional output, use add() instead of set().


=head1 DESCRIPTION

See L<Progress::Any> for overview.


=head1 METHODS

=head2 Progress::Any::Output->set([ \%opts ], $output[, @args])

Set (or replace) output. Will load and instantiate
C<Progress::Any::Output::$output>. To only set output for a certain (sub)task,
set C<%opts> to C<< { task => $task } >>. C<@args> will be passed to output
module's constructor.

=head2 Progress::Any::Output->add([ \%opts ], $output[, @args])

Like set(), but will add output instead of replace existing one(s).


=head1 SEE ALSO

L<Progress::Any>

=cut

