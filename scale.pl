#!/usr/bin/perl
use strict; use warnings;

my @chromatic_scale = ( qw/ A Bb B C /, 'C#', qw/ D Eb E F /, 'F#', qw/ G Ab / );
my @sequence = qw/ 2 2 1 2 2 2 1 /;
my @note_types = qw/ Maj m m Maj Maj m dim /;
my @modes = qw/Ionian Dorian Phrygian Lydian Mixolydian Aolian Lochrian/;

my $note = $ARGV[0]; # A
my $mode = $ARGV[1]; # Mixolydian


# Mixolydian is the 5th scale, according to note_types it is a Major scale
my $mode_index = mode_index( $mode ); # 4 ( as an array index )
my $note_index = note_index( $note ); # 0
my $note_type = $note_types[$mode_index]; # Maj

# So, the scale where A is the 5th note

# We are 5th <$mode_index> positions into the major scale interval sequence ( @sequence )
# Move backward from our chosen note using the relative interval
my $sequence_index = $mode_index - 1;
my $chromatic_index = $note_index;
while ( $sequence_index > -1 ) {

    #     <-   <-    <-    *
    #   W    W     h    W
    # D .. E .. F# .. G .. A

    $chromatic_index = minus_index ( $chromatic_index, $sequence[$sequence_index], scalar(@chromatic_scale) );
    $sequence_index--;
}

# Using the major scale interval sequence, print the notes for the relative major scale
my $major_scale = $chromatic_scale[$chromatic_index];

# Our scale is A Mixolydian, the relative Major scale is D Major
my @notes = reorder_to_note( $note, major_notes( $chromatic_index ) );

print "\n\n";
print "$note $mode Scale\n\n";
print "Notes: " . join( ", ", @notes );
print "\n\n";

sub reorder_to_note {
    my $note = shift;
    my @notes = @_;

    while ( $notes[0] ne $note ){
        push @notes, shift @notes;
    }

    return @notes;
}

sub major_notes {
    my $note_index = shift;
    my @notes = ( $chromatic_scale[$note_index] );

    foreach my $seq ( @sequence ) {
        $note_index = add_index( $note_index, $seq, scalar( @chromatic_scale ) );
        push @notes, $chromatic_scale[$note_index]
    }

    pop( @notes );
    return @notes;
}
sub minus_index { 
    my ( $ind, $step, $max ) = @_;
    
    $ind = $ind - $step;

    if ( $ind < 0 ) {
        $ind = $max + $ind;
    }

    return $ind;
}
sub add_index {
    my ( $ind, $step, $max ) = @_;

    $ind = $ind + $step;

    if ( $ind >= $max ) {
        $ind = 0 + $ind - $max;
    }

    return $ind;
}
sub mode_index { return _item_index( $_[0], @modes ); }
sub note_index { return _item_index( $_[0], @chromatic_scale ); }
sub _item_index {
    my $item = shift;
    my @arr = @_;
    my $ind = 0;

    foreach my $n ( @arr ) {
        return $ind if ( $n eq $item );
        $ind++;
    }
}
